-- Placeholder actions. The real copy is written against the safety floor in
-- design spec section 9 and is not this plan's deliverable (Q2, Q11).
--
-- Every title and body_md is prefixed with [PLACEHOLDER] so the signal survives
-- a copy-paste that drops this header comment. Nothing here has been through the
-- safety-floor review in docs/product/content-review.md (ADR-0020); it must not
-- be mistaken for reviewed content.
insert into public.actions
  (campaign_id, day_index, title, body_md, archetype_id, effort)
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
   'cccccccc-0000-0000-0000-000000000002', 3);
