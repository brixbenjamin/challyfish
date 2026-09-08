-- Eight forced-choice pairs (ADR-0009). All six archetype pairings appear, plus
-- two repeats (psycho/killer and alchemist/creature) chosen so that every
-- archetype appears in exactly four questions and wins/4 is comparable.
insert into public.diagnostic_questions (id, prompt, sort) values
  ('dddddddd-0000-0000-0000-000000000001', 'Closer to you?', 1),
  ('dddddddd-0000-0000-0000-000000000002', 'Closer to you?', 2),
  ('dddddddd-0000-0000-0000-000000000003', 'Closer to you?', 3),
  ('dddddddd-0000-0000-0000-000000000004', 'Closer to you?', 4),
  ('dddddddd-0000-0000-0000-000000000005', 'Closer to you?', 5),
  ('dddddddd-0000-0000-0000-000000000006', 'Closer to you?', 6),
  ('dddddddd-0000-0000-0000-000000000007', 'Closer to you?', 7),
  ('dddddddd-0000-0000-0000-000000000008', 'Closer to you?', 8);

insert into public.diagnostic_options (question_id, label, archetype_id, sort) values
  -- 1. psycho vs killer
  ('dddddddd-0000-0000-0000-000000000001', 'Commit to something before you can justify it',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000001', 'Say the thing nobody in the room will say',
   'cccccccc-0000-0000-0000-000000000002', 1),
  -- 2. psycho vs alchemist
  ('dddddddd-0000-0000-0000-000000000002', 'Hold a plan nobody else believes in',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000002', 'Start now and work it out on the way',
   'cccccccc-0000-0000-0000-000000000003', 1),
  -- 3. psycho vs creature
  ('dddddddd-0000-0000-0000-000000000003', 'Ignore how it looks to other people',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000003', 'Want what you want without apologising for it',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 4. killer vs alchemist
  ('dddddddd-0000-0000-0000-000000000004', 'End a conversation instead of explaining again',
   'cccccccc-0000-0000-0000-000000000002', 0),
  ('dddddddd-0000-0000-0000-000000000004', 'Make the first move with half the information',
   'cccccccc-0000-0000-0000-000000000003', 1),
  -- 5. killer vs creature
  ('dddddddd-0000-0000-0000-000000000005', 'Hold your ground when someone pushes',
   'cccccccc-0000-0000-0000-000000000002', 0),
  ('dddddddd-0000-0000-0000-000000000005', 'Admit plainly what you actually want',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 6. alchemist vs creature
  ('dddddddd-0000-0000-0000-000000000006', 'Improvise when the plan falls apart',
   'cccccccc-0000-0000-0000-000000000003', 0),
  ('dddddddd-0000-0000-0000-000000000006', 'Follow an appetite you cannot fully defend',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 7. psycho vs killer (repeat, for balance)
  ('dddddddd-0000-0000-0000-000000000007', 'Bet on an idea everyone calls unrealistic',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000007', 'Refuse a request without softening it',
   'cccccccc-0000-0000-0000-000000000002', 1),
  -- 8. alchemist vs creature (repeat, for balance)
  ('dddddddd-0000-0000-0000-000000000008', 'Act on instinct and correct afterwards',
   'cccccccc-0000-0000-0000-000000000003', 0),
  ('dddddddd-0000-0000-0000-000000000008', 'Say out loud what you are drawn to',
   'cccccccc-0000-0000-0000-000000000004', 1);
