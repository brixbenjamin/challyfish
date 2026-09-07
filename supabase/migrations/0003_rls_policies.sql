-- Row-level security is the trust boundary. The client is never the thing that
-- decides whether a row is readable. See docs/technical/security.md.

-- Content: readable by everyone, writable only by the service role (which
-- bypasses RLS). Granting no write policy is what makes it read-only.
do $$
declare t text;
begin
  foreach t in array array[
    'archetypes', 'doctrine_groups', 'doctrine_entries',
    'packs', 'campaigns', 'campaign_archetypes', 'actions'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy %I_read on public.%I for select to anon, authenticated using (true)',
      t, t
    );
  end loop;
end;
$$;

-- User tables: full access to your own rows, no access to anyone else's.
do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'diagnostic_results', 'campaign_runs', 'day_logs'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy %I_owner_select on public.%I for select to authenticated
         using (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_owner_insert on public.%I for insert to authenticated
         with check (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_owner_update on public.%I for update to authenticated
         using (auth.uid() = user_id) with check (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_owner_delete on public.%I for delete to authenticated
         using (auth.uid() = user_id)', t, t);
  end loop;
end;
$$;

-- Entitlements are written by the purchase webhook, never by the client.
-- Read-only here is the control that stops a client granting itself a pack.
alter table public.entitlements enable row level security;

create policy entitlements_owner_select on public.entitlements
  for select to authenticated using (auth.uid() = user_id);
