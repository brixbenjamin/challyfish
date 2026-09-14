-- Placeholder actions. The real copy is written against the safety floor in
-- design spec section 9 and is not this plan's deliverable (Q2, Q11).
--
-- Every title is prefixed with [PLACEHOLDER] so the signal survives a copy-paste
-- that drops this header comment. Nothing here has been through the safety-floor
-- review in docs/product/content-review.md (ADR-0020); it must not be mistaken
-- for reviewed content.
--
-- The authored copy is no longer in this file. It moved to seed/action_bodies.sql
-- when it moved out of public.actions, so entitlement could be a row-level policy
-- rather than an application check (ADR-0025). That file recomputes the same md5
-- ids rather than joining, so both files agree across a db reset.
--
-- Ids are derived from (campaign_id, day_index) rather than left to the column
-- default, and that is load-bearing rather than tidiness. `gen_random_uuid()`
-- mints new ids on every `db reset`, which silently breaks two things at once:
-- the bundled snapshot in app/assets/seed/core_content.json pins whatever ids
-- one run happened to produce, and a device that seeded from it then writes
-- day_logs.action_id values this database has never heard of. The client cannot
-- repair that on its own — actions is keyed on id, so the same (campaign, day)
-- arriving under a new id is a second row, not a correction. Every other seed
-- file pins its ids by hand for the same reason; these are only computed
-- because there are 123 of them.
--
-- The action no longer knows its campaign or its day number. It knows its day,
-- and the day knows the rest (ADR-0034). The md5 below is over the *day* id, so
-- seed/days.sql and this file agree without joining.
--
-- The action and its archetype shares are written by one statement, not two.
-- actions_have_an_archetype is a deferred constraint trigger, so it is checked
-- at commit -- and `supabase db reset` seeds over the wire, where the
-- transaction boundaries around a file are not ours to assume. A single
-- statement is atomic under either.
--
-- Day 5 is authored 2:1 across two drives: a placeholder, but a real one, so
-- the split path is exercised by the seed, the bundled snapshot and every test
-- that reads them rather than only by unit tests.
with authored as (
  select
    md5('feral:action:' || v.campaign_id || ':' || v.day_index)::uuid as id,
    md5('feral:day:'    || v.campaign_id || ':' || v.day_index)::uuid as day_id,
    v.title,
    v.effort,
    v.archetype_id::uuid as archetype_id,
    v.share
  from (
    values
      ('bbbbbbbb-0000-0000-0000-000000000001', 1, '[PLACEHOLDER] State a preference out loud',
       1, 'cccccccc-0000-0000-0000-000000000002', 1),
      ('bbbbbbbb-0000-0000-0000-000000000001', 2, '[PLACEHOLDER] Ask for something small',
       1, 'cccccccc-0000-0000-0000-000000000002', 1),
      ('bbbbbbbb-0000-0000-0000-000000000001', 3, '[PLACEHOLDER] Do not explain yourself',
       2, 'cccccccc-0000-0000-0000-000000000002', 1),
      ('bbbbbbbb-0000-0000-0000-000000000001', 4, '[PLACEHOLDER] Go first',
       2, 'cccccccc-0000-0000-0000-000000000002', 1),
      -- Two drives, 2:1. Three points become two and one; the act is not worth
      -- more for being tagged twice.
      ('bbbbbbbb-0000-0000-0000-000000000001', 5, '[PLACEHOLDER] Disagree in the room',
       3, 'cccccccc-0000-0000-0000-000000000002', 2),
      ('bbbbbbbb-0000-0000-0000-000000000001', 5, '[PLACEHOLDER] Disagree in the room',
       3, 'cccccccc-0000-0000-0000-000000000001', 1),
      ('bbbbbbbb-0000-0000-0000-000000000001', 6, '[PLACEHOLDER] Take the harder option',
       3, 'cccccccc-0000-0000-0000-000000000002', 1),
      ('bbbbbbbb-0000-0000-0000-000000000001', 7, '[PLACEHOLDER] Say the thing you have been not saying',
       3, 'cccccccc-0000-0000-0000-000000000002', 1)
  ) as v(campaign_id, day_index, title, effort, archetype_id, share)
), inserted as (
  -- Data-modifying CTEs run to completion whether or not the main query reads
  -- them, and the foreign key is checked at end of statement, by which point
  -- both inserts have happened.
  insert into public.actions (id, day_id, title, effort)
  select distinct id, day_id, title, effort from authored
)
insert into public.action_archetypes (action_id, archetype_id, share)
select id, archetype_id, share from authored;

-- One placeholder action per day for the five campaigns added by the launch
-- library, so every structural check runs against a full-length campaign. Each
-- row is replaced by authored copy before launch; none of these bodies may
-- reach a store, and tool/launch_readiness.sql refuses while any remain.
with generated as (
  select
    md5('feral:action:' || c.id || ':' || g.day)::uuid as id,
    md5('feral:day:'    || c.id || ':' || g.day)::uuid as day_id,
    format('Day %s', g.day) as title,
    1 + (g.day % 3) as effort,
    (select ca.archetype_id
       from public.campaign_archetypes ca
      where ca.campaign_id = c.id
      order by ca.archetype_id
      limit 1) as archetype_id
  from public.campaigns c
  cross join lateral generate_series(1, c.length_days) as g(day)
  where c.id in (
    'bbbbbbbb-0000-0000-0000-000000000002',
    'bbbbbbbb-0000-0000-0000-000000000003',
    'bbbbbbbb-0000-0000-0000-000000000004',
    'bbbbbbbb-0000-0000-0000-000000000005',
    'bbbbbbbb-0000-0000-0000-000000000006'
  )
), inserted as (
  insert into public.actions (id, day_id, title, effort)
  select id, day_id, title, effort from generated
)
insert into public.action_archetypes (action_id, archetype_id, share)
select id, archetype_id, 1 from generated;
