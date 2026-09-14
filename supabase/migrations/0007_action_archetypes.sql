-- Multi-archetype actions. Amends ADR-0004, which required every action to
-- carry exactly one archetype and accepted, as a named cost, that an action
-- plausibly serving two drives had to pick one.
--
-- An action now declares its drives in a join table with an integer `share`.
-- The share is a ratio numerator, not a multiplier: the weight the client
-- applies is `share / sum(shares for that action)`, so an action contributes
-- exactly its own `effort` however many rows it has here. That is what keeps
-- multi-tagging from being the cheapest way to fill the radar, and what keeps
-- BalanceWeights.fullAxisValue derivable from the day cap and the half-life.

create table public.action_archetypes (
  action_id    uuid not null references public.actions (id) on delete cascade,
  archetype_id uuid not null references public.archetypes (id),
  -- Small integers by convention: 1 for a single drive, 1:1 for an even pair,
  -- 2:1 where there is a clear primary. Bigger numbers buy nothing, because
  -- the client normalises before using them.
  share        int  not null default 1 check (share > 0),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  primary key (action_id, archetype_id)
);

-- The watermark pull filters on updated_at across every content table.
create index action_archetypes_updated_idx on public.action_archetypes (updated_at);

create trigger action_archetypes_touch before update on public.action_archetypes
  for each row execute function public.touch_updated_at();

-- Backfill before the column goes, one row per action at share 1. That
-- normalises to weight 1.0, which is arithmetically what the column meant, so
-- no existing radar moves when this ships.
insert into public.action_archetypes (action_id, archetype_id, share, updated_at)
select id, archetype_id, 1, updated_at from public.actions;

alter table public.actions drop column archetype_id;

-- The dropped column was `not null`, which made "every action has an archetype"
-- true by construction. A join table cannot express that, so it is enforced
-- here rather than left to authoring discipline -- an action with no archetype
-- is content that reaches the client, is ticked, and contributes to nothing.
--
-- DEFERRABLE INITIALLY DEFERRED, because an action and its archetypes cannot be
-- written in the same statement in the general case: the check has to run at
-- commit, when the transaction is whole, not between two inserts.
create function public.assert_action_has_archetype() returns trigger
language plpgsql as $$
declare
  target uuid;
begin
  -- One function, two tables. On `actions` the row being checked is the action
  -- itself; on `action_archetypes` it is always OLD's action, because that is
  -- the one a delete -- or an update that moves the row to another action --
  -- can leave with nothing. NEW's action gained a row and cannot be empty.
  if tg_table_name = 'actions' then
    target := new.id;
  else
    target := old.action_id;
  end if;

  -- The action may itself be gone: deleting an action cascades its archetype
  -- rows away, and that is not a violation.
  if not exists (select 1 from public.actions a where a.id = target) then
    return null;
  end if;

  if not exists (
    select 1 from public.action_archetypes aa where aa.action_id = target
  ) then
    raise exception 'action % has no archetype', target
      using errcode = 'check_violation';
  end if;

  return null;
end;
$$;

create constraint trigger actions_have_an_archetype
  after insert on public.actions
  deferrable initially deferred
  for each row execute function public.assert_action_has_archetype();

create constraint trigger action_archetypes_leave_one
  after delete or update on public.action_archetypes
  deferrable initially deferred
  for each row execute function public.assert_action_has_archetype();

-- Content: readable by everyone, writable only by the service role, exactly as
-- the tables in 0003. Granting no write policy is what makes it read-only, and
-- the grant is what makes the policy reachable at all.
alter table public.action_archetypes enable row level security;

create policy action_archetypes_read on public.action_archetypes
  for select to anon, authenticated using (true);

grant select on public.action_archetypes to anon, authenticated;
grant select, insert, update, delete on public.action_archetypes to service_role;
