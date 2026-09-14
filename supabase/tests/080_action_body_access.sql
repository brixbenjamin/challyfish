begin;
select plan(7);

-- Fixture campaigns hang off the two seeded packs rather than inserting packs of
-- their own: packs_single_core (0001) permits exactly one core pack forever, so a
-- fixture core pack cannot exist. Ids are prefixed dddddddd- so they cannot
-- collide with anything in supabase/seed/. Everything below is inserted as the
-- default superuser role, which bypasses RLS, so every assertion proves a policy
-- decision rather than an empty table.
insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values ('dddddddd-0000-0000-0000-000000000001',
        (select id from public.packs where is_core),
        'fixture-free-camp', 'Free', 'i', 3, 901),
       ('dddddddd-0000-0000-0000-000000000002',
        (select id from public.packs where not is_core order by sort limit 1),
        'fixture-paid-camp', 'Paid', 'i', 3, 902);

insert into public.actions (id, campaign_id, day_index, title, effort)
values ('dddddddd-1111-0000-0000-000000000001', 'dddddddd-0000-0000-0000-000000000001',
        1, 'Free day one', 1),
       ('dddddddd-1111-0000-0000-000000000002', 'dddddddd-0000-0000-0000-000000000002',
        1, 'Paid day one', 1);

insert into public.action_archetypes (action_id, archetype_id, share)
values ('dddddddd-1111-0000-0000-000000000001',
        (select id from public.archetypes order by sort limit 1), 1),
       ('dddddddd-1111-0000-0000-000000000002',
        (select id from public.archetypes order by sort limit 1), 1);

insert into public.action_bodies (action_id, body_md)
values ('dddddddd-1111-0000-0000-000000000001', 'FREE BODY'),
       ('dddddddd-1111-0000-0000-000000000002', 'PAID BODY');

insert into auth.users (id, email)
values ('11111111-0000-0000-0000-000000000001', 'nobody@example.com'),
       ('11111111-0000-0000-0000-000000000002', 'buyer@example.com');
insert into public.profiles (user_id)
values ('11111111-0000-0000-0000-000000000001'),
       ('11111111-0000-0000-0000-000000000002');

insert into public.entitlements (user_id, pack_id, source)
values ('11111111-0000-0000-0000-000000000002',
        (select id from public.packs where not is_core order by sort limit 1), 'store');

-- 1, 2. A visitor with no session reads the free pack and not the paid one.
set local role anon;
select results_eq(
  $$ select body_md from public.action_bodies
      where action_id = 'dddddddd-1111-0000-0000-000000000001' $$,
  array['FREE BODY'],
  'anon reads a core-pack body'
);
select is_empty(
  $$ select body_md from public.action_bodies
      where action_id = 'dddddddd-1111-0000-0000-000000000002' $$,
  'anon cannot read a paid body'
);

-- 3, 4. A signed-in user who has bought nothing gets the same answer. Anonymous
-- Supabase sessions carry the authenticated role (ADR-0007), so this is the path
-- most real traffic takes and it must be exercised separately from anon.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"11111111-0000-0000-0000-000000000001","role":"authenticated"}';
select results_eq(
  $$ select body_md from public.action_bodies
      where action_id = 'dddddddd-1111-0000-0000-000000000001' $$,
  array['FREE BODY'],
  'an unentitled user reads a core-pack body'
);
select is_empty(
  $$ select body_md from public.action_bodies
      where action_id = 'dddddddd-1111-0000-0000-000000000002' $$,
  'an unentitled user cannot read a paid body'
);

-- 5. The buyer can.
set local request.jwt.claims to
  '{"sub":"11111111-0000-0000-0000-000000000002","role":"authenticated"}';
select results_eq(
  $$ select body_md from public.action_bodies
      where action_id = 'dddddddd-1111-0000-0000-000000000002' $$,
  array['PAID BODY'],
  'an entitled user reads the paid body'
);

-- 6. Content is read-only to the client, as every content table is. A client that
-- could write this table could author its own pack.
select throws_ok(
  $$ update public.action_bodies set body_md = 'tampered' $$,
  '42501',
  null,
  'an authenticated user cannot write action_bodies'
);

-- 7. The teaser survives the split. A locked action is still browsable: the row
-- is there, the title is readable, and only the body is withheld.
select results_eq(
  $$ select title from public.actions
      where id = 'dddddddd-1111-0000-0000-000000000002' $$,
  array['Paid day one'],
  'a locked action is still browsable by title'
);

select * from finish();
rollback;
