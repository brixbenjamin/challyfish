begin;
select plan(10);

-- Two users, created directly in auth.users as the postgres role.
insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 'a@example.test'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.test');

insert into public.profiles (user_id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222');

-- Minimal content fixtures so user B can hold a run, a day log, and an
-- entitlement. Inserted as the default (superuser, RLS-bypassing) role.
insert into public.archetypes (id, key, name, blurb, color, sort)
values ('cccccccc-2222-2222-2222-222222222222', 'arch1', 'Archetype One', 'b', '#fff', 1);

-- A non-core pack, distinct from the real seed's content: this file only needs a
-- pack to attach a campaign to, not the schema's single core-pack slot
-- (packs_single_core), which the real seed already permanently owns.
insert into public.packs (id, key, title, description, is_core, store_product_id, sort)
values ('aaaaaaaa-2222-2222-2222-222222222222', 'fixture-pack-020', 'Fixture Pack 020', 'd',
        false, 'com.feral.fixture.020', 1);

insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values ('bbbbbbbb-2222-2222-2222-222222222222',
        'aaaaaaaa-2222-2222-2222-222222222222', 'c1', 'One', 'i', 21, 1);

insert into public.actions (id, campaign_id, day_index, title, body_md, archetype_id)
values ('dddddddd-0000-0000-0000-000000000001',
        'bbbbbbbb-2222-2222-2222-222222222222', 1, 'Do the thing', 'b',
        'cccccccc-2222-2222-2222-222222222222');

-- User B's own rows in the three tables the spec names explicitly.
insert into public.campaign_runs (user_id, campaign_id, status, started_at)
values ('22222222-2222-2222-2222-222222222222',
        'bbbbbbbb-2222-2222-2222-222222222222', 'active', now());

insert into public.day_logs (user_id, run_id, day_index, action_id)
values ('22222222-2222-2222-2222-222222222222',
        (select id from public.campaign_runs
           where user_id = '22222222-2222-2222-2222-222222222222'),
        1, 'dddddddd-0000-0000-0000-000000000001');

insert into public.entitlements (user_id, pack_id, source)
values ('22222222-2222-2222-2222-222222222222',
        'aaaaaaaa-2222-2222-2222-222222222222', 'fixture');

-- Act as user A.
set local role authenticated;
set local "request.jwt.claims" to
  '{"sub": "11111111-1111-1111-1111-111111111111", "role": "authenticated"}';

select results_eq(
  $$ select count(*)::int from public.profiles $$,
  array[1],
  'user A sees exactly one profile — their own'
);

select results_eq(
  $$ select count(*)::int from public.profiles
     where user_id = '22222222-2222-2222-2222-222222222222' $$,
  array[0],
  'user A cannot read user B''s profile'
);

select throws_ok(
  $$ insert into public.profiles (user_id)
     values ('33333333-3333-3333-3333-333333333333') $$,
  '42501',
  null,
  'user A cannot create a profile for someone else'
);

select results_eq(
  $$ with attempt as (
       update public.profiles set display_name = 'pwned'
       where user_id = '22222222-2222-2222-2222-222222222222'
       returning 1
     ) select count(*)::int from attempt $$,
  array[0],
  'user A''s update of user B''s profile affects no rows'
);

-- campaign_runs
select results_eq(
  $$ select count(*)::int from public.campaign_runs
     where user_id = '22222222-2222-2222-2222-222222222222' $$,
  array[0],
  'user A cannot read user B''s campaign run'
);

select results_eq(
  $$ with attempt as (
       update public.campaign_runs set status = 'abandoned'
       where user_id = '22222222-2222-2222-2222-222222222222'
       returning 1
     ) select count(*)::int from attempt $$,
  array[0],
  'user A''s update of user B''s campaign run affects no rows'
);

-- day_logs
select results_eq(
  $$ select count(*)::int from public.day_logs
     where user_id = '22222222-2222-2222-2222-222222222222' $$,
  array[0],
  'user A cannot read user B''s day log'
);

select results_eq(
  $$ with attempt as (
       update public.day_logs set note = 'pwned'
       where user_id = '22222222-2222-2222-2222-222222222222'
       returning 1
     ) select count(*)::int from attempt $$,
  array[0],
  'user A''s update of user B''s day log affects no rows'
);

-- entitlements: no owner-generator loop covers this table (hand-written policy),
-- and it is the one where a mistake means a client granting itself paid content.
select results_eq(
  $$ select count(*)::int from public.entitlements
     where user_id = '22222222-2222-2222-2222-222222222222' $$,
  array[0],
  'user A cannot read user B''s entitlement'
);

select throws_ok(
  $$ insert into public.entitlements (user_id, pack_id, source)
     values ('11111111-1111-1111-1111-111111111111',
             'aaaaaaaa-2222-2222-2222-222222222222', 'self-granted') $$,
  '42501',
  null,
  'user A cannot insert an entitlement at all, even for themself'
);

select * from finish();
rollback;
