// What a RevenueCat event means, decided in one pure function so it can be
// tested as a table instead of by POSTing at a live function.
//
// Rules (ADR-0017, ADR-0019):
//  * the subject is `app_user_id`, and only if it parses as a uuid;
//  * one product maps to one pack, resolved later through packs.store_product_id;
//  * anything else is an empty plan — a no-op the caller answers 200 to.

export type WebhookWrite =
  | { kind: "grant"; userId: string; productId: string }
  | { kind: "revoke"; userId: string; productId: string };

// The shape Postgres itself accepts for `uuid`, deliberately not the stricter
// RFC-4122 version-and-variant form. This test is only here to tell one of our
// user ids from a RevenueCat anonymous id or a test payload; insisting on the
// v4 bits would silently drop a real purchase from any account whose id is not
// v4, and the foreign key to auth.users already rejects an id that is not ours.
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function asUserId(value: unknown): string | null {
  return typeof value === "string" && UUID.test(value) ? value : null;
}

function asProductId(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function asUserIds(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map(asUserId).filter((id): id is string => id !== null);
}

export function planWrites(payload: unknown): WebhookWrite[] {
  if (typeof payload !== "object" || payload === null) return [];
  const event = (payload as { event?: unknown }).event;
  if (typeof event !== "object" || event === null) return [];

  const e = event as Record<string, unknown>;
  const type = typeof e.type === "string" ? e.type : "";
  const productId = asProductId(e.product_id);
  if (productId === null) return [];

  switch (type) {
    case "INITIAL_PURCHASE":
    case "NON_RENEWING_PURCHASE": {
      const userId = asUserId(e.app_user_id);
      return userId === null ? [] : [{ kind: "grant", userId, productId }];
    }

    case "REFUND":
    case "CANCELLATION": {
      const userId = asUserId(e.app_user_id);
      return userId === null ? [] : [{ kind: "revoke", userId, productId }];
    }

    case "TRANSFER": {
      // A store account's purchases moving to a different app user id — what a
      // reinstall plus restore looks like. Both sides are named in the payload.
      //
      // If a transfer is ever missed, the device is still correct: the client
      // unions these rows with the SDK's cached product ids (ADR-0017), so only
      // the durable copy lags, and only until the next event.
      const writes: WebhookWrite[] = [];
      for (const userId of asUserIds(e.transferred_from)) {
        writes.push({ kind: "revoke", userId, productId });
      }
      for (const userId of asUserIds(e.transferred_to)) {
        writes.push({ kind: "grant", userId, productId });
      }
      return writes;
    }

    default:
      // Subscription lifecycle events, test pings, anything RevenueCat adds
      // later. Not ours, not an error.
      return [];
  }
}
