-- Placeholder actions. The real copy is written against the safety floor in
-- design spec section 9 and is not this plan's deliverable (Q2, Q11).
insert into public.actions
  (campaign_id, day_index, title, body_md, archetype_id, effort)
values
  ('bbbbbbbb-0000-0000-0000-000000000001', 1, 'State a preference out loud',
   'Once today, when someone asks what you want, answer immediately and do not soften it.',
   'cccccccc-0000-0000-0000-000000000002', 1),
  ('bbbbbbbb-0000-0000-0000-000000000001', 2, 'Ask for something small',
   'Ask one person for one thing you would normally not bother asking for.',
   'cccccccc-0000-0000-0000-000000000002', 1),
  ('bbbbbbbb-0000-0000-0000-000000000001', 3, 'Do not explain yourself',
   'Say no once today, and stop talking after you have said it.',
   'cccccccc-0000-0000-0000-000000000002', 2),
  ('bbbbbbbb-0000-0000-0000-000000000001', 4, 'Go first',
   'In one conversation today, be the first to speak.',
   'cccccccc-0000-0000-0000-000000000002', 2),
  ('bbbbbbbb-0000-0000-0000-000000000001', 5, 'Disagree in the room',
   'Say the disagreeing thing once, while the subject is still open.',
   'cccccccc-0000-0000-0000-000000000002', 3),
  ('bbbbbbbb-0000-0000-0000-000000000001', 6, 'Take the harder option',
   'Where two options exist today and one is easier, take the other.',
   'cccccccc-0000-0000-0000-000000000002', 3),
  ('bbbbbbbb-0000-0000-0000-000000000001', 7, 'Say the thing you have been not saying',
   'You already know what it is. Say it to the person it concerns.',
   'cccccccc-0000-0000-0000-000000000002', 3);
