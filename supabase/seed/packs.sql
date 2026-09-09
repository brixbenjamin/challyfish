insert into public.packs (id, key, title, description, is_core, sort) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'core', 'The Core',
   'Where everyone starts. Free, forever.', true, 1);

-- The one paid pack (ADR-0018). The product id is a placeholder until Q1 (the
-- product name) closes and the real bundle id exists; plan 4 Task 15 replaces
-- it, and it must match App Store Connect, Play Console and RevenueCat exactly.
insert into public.packs
  (id, key, title, description, is_core, store_product_id, sort)
values
  ('aaaaaaaa-0000-0000-0000-000000000002', 'edge', 'The Edge',
   '[TO AUTHOR]', false, 'pack.edge', 2);
