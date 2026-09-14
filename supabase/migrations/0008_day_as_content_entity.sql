-- The day becomes a content entity (ADR-0034). Before this, a day was an
-- integer that several `actions` rows happened to share, and nothing could be
-- said about a day that was not said about one of its actions.
--
-- Append-only, with a backfill -- not a rewrite of 0001. Rewriting 0001 would
-- also mean rewriting 0006's day-slot constraint and 0007's trigger commentary,
-- and would strand any local or branch database that cannot be reached by
-- `supabase db reset` alone.

create table public.days (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns (id) on delete cascade,
  day_index int not null check (day_index > 0),
  title text not null,
  -- A check-constrained text column, not a boolean. The taxonomy already has a
  -- second member lurking -- the bridge day, currently signalled by
  -- actions.why_doctrine_id (ADR-0027, Q19) -- and parallel booleans would
  -- permit a day that is both rest and bridge, which is nonsense.
  kind text not null default 'standard' check (kind in ('standard', 'rest')),
  -- The one drive the day's surface wears, under the One Drive Per Loop Rule.
  -- Nullable: unset means the surface falls back to the mandatory action's
  -- dominant drive, which is what it does today.
  primary_archetype_id uuid references public.archetypes (id),
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (campaign_id, day_index)
);

create index days_campaign_idx on public.days (campaign_id, day_index);
create index days_updated_idx  on public.days (updated_at);

-- The day's framing copy: what the user reads before committing. Separated from
-- `days` for the same reason action_bodies is separated from actions (ADR-0025)
-- -- everything else about a day is public, and this is not.
create table public.day_bodies (
  day_id     uuid primary key references public.days (id) on delete cascade,
  body_md    text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index day_bodies_updated_idx on public.day_bodies (updated_at);

create trigger days_touch before update on public.days
  for each row execute function public.touch_updated_at();
create trigger day_bodies_touch before update on public.day_bodies
  for each row execute function public.touch_updated_at();

-- One day per distinct (campaign, day_index) already present in `actions`.
--
-- The id is derived rather than left to the column default. seed/days.sql mints
-- the same md5, so a database reached by this migration and one reached by
-- `supabase db reset` agree on every day id -- and the bundled snapshot pins an
-- id that survives both. This is the same reasoning as the header of
-- seed/actions.sql, and it is load-bearing rather than tidiness.
insert into public.days (id, campaign_id, day_index, title, updated_at)
select
  md5('feral:day:' || a.campaign_id || ':' || a.day_index)::uuid,
  a.campaign_id,
  a.day_index,
  -- Placeholder, and knowingly so: a day title cannot be honestly backfilled.
  -- tool/launch_readiness.sql refuses on exactly this pattern.
  format('Day %s', a.day_index),
  max(a.updated_at)
from public.actions a
group by a.campaign_id, a.day_index;

-- day_bodies gets no backfill at all. There is nothing to synthesize a day's
-- framing copy from, and a fabricated body would be worse than an absent one:
-- the launch gate can refuse a missing body and cannot detect an invented one.

alter table public.actions
  add column day_id uuid references public.days (id) on delete cascade;

update public.actions a
   set day_id = d.id
  from public.days d
 where d.campaign_id = a.campaign_id
   and d.day_index   = a.day_index;

alter table public.actions alter column day_id set not null;

create index actions_day_idx on public.actions (day_id, sort);

-- The two constraints from ADR-0030 move down a level. Over (day_id) they are
-- constraints on a real foreign key rather than on two columns kept consistent
-- by authoring discipline across rows that are supposed to describe one day.
alter table public.actions drop constraint actions_day_slot_key;
alter table public.actions add  constraint actions_day_slot_key unique (day_id, sort);

drop index public.actions_one_mandatory_per_day;
create unique index actions_one_mandatory_per_day
  on public.actions (day_id) where not is_optional;

-- The day knows its campaign. A denormalized copy is a second place for the
-- truth to live and eventually disagree -- the same argument that moved the
-- archetype out in 0007, applied to position instead of meaning.
--
-- actions_campaign_idx is over (campaign_id, day_index) and is dropped by
-- Postgres along with the columns; actions_day_idx above replaces it.
alter table public.actions drop column day_index;
alter table public.actions drop column campaign_id;

-- Content: readable by everyone, writable only by the service role, exactly as
-- the tables in 0003. `days` joins the teaser loop; day_bodies deliberately
-- does not, and the absence is the point (ADR-0025, ADR-0034).
alter table public.days enable row level security;

create policy days_read on public.days
  for select to anon, authenticated using (true);

grant select on public.days to anon, authenticated;
grant select, insert, update, delete on public.days to service_role;

-- The action -> campaign join now goes through days, so 0003's helper is wrong
-- rather than merely out of date: `a.campaign_id` no longer exists and the
-- function would fail to resolve on its next call. Rewritten, not replaced --
-- the policy in 0003 keeps pointing at this name.
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
    join public.days d      on d.id = a.day_id
    join public.campaigns c on c.id = d.campaign_id
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

-- The same shape for days. `private` is not an exposed schema, which is what
-- keeps it unreachable through PostgREST regardless of grants; search_path = ''
-- forces every reference to be qualified, so a caller's search path cannot
-- redirect it.
create or replace function private.day_body_readable(p_day_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.days d
    join public.campaigns c on c.id = d.campaign_id
    join public.packs p     on p.id = c.pack_id
    where d.id = p_day_id
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

-- `grant usage on schema private` is already in place from 0003. Isolation comes
-- from `private` being unexposed, not from withholding execute -- a policy that
-- cannot call its own helper fails closed and locks every user out of the free
-- pack too.
grant execute on function private.day_body_readable(uuid) to anon, authenticated;

alter table public.day_bodies enable row level security;

create policy day_bodies_entitled_read on public.day_bodies
  for select to anon, authenticated
  using (private.day_body_readable(day_id));

grant select on public.day_bodies to anon, authenticated;
grant select, insert, update, delete on public.day_bodies to service_role;
