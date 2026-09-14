begin;
select plan(12);

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

-- No body: the copy lives in public.action_bodies now (ADR-0025), and nothing
-- below reads it. day_logs references the action, not its body.
--
-- The action hangs off a day row since ADR-0034; it no longer carries its own
-- campaign or day number.
insert into public.days (id, campaign_id, day_index, title)
values ('dddddddd-9999-0000-0000-000000000001',
        'bbbbbbbb-2222-2222-2222-222222222222', 1, 'Day one');

insert into public.actions (id, day_id, title)
values ('dddddddd-0000-0000-0000-000000000001',
        'dddddddd-9999-0000-0000-000000000001', 'Do the thing');

-- The archetype is a join row since 0007. One row at share 1 is the ordinary
-- single-drive action, which is all this fixture needs.
insert into public.action_archetypes (action_id, archetype_id, share)
values ('dddddddd-0000-0000-0000-000000000001',
        'cccccccc-2222-2222-2222-222222222222', 1);

-- User B's own rows in the tables the spec names explicitly. The run id is
-- spelled out rather than sub-selected because the write assertions below run
-- as user A, who cannot see user B's run to look it up -- a null run_id would
-- raise a not-null violation and the test would pass for the wrong reason.
insert into public.campaign_runs (id, user_id, campaign_id, status, started_at)
values ('33333333-3333-3333-3333-333333333333',
        '22222222-2222-2222-2222-222222222222',
        'bbbbbbbb-2222-2222-2222-222222222222', 'active', now());

insert into public.day_logs (user_id, run_id, day_index, action_id)
values ('22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333',
        1, 'dddddddd-0000-0000-0000-000000000001');

-- A tick of user B's, so the read assertion below is answering "RLS hid it"
-- rather than "the table happened to be empty".
insert into public.day_log_actions (user_id, run_id, day_index, action_id)
values ('22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333',
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

-- day_log_actions is owner-scoped like every other user table (ADR-0030). The
-- ticks say which specific acts a user performed, so this is the same privacy
-- guarantee as day_logs and not a lesser one.
select results_eq(
  $$ select count(*)::int from public.day_log_actions
     where user_id = '22222222-2222-2222-2222-222222222222' $$,
  array[0],
  'user A cannot read user B''s ticks'
);

-- Every foreign key here resolves, so a 42501 can only have come from the RLS
-- with-check predicate rather than from a dangling reference.
select throws_ok(
  $$ insert into public.day_log_actions (user_id, run_id, day_index, action_id)
     values ('22222222-2222-2222-2222-222222222222',
             '33333333-3333-3333-3333-333333333333', 1,
             'dddddddd-0000-0000-0000-000000000001') $$,
  '42501',
  null,
  'user A cannot write a tick for another user'
);

select * from finish();
rollback;
