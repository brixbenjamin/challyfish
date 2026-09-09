import { assertEquals } from "jsr:@std/assert@1";
import { planWrites } from "./mapping.ts";

const USER = "11111111-1111-1111-1111-111111111111";
const OTHER = "22222222-2222-2222-2222-222222222222";
const PRODUCT = "pack.edge";

function event(overrides: Record<string, unknown>) {
  return {
    event: {
      type: "NON_RENEWING_PURCHASE",
      app_user_id: USER,
      product_id: PRODUCT,
      ...overrides,
    },
  };
}

Deno.test("a one-time purchase grants the product to its buyer", () => {
  assertEquals(planWrites(event({})), [
    { kind: "grant", userId: USER, productId: PRODUCT },
  ]);
});

Deno.test("an initial purchase grants too", () => {
  assertEquals(planWrites(event({ type: "INITIAL_PURCHASE" })), [
    { kind: "grant", userId: USER, productId: PRODUCT },
  ]);
});

Deno.test("a refund revokes", () => {
  assertEquals(planWrites(event({ type: "REFUND" })), [
    { kind: "revoke", userId: USER, productId: PRODUCT },
  ]);
});

Deno.test("a cancellation of a one-time purchase revokes", () => {
  assertEquals(planWrites(event({ type: "CANCELLATION" })), [
    { kind: "revoke", userId: USER, productId: PRODUCT },
  ]);
});

Deno.test("a transfer moves the product between app user ids", () => {
  const writes = planWrites({
    event: {
      type: "TRANSFER",
      product_id: PRODUCT,
      transferred_from: [USER],
      transferred_to: [OTHER],
    },
  });
  assertEquals(writes, [
    { kind: "revoke", userId: USER, productId: PRODUCT },
    { kind: "grant", userId: OTHER, productId: PRODUCT },
  ]);
});

Deno.test("a transfer with no product id is ignored rather than guessed", () => {
  assertEquals(
    planWrites({
      event: {
        type: "TRANSFER",
        transferred_from: [USER],
        transferred_to: [OTHER],
      },
    }),
    [],
  );
});

Deno.test("a RevenueCat anonymous id is not one of our users", () => {
  // Our gateway always configures with the Supabase user id (ADR-0017), so an
  // anonymous id means the purchase belongs to nobody we can name. Guessing is
  // worse than dropping it.
  assertEquals(planWrites(event({ app_user_id: "$RCAnonymousID:8a9f3c" })), []);
});

Deno.test("a non-uuid app user id is ignored", () => {
  assertEquals(planWrites(event({ app_user_id: "someone@example.com" })), []);
});

Deno.test("an event with no product id is ignored", () => {
  assertEquals(planWrites(event({ product_id: undefined })), []);
});

Deno.test("an event type we do not handle is ignored, not an error", () => {
  assertEquals(planWrites(event({ type: "SUBSCRIPTION_PAUSED" })), []);
  assertEquals(planWrites(event({ type: "TEST" })), []);
});

Deno.test("a body that is not an event is ignored", () => {
  assertEquals(planWrites({}), []);
  assertEquals(planWrites({ event: null }), []);
  assertEquals(planWrites("nonsense"), []);
});
