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

-- The launch library (ADR-0018): a free core pack of three campaigns at 7, 21
-- and 30 days covering all four archetypes, and one paid pack of three.
--
-- Action bodies are marked [TO AUTHOR] deliberately. The voice is still open
-- (Q2) and every action must pass the safety-floor checklist in
-- docs/product/content-review.md before it ships (ADR-0020).
-- tool/launch_readiness.sql fails while any marker remains.

insert into public.campaigns
  (id, pack_id, key, title, subtitle, intro_md, length_days, ramp_days, difficulty, sort)
values
  ('bbbbbbbb-0000-0000-0000-000000000002',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'three-weeks',
   'Three Weeks',
   '[TO AUTHOR]',
   '[TO AUTHOR]',
   21, 3, 2, 2),
  ('bbbbbbbb-0000-0000-0000-000000000003',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'thirty-days',
   'Thirty Days',
   '[TO AUTHOR]',
   '[TO AUTHOR]',
   30, 4, 3, 3);

-- Coverage, per ADR-0018: the 7-day is Killer, so these two carry Psycho,
-- Alchemist and Creature between them, completing the set of four.
insert into public.campaign_archetypes (campaign_id, archetype_id, weight) values
  ('bbbbbbbb-0000-0000-0000-000000000002', 'cccccccc-0000-0000-0000-000000000003', 1),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'cccccccc-0000-0000-0000-000000000001', 1),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'cccccccc-0000-0000-0000-000000000004', 1),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'cccccccc-0000-0000-0000-000000000002', 1);

insert into public.campaigns
  (id, pack_id, key, title, subtitle, intro_md, length_days, ramp_days, difficulty, sort)
values
  ('bbbbbbbb-0000-0000-0000-000000000004',
   'aaaaaaaa-0000-0000-0000-000000000002',
   'edge-fourteen', 'Fourteen', '[TO AUTHOR]', '[TO AUTHOR]', 14, 2, 3, 1),
  ('bbbbbbbb-0000-0000-0000-000000000005',
   'aaaaaaaa-0000-0000-0000-000000000002',
   'edge-twentyone', 'Twenty-One', '[TO AUTHOR]', '[TO AUTHOR]', 21, 3, 4, 2),
  ('bbbbbbbb-0000-0000-0000-000000000006',
   'aaaaaaaa-0000-0000-0000-000000000002',
   'edge-thirty', 'Thirty', '[TO AUTHOR]', '[TO AUTHOR]', 30, 4, 4, 3);

insert into public.campaign_archetypes (campaign_id, archetype_id, weight) values
  ('bbbbbbbb-0000-0000-0000-000000000004', 'cccccccc-0000-0000-0000-000000000001', 1),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'cccccccc-0000-0000-0000-000000000003', 1),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'cccccccc-0000-0000-0000-000000000004', 1);
