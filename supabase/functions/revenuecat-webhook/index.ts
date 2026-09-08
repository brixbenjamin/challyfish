import { createClient } from "@supabase/supabase-js";

import { planWrites } from "./mapping.ts";

// Receives RevenueCat purchase events and is the ONLY writer of
// public.entitlements (ADR-0017). It holds the service role key and the webhook
// shared secret; with delete-account it is one of exactly two functions in v1,
// and the only two places a secret exists.
//
// Answer 2xx to anything that cannot be acted on. A 500 on an event we will
// never handle makes RevenueCat retry the same payload forever and buries the
// delivery that matters.

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/// Constant-time comparison: a length-or-first-difference check on a shared
/// secret leaks it a byte at a time to anyone willing to send enough requests.
function secretMatches(provided: string, expected: string): boolean {
  if (provided.length !== expected.length) return false;
  let diff = 0;
  for (let i = 0; i < provided.length; i++) {
    diff |= provided.charCodeAt(i) ^ expected.charCodeAt(i);
  }
  return diff === 0;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json(405, { error: "method_not_allowed" });
  }

  const expected = Deno.env.get("REVENUECAT_WEBHOOK_SECRET") ?? "";
  const provided = req.headers.get("Authorization") ?? "";
  if (expected.length === 0 || !secretMatches(provided, expected)) {
    return json(401, { error: "unauthorized" });
  }

  let payload: unknown;
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "bad_request" });
  }

  const writes = planWrites(payload);
  if (writes.length === 0) {
    // Deliberate no-op: an event type we do not handle, or an app user id that
    // is not one of ours. Accepted so it is not redelivered.
    console.log("revenuecat-webhook: no-op", {
      type: (payload as { event?: { type?: unknown } })?.event?.type ?? null,
    });
    return json(200, { applied: 0 });
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  let applied = 0;
  for (const write of writes) {
    // ADR-0019: one product, one pack, resolved through this column alone.
    const { data: pack, error: packError } = await admin
      .from("packs")
      .select("id")
      .eq("store_product_id", write.productId)
      .maybeSingle();

    if (packError) {
      console.error("revenuecat-webhook: pack lookup failed", {
        productId: write.productId,
        message: packError.message,
      });
      return json(500, { error: "lookup_failed" });
    }

    if (!pack) {
      // A product that matches no pack: a store product configured before its
      // pack ships, or a pack withdrawn. Not an error.
      console.log("revenuecat-webhook: unknown product", {
        productId: write.productId,
      });
      continue;
    }

    if (write.kind === "grant") {
      const { error } = await admin.from("entitlements").upsert({
        user_id: write.userId,
        pack_id: pack.id,
        source: "store",
        updated_at: new Date().toISOString(),
      }, { onConflict: "user_id,pack_id" });

      if (error) {
        console.error("revenuecat-webhook: grant failed", {
          userId: write.userId,
          message: error.message,
        });
        return json(500, { error: "write_failed" });
      }
    } else {
      const { error } = await admin
        .from("entitlements")
        .delete()
        .eq("user_id", write.userId)
        .eq("pack_id", pack.id);

      if (error) {
        console.error("revenuecat-webhook: revoke failed", {
          userId: write.userId,
          message: error.message,
        });
        return json(500, { error: "write_failed" });
      }
    }

    applied++;
  }

  return json(200, { applied });
});
