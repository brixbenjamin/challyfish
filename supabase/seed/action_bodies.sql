-- The authored copy, separated from the action so entitlement can be a row-level
-- policy rather than an application check (ADR-0025).
--
-- Ids are recomputed with the same md5 expression as seed/actions.sql rather than
-- joined, so both files agree across a `db reset` without depending on insertion
-- order. Read that file's header before changing either.
--
-- Every body here is unauthored placeholder text. Nothing in this file has been
-- through the safety-floor review in docs/product/content-review.md (ADR-0020),
-- and tool/launch_readiness.sql refuses to pass while any [TO AUTHOR] or
-- [PLACEHOLDER] marker remains. This file is the review's diff: after ADR-0025
-- the copy under review is exactly this file and nothing else.

insert into public.action_bodies (action_id, body_md)
select
  md5('feral:action:' || v.campaign_id || ':' || v.day_index)::uuid,
  v.body_md
from (
  values
    ('bbbbbbbb-0000-0000-0000-000000000001', 1,
     '[PLACEHOLDER] Once today, when someone asks what you want, answer immediately and do not soften it.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 2,
     '[PLACEHOLDER] Ask one person for one thing you would normally not bother asking for.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 3,
     '[PLACEHOLDER] Say no once today, and stop talking after you have said it.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 4,
     '[PLACEHOLDER] In one conversation today, be the first to speak.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 5,
     '[PLACEHOLDER] Say the disagreeing thing once, while the subject is still open.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 6,
     '[PLACEHOLDER] Where two options exist today and one is easier, take the other.'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 7,
     '[PLACEHOLDER] You already know what it is. Say it to the person it concerns.')
) as v (campaign_id, day_index, body_md);

-- The generated campaigns, matching the second insert in seed/actions.sql.
insert into public.action_bodies (action_id, body_md)
select
  md5('feral:action:' || c.id || ':' || g.day)::uuid,
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
