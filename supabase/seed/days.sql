-- One row per campaign day (ADR-0034). Slots in before seed/actions.sql, which
-- now hangs its rows off these ids.
--
-- Ids are derived from (campaign_id, day_index) rather than left to the column
-- default, for the reason spelled out at the top of seed/actions.sql:
-- gen_random_uuid() mints new ids on every `db reset`, the bundled snapshot in
-- app/assets/seed/core_content.json pins whatever one run produced, and the
-- client cannot repair a re-issued id on its own. migrations/0008 computes the
-- same md5 for its backfill, so a migrated database and a reset one agree.
--
-- Every title here is prefixed with [PLACEHOLDER]. Nothing in this file has been
-- through the safety-floor review in docs/product/content-review.md (ADR-0020).
-- The generated days below carry the synthesized `Day N` title instead, which
-- tool/launch_readiness.sql refuses on separately -- a synthesized title is not
-- placeholder copy that was written and not reviewed, it is copy that was never
-- written at all, and the gate has to be able to tell those apart.

insert into public.days (id, campaign_id, day_index, title, kind)
select
  md5('feral:day:' || v.campaign_id || ':' || v.day_index)::uuid,
  v.campaign_id::uuid,
  v.day_index,
  v.title,
  v.kind
from (
  values
    ('bbbbbbbb-0000-0000-0000-000000000001', 1, '[PLACEHOLDER] The first word', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 2, '[PLACEHOLDER] The ask', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 3, '[PLACEHOLDER] No explanation', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 4, '[PLACEHOLDER] Going first', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 5, '[PLACEHOLDER] The disagreement', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 6, '[PLACEHOLDER] The harder road', 'standard'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 7, '[PLACEHOLDER] The unsaid thing', 'standard')
) as v (campaign_id, day_index, title, kind);

-- The launch library. One day per campaign day for the five generated campaigns,
-- matching the generate_series block in seed/actions.sql exactly.
insert into public.days (id, campaign_id, day_index, title)
select
  md5('feral:day:' || c.id || ':' || g.day)::uuid,
  c.id,
  g.day,
  format('Day %s', g.day)
from public.campaigns c
cross join lateral generate_series(1, c.length_days) as g(day)
where c.id in (
  'bbbbbbbb-0000-0000-0000-000000000002',
  'bbbbbbbb-0000-0000-0000-000000000003',
  'bbbbbbbb-0000-0000-0000-000000000004',
  'bbbbbbbb-0000-0000-0000-000000000005',
  'bbbbbbbb-0000-0000-0000-000000000006'
);
