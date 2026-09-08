import { createClient } from "@supabase/supabase-js";

// Deletes the CALLING user's own account.
//
// It takes no user id. The subject comes from the verified JWT and nowhere
// else (ADR-0015). An endpoint that accepts an id to delete is an endpoint
// that can delete someone else's account, and no amount of checking makes that
// as safe as not offering the parameter at all.
//
// This function holds the service role key. It and the purchase webhook are
// the only two places in the system where a secret may exist.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, code: string, message: string): Response {
  return new Response(
    JSON.stringify({ error: { code, message, details: {} } }),
    { status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json(405, "method_not_allowed", "Use POST.");
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return json(401, "unauthorized", "A session token is required.");
  }

  const url = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Verify the caller with the anon key and their own token: this both
  // authenticates them and yields the only user id this request may touch.
  const caller = createClient(url, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });

  const { data: userData, error: userError } = await caller.auth.getUser();
  if (userError || !userData.user) {
    return json(401, "unauthorized", "That session is not valid.");
  }

  const subject = userData.user.id;

  const admin = createClient(url, serviceRoleKey, {
    auth: { persistSession: false },
  });

  // Foreign keys cascade to profiles, diagnostic_results, campaign_runs,
  // day_logs and entitlements. Asserted by supabase/tests/060_delete_cascade.sql
  // rather than assumed from the schema.
  const { error: deleteError } = await admin.auth.admin.deleteUser(subject);
  if (deleteError) {
    console.error("delete-account failed", {
      subject,
      message: deleteError.message,
    });
    return json(500, "delete_failed", "The account could not be deleted.");
  }

  return new Response(null, { status: 204, headers: corsHeaders });
});
