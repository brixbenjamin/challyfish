-- Multi-action days (ADR-0030). A day carries exactly one mandatory action and
-- zero or more optional ones; the day itself stays one row, one commit, one
-- report. The outcome stops being chosen and starts being derived from which
-- actions the user ticked.

alter table public.actions
  add column is_optional boolean not null default false,
  add column sort        int     not null default 0;

-- The day is no longer the unique slot -- (day, sort) is. Existing rows all
-- default to sort 0, so every currently seeded action keeps a valid slot and
-- becomes its day's mandatory action without a data edit.
alter table public.actions drop constraint actions_campaign_id_day_index_key;
alter table public.actions add constraint actions_day_slot_key
  unique (campaign_id, day_index, sort);

-- Exactly one mandatory action per day, enforced rather than left to authoring
-- discipline. A day with two mandatory actions would make the grade ambiguous;
-- a day with none could never resolve to `done`.
create unique index actions_one_mandatory_per_day
  on public.actions (campaign_id, day_index) where not is_optional;

-- Which actions the user actually ticked.
--
-- The parent is referenced by (run_id, day_index), NOT by day_logs.id: the sync
-- merge adopts the server's uuid by deleting the local day_logs row and
-- reinserting it, so a child keyed on that surrogate id would be cascaded away
-- on every merge where two devices minted different uuids for the same day.
--
-- `completed` is a flag rather than row presence because nothing in this sync
-- design carries tombstones: a deleted tick would never reach a second device,
-- and the next pull would resurrect it.
create table public.day_log_actions (
  id         uuid primary key default gen_random_uuid(),
  -- Denormalized so RLS stays a single-table predicate, as day_logs does.
  user_id    uuid not null references auth.users (id) on delete cascade,
  run_id     uuid not null,
  day_index  int  not null check (day_index > 0),
  action_id  uuid not null references public.actions (id),
  completed  boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (run_id, day_index, action_id),
  foreign key (run_id, day_index)
    references public.day_logs (run_id, day_index) on delete cascade
);

create index day_log_actions_user_idx on public.day_log_actions (user_id);
create index day_log_actions_day_idx  on public.day_log_actions (run_id, day_index);

-- Backfill, and it is not optional: once the balance reads ticks instead of day
-- outcomes, every historical day contributes nothing without this and every
-- existing user's radar collapses to zero. A fallback in the calculator was
-- rejected as a shim that would outlive the one-time migration it served.
insert into public.day_log_actions (user_id, run_id, day_index, action_id, completed, updated_at)
select l.user_id, l.run_id, l.day_index, l.action_id, true, l.updated_at
from public.day_logs l
where l.outcome in ('done', 'partial')
on conflict (run_id, day_index, action_id) do nothing;

-- Owner-scoped policies for the new table, and a rewrite of the existing four.
-- auth.uid() unwrapped is re-evaluated per row; wrapping it in a SELECT lets
-- Postgres evaluate it once per statement. Contained improvement to a surface
-- this migration already has open, not unrelated refactoring.
--
-- The four policy names match 0003 exactly, delete included. Dropping three of
-- four would leave the original delete policy standing on the old predicate --
-- correct, but silently inconsistent with its three siblings.
alter table public.day_log_actions enable row level security;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'diagnostic_results', 'campaign_runs', 'day_logs', 'day_log_actions'
  ] loop
    execute format('drop policy if exists %I_owner_select on public.%I', t, t);
    execute format('drop policy if exists %I_owner_insert on public.%I', t, t);
    execute format('drop policy if exists %I_owner_update on public.%I', t, t);
    execute format('drop policy if exists %I_owner_delete on public.%I', t, t);

    execute format(
      'create policy %I_owner_select on public.%I for select to authenticated
         using ((select auth.uid()) = user_id)', t, t);
    execute format(
      'create policy %I_owner_insert on public.%I for insert to authenticated
         with check ((select auth.uid()) = user_id)', t, t);
    execute format(
      'create policy %I_owner_update on public.%I for update to authenticated
         using ((select auth.uid()) = user_id)
         with check ((select auth.uid()) = user_id)', t, t);
    execute format(
      'create policy %I_owner_delete on public.%I for delete to authenticated
         using ((select auth.uid()) = user_id)', t, t);
  end loop;
end $$;

-- Postgres checks table-level GRANTs before RLS policies are ever consulted, so
-- the policies above are inert without these. The grant surface mirrors the
-- policy surface exactly, as it does for every other user table in 0003.
grant select, insert, update, delete on public.day_log_actions to authenticated;
grant select, insert, update, delete on public.day_log_actions to service_role;
