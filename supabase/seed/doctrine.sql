insert into public.doctrine_groups (id, title, blurb, sort) values
  ('eeeeeeee-0000-0000-0000-000000000001', 'The Zoo',
   'The enclosure you did not choose.', 1),
  ('eeeeeeee-0000-0000-0000-000000000002', 'Thumos',
   'The spirited part, and what it is for.', 2);

insert into public.doctrine_entries (id, group_id, title, body_md, related_archetype_id, sort)
values
  ('ffffffff-0000-0000-0000-000000000001',
   'eeeeeeee-0000-0000-0000-000000000001',
   'The Domesticated State',
   'Safety, predictability and a single-file path, traded for the ability to choose your own. Nobody forced it on you. That is what makes it hard to see.',
   null, 1),
  ('ffffffff-0000-0000-0000-000000000002',
   'eeeeeeee-0000-0000-0000-000000000001',
   'Thought Corruption',
   'Reading about it is not doing it. Collecting one more framework is the most comfortable way to avoid acting, because it feels like progress.',
   null, 2),
  ('ffffffff-0000-0000-0000-000000000003',
   'eeeeeeee-0000-0000-0000-000000000002',
   'Thumos',
   'The drive to be seen, to assert, to leave a mark on the physical world. Not willpower and not grit — both of those lose the half about being seen.',
   null, 1);
