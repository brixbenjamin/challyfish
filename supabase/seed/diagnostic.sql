-- Eight forced-choice pairs (ADR-0009). All six archetype pairings appear, plus
-- two repeats (psycho/killer and trickster/beast) chosen so that every
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

-- Ids derived from (question_id, sort) for the reason spelled out at the top of
-- actions.sql: this table is keyed on id but separately unique on
-- (question_id, sort), so an id that changes between one `db reset` and the
-- next arrives at a device as a duplicate rather than as an update, and the
-- content pull cannot get past it.
insert into public.diagnostic_options (id, question_id, label, archetype_id, sort)
select
  md5('feral:diagnostic_option:' || v.question_id || ':' || v.sort)::uuid,
  v.question_id::uuid,
  v.label,
  v.archetype_id::uuid,
  v.sort
from (
  values
  -- 1. psycho vs killer
  ('dddddddd-0000-0000-0000-000000000001', 'Commit to something before you can justify it',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000001', 'Say the thing nobody in the room will say',
   'cccccccc-0000-0000-0000-000000000002', 1),
  -- 2. psycho vs trickster
  ('dddddddd-0000-0000-0000-000000000002', 'Hold a plan nobody else believes in',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000002', 'Start now and work it out on the way',
   'cccccccc-0000-0000-0000-000000000003', 1),
  -- 3. psycho vs beast
  ('dddddddd-0000-0000-0000-000000000003', 'Ignore how it looks to other people',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000003', 'Want what you want without apologising for it',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 4. killer vs trickster
  ('dddddddd-0000-0000-0000-000000000004', 'End a conversation instead of explaining again',
   'cccccccc-0000-0000-0000-000000000002', 0),
  ('dddddddd-0000-0000-0000-000000000004', 'Make the first move with half the information',
   'cccccccc-0000-0000-0000-000000000003', 1),
  -- 5. killer vs beast
  ('dddddddd-0000-0000-0000-000000000005', 'Hold your ground when someone pushes',
   'cccccccc-0000-0000-0000-000000000002', 0),
  ('dddddddd-0000-0000-0000-000000000005', 'Admit plainly what you actually want',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 6. trickster vs beast
  ('dddddddd-0000-0000-0000-000000000006', 'Improvise when the plan falls apart',
   'cccccccc-0000-0000-0000-000000000003', 0),
  ('dddddddd-0000-0000-0000-000000000006', 'Follow an appetite you cannot fully defend',
   'cccccccc-0000-0000-0000-000000000004', 1),
  -- 7. psycho vs killer (repeat, for balance)
  ('dddddddd-0000-0000-0000-000000000007', 'Bet on an idea everyone calls unrealistic',
   'cccccccc-0000-0000-0000-000000000001', 0),
  ('dddddddd-0000-0000-0000-000000000007', 'Refuse a request without softening it',
   'cccccccc-0000-0000-0000-000000000002', 1),
  -- 8. trickster vs beast (repeat, for balance)
  ('dddddddd-0000-0000-0000-000000000008', 'Act on instinct and correct afterwards',
   'cccccccc-0000-0000-0000-000000000003', 0),
  ('dddddddd-0000-0000-0000-000000000008', 'Say out loud what you are drawn to',
   'cccccccc-0000-0000-0000-000000000004', 1)
) as v(question_id, label, archetype_id, sort);
