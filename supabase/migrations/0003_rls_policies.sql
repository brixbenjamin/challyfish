-- Row-level security is the trust boundary. The client is never the thing that
-- decides whether a row is readable. See docs/technical/security.md.

-- Content: readable by everyone, writable only by the service role (which
-- bypasses RLS). Granting no write policy is what makes it read-only.
--
-- Postgres checks table-level GRANTs before RLS policies are ever consulted,
-- so the policy above is inert without a matching grant here. The grant
-- surface mirrors the policy surface exactly: select only for the client
-- roles, full DML for service_role (which bypasses RLS but still needs the
-- underlying privilege to touch the table at all).
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
    execute format('grant select on public.%I to anon, authenticated', t);
    execute format('grant select, insert, update, delete on public.%I to service_role', t);
  end loop;
end;
$$;

-- User tables: full access to your own rows, no access to anyone else's.
-- Grants mirror the policies: authenticated gets full DML at the table-grant
-- layer, and auth.uid() = user_id narrows it to the caller's own rows at the
-- RLS layer. service_role gets the same DML for the same reason as above.
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
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format('grant select, insert, update, delete on public.%I to service_role', t);
  end loop;
end;
$$;

-- Entitlements are written by the purchase webhook, never by the client.
-- Read-only here is the control that stops a client granting itself a pack.
-- No insert/update/delete grant for authenticated: that absence is what
-- makes the table read-only to the client at the grant layer, matching the
-- absence of any write policy at the RLS layer.
alter table public.entitlements enable row level security;

create policy entitlements_owner_select on public.entitlements
  for select to authenticated using (auth.uid() = user_id);

grant select on public.entitlements to authenticated;
grant select, insert, update, delete on public.entitlements to service_role;

-- The exception to the content block at the top of this file. A body is readable
-- when its pack is free, or when this user has bought it; the teaser it belongs
-- to stays public either way (ADR-0025). action_bodies is deliberately absent
-- from that `using (true)` loop -- the loop is the definition of "teaser", and
-- adding it there is the whole defect this migration exists to prevent.
--
-- This block sits below the entitlements policy because the helper reads
-- public.entitlements, which 0002 creates and the block above secures.
--
-- The action -> campaign -> pack lookup does not belong inline in a policy, so it
-- lives in a helper. `private` is not an exposed schema, which is what keeps it
-- unreachable through PostgREST regardless of grants; `search_path = ''` forces
-- every reference to be qualified, so a caller's search path cannot redirect it.
create schema if not exists private;

create or replace function private.action_body_readable(p_action_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.actions a
    join public.campaigns c on c.id = a.campaign_id
    join public.packs p     on p.id = c.pack_id
    where a.id = p_action_id
      and (
        p.is_core
        or exists (
          select 1 from public.entitlements e
          where e.pack_id = p.id
            and e.user_id = (select auth.uid())
        )
      )
  );
$$;

-- The policy must be able to call it. Isolation comes from `private` being
-- unexposed, not from withholding execute -- a policy that cannot call its own
-- helper fails closed and locks every user out of the free pack too.
grant usage on schema private to anon, authenticated;
grant execute on function private.action_body_readable(uuid) to anon, authenticated;

alter table public.action_bodies enable row level security;

create policy action_bodies_entitled_read on public.action_bodies
  for select to anon, authenticated
  using (private.action_body_readable(action_id));

grant select on public.action_bodies to anon, authenticated;
grant select, insert, update, delete on public.action_bodies to service_role;
