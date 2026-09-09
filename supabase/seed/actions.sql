-- Placeholder actions. The real copy is written against the safety floor in
-- design spec section 9 and is not this plan's deliverable (Q2, Q11).
--
-- Every title and body_md is prefixed with [PLACEHOLDER] so the signal survives
-- a copy-paste that drops this header comment. Nothing here has been through the
-- safety-floor review in docs/product/content-review.md (ADR-0020); it must not
-- be mistaken for reviewed content.
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
insert into public.actions
  (id, campaign_id, day_index, title, body_md, archetype_id, effort)
select
  md5('feral:action:' || v.campaign_id || ':' || v.day_index)::uuid,
  v.campaign_id::uuid,
  v.day_index,
  v.title,
  v.body_md,
  v.archetype_id::uuid,
  v.effort
from (
  values
    ('bbbbbbbb-0000-0000-0000-000000000001', 1, '[PLACEHOLDER] State a preference out loud',
     '[PLACEHOLDER] Once today, when someone asks what you want, answer immediately and do not soften it.',
     'cccccccc-0000-0000-0000-000000000002', 1),
    ('bbbbbbbb-0000-0000-0000-000000000001', 2, '[PLACEHOLDER] Ask for something small',
     '[PLACEHOLDER] Ask one person for one thing you would normally not bother asking for.',
     'cccccccc-0000-0000-0000-000000000002', 1),
    ('bbbbbbbb-0000-0000-0000-000000000001', 3, '[PLACEHOLDER] Do not explain yourself',
     '[PLACEHOLDER] Say no once today, and stop talking after you have said it.',
     'cccccccc-0000-0000-0000-000000000002', 2),
    ('bbbbbbbb-0000-0000-0000-000000000001', 4, '[PLACEHOLDER] Go first',
     '[PLACEHOLDER] In one conversation today, be the first to speak.',
     'cccccccc-0000-0000-0000-000000000002', 2),
    ('bbbbbbbb-0000-0000-0000-000000000001', 5, '[PLACEHOLDER] Disagree in the room',
     '[PLACEHOLDER] Say the disagreeing thing once, while the subject is still open.',
     'cccccccc-0000-0000-0000-000000000002', 3),
    ('bbbbbbbb-0000-0000-0000-000000000001', 6, '[PLACEHOLDER] Take the harder option',
     '[PLACEHOLDER] Where two options exist today and one is easier, take the other.',
     'cccccccc-0000-0000-0000-000000000002', 3),
    ('bbbbbbbb-0000-0000-0000-000000000001', 7,
     '[PLACEHOLDER] Say the thing you have been not saying',
     '[PLACEHOLDER] You already know what it is. Say it to the person it concerns.',
     'cccccccc-0000-0000-0000-000000000002', 3)
) as v(campaign_id, day_index, title, body_md, archetype_id, effort);

-- One placeholder action per day for the five campaigns added by the launch
-- library, so every structural check runs against a full-length campaign. Each
-- row is replaced by authored copy before launch; none of these bodies may
-- reach a store, and tool/launch_readiness.sql refuses while any remain.
insert into public.actions
  (id, campaign_id, day_index, title, body_md, archetype_id, effort)
select
  md5('feral:action:' || c.id || ':' || g.day)::uuid,
  c.id,
  g.day,
  format('Day %s', g.day),
  '[TO AUTHOR]',
  (select ca.archetype_id
     from public.campaign_archetypes ca
    where ca.campaign_id = c.id
    order by ca.archetype_id
    limit 1),
  1 + (g.day % 3)
from public.campaigns c
cross join lateral generate_series(1, c.length_days) as g(day)
where c.id in (
  'bbbbbbbb-0000-0000-0000-000000000002',
  'bbbbbbbb-0000-0000-0000-000000000003',
  'bbbbbbbb-0000-0000-0000-000000000004',
  'bbbbbbbb-0000-0000-0000-000000000005',
  'bbbbbbbb-0000-0000-0000-000000000006'
);
