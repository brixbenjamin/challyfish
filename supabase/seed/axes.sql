-- Four archetypes, permanently (ADR-0004). The product uses the short names
-- Alchemist and Creature, never the source material's longer forms.
--
-- The four rows are the whole taxonomy. Nothing in the engine or the UI names
-- one of these keys; the names and blurbs below are the only place the words
-- exist (ADR-0021).
insert into public.archetypes (id, key, name, blurb, color, sort) values
  ('cccccccc-0000-0000-0000-000000000001', 'psycho', 'Psycho',
   'The irrational visionary. Absolute focus, unbothered by standard risk paradigms, social embarrassment, or logical limitations.',
   '#B23A48', 1),
  ('cccccccc-0000-0000-0000-000000000002', 'killer', 'Killer',
   'The acutely competent predator. Physical confidence and assertiveness; refusal to enter a subservient state of explaining oneself.',
   '#2E4057', 2),
  ('cccccccc-0000-0000-0000-000000000003', 'alchemist', 'Alchemist',
   'The intuitive action force. Immediate action on unearned confidence, turning error and chaos into progress.',
   '#C98C1E', 3),
  ('cccccccc-0000-0000-0000-000000000004', 'creature', 'Creature',
   'Primal desire. Raw drive without sterile guilt, social policing, or self-sabotaging shame.',
   '#4A7C59', 4);
