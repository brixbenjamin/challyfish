insert into public.campaigns
  (id, pack_id, key, title, subtitle, intro_md, length_days, ramp_days, difficulty, sort)
values
  ('bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'first-week',
   'The First Week',
   'Seven days of saying the thing.',
   'Seven days. One act a day, each one small enough that you cannot reasonably claim it was impossible, and large enough that you will want to skip it.',
   7, 2, 1, 1);

-- Only killer is weighted for this placeholder campaign; the other three
-- archetypes are intentionally absent here, not an oversight.
insert into public.campaign_archetypes (campaign_id, archetype_id, weight) values
  ('bbbbbbbb-0000-0000-0000-000000000001', 'cccccccc-0000-0000-0000-000000000002', 1);
