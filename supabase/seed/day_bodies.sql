-- The day's framing copy, separated from the day so entitlement can be a
-- row-level policy rather than an application check (ADR-0025, ADR-0034).
--
-- Ids are recomputed with the same md5 expression as seed/days.sql rather than
-- joined, so both files agree across a `db reset` without depending on insertion
-- order. Read that file's header before changing either.
--
-- The authoring constraint these bodies are placeholders for: a day body must
-- convey what the day asks WITHOUT enumerating it. The actions are revealed by
-- the commit, so a body that lists them makes the commit redundant and a body
-- that says nothing makes it blind (ADR-0034).
--
-- Every body here is unauthored placeholder text and nothing in this file has
-- been through the safety-floor review in docs/product/content-review.md
-- (ADR-0020). tool/launch_readiness.sql refuses while any marker remains.

insert into public.day_bodies (day_id, body_md)
select
  md5('feral:day:' || v.campaign_id || ':' || v.day_index)::uuid,
  v.body_md
from (
  values
    ('bbbbbbbb-0000-0000-0000-000000000001', 1,
     '[PLACEHOLDER] Today is about being audible. Not louder -- audible.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 2,
     '[PLACEHOLDER] Today you find out what you have been going without.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 3,
     '[PLACEHOLDER] Today the sentence ends where you end it.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 4,
     '[PLACEHOLDER] Today you stop waiting to be invited.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 5,
     '[PLACEHOLDER] Today costs something. That is how you know it counted.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 6,
     '[PLACEHOLDER] Today you take the road you would rather not.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 7,
     '[PLACEHOLDER] Today is the one you have been circling all week.')
) as v (campaign_id, day_index, body_md);

-- The generated campaigns, matching the second insert in seed/days.sql.
insert into public.day_bodies (day_id, body_md)
select
  md5('feral:day:' || c.id || ':' || g.day)::uuid,
  '[TO AUTHOR]'
from public.campaigns c
cross join lateral generate_series(1, c.length_days) as g(day)
where c.id in (
  'bbbbbbbb-0000-0000-0000-000000000002',
  'bbbbbbbb-0000-0000-0000-000000000003',
  'bbbbbbbb-0000-0000-0000-000000000004',
  'bbbbbbbb-0000-0000-0000-000000000005',
  'bbbbbbbb-0000-0000-0000-000000000006'
);
