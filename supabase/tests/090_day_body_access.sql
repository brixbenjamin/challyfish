begin;
select plan(7);

-- Fixture campaigns hang off the two seeded packs rather than inserting packs of
-- their own: packs_single_core (0001) permits exactly one core pack forever, so a
-- fixture core pack cannot exist. Ids are prefixed eeeeeeee- so they cannot
-- collide with 080's dddddddd- fixtures or with anything in supabase/seed/.
-- Everything below is inserted as the default superuser role, which bypasses
-- RLS, so every assertion proves a policy decision rather than an empty table.
insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values ('eeeeeeee-0000-0000-0000-000000000001',
        (select id from public.packs where is_core),
        'fixture-free-daycamp', 'Free', 'i', 3, 903),
       ('eeeeeeee-0000-0000-0000-000000000002',
        (select id from public.packs where not is_core order by sort limit 1),
        'fixture-paid-daycamp', 'Paid', 'i', 3, 904);

insert into public.days (id, campaign_id, day_index, title)
values ('eeeeeeee-1111-0000-0000-000000000001',
        'eeeeeeee-0000-0000-0000-000000000001', 1, 'Free day one'),
       ('eeeeeeee-1111-0000-0000-000000000002',
        'eeeeeeee-0000-0000-0000-000000000002', 1, 'Paid day one');

insert into public.day_bodies (day_id, body_md)
values ('eeeeeeee-1111-0000-0000-000000000001', 'FREE DAY BODY'),
       ('eeeeeeee-1111-0000-0000-000000000002', 'PAID DAY BODY');

insert into auth.users (id, email)
values ('11111111-0000-0000-0000-000000000003', 'nobody-day@example.com'),
       ('11111111-0000-0000-0000-000000000004', 'buyer-day@example.com');
insert into public.profiles (user_id)
values ('11111111-0000-0000-0000-000000000003'),
       ('11111111-0000-0000-0000-000000000004');

insert into public.entitlements (user_id, pack_id, source)
values ('11111111-0000-0000-0000-000000000004',
        (select id from public.packs where not is_core order by sort limit 1), 'store');

-- 1, 2. A visitor with no session reads the free pack and not the paid one.
set local role anon;
select results_eq(
  $$ select body_md from public.day_bodies
      where day_id = 'eeeeeeee-1111-0000-0000-000000000001' $$,
  array['FREE DAY BODY'],
  'anon reads a core-pack day body'
);
select is_empty(
  $$ select body_md from public.day_bodies
      where day_id = 'eeeeeeee-1111-0000-0000-000000000002' $$,
  'anon cannot read a paid day body'
);

-- 3, 4. A signed-in user who has bought nothing gets the same answer. Anonymous
-- Supabase sessions carry the authenticated role (ADR-0007), so this is the path
-- most real traffic takes and it must be exercised separately from anon.
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"11111111-0000-0000-0000-000000000003","role":"authenticated"}';
select results_eq(
  $$ select body_md from public.day_bodies
      where day_id = 'eeeeeeee-1111-0000-0000-000000000001' $$,
  array['FREE DAY BODY'],
  'an unentitled user reads a core-pack day body'
);
select is_empty(
  $$ select body_md from public.day_bodies
      where day_id = 'eeeeeeee-1111-0000-0000-000000000002' $$,
  'an unentitled user cannot read a paid day body'
);

-- 5. The buyer can.
set local request.jwt.claims to
  '{"sub":"11111111-0000-0000-0000-000000000004","role":"authenticated"}';
select results_eq(
  $$ select body_md from public.day_bodies
      where day_id = 'eeeeeeee-1111-0000-0000-000000000002' $$,
  array['PAID DAY BODY'],
  'an entitled user reads the paid day body'
);

-- 6. Content is read-only to the client, as every content table is. A client that
-- could write this table could author its own pack.
select throws_ok(
  $$ update public.day_bodies set body_md = 'tampered' $$,
  '42501',
  null,
  'an authenticated user cannot write day_bodies'
);

-- 7. The teaser survives the split. A locked day is still browsable: the row is
-- there, the title is readable, and only the body is withheld. This is the
-- property that makes a locked pack browsable at day granularity (Q16).
select results_eq(
  $$ select title from public.days
      where id = 'eeeeeeee-1111-0000-0000-000000000002' $$,
  array['Paid day one'],
  'a locked day is still browsable by title'
);

select * from finish();
rollback;
