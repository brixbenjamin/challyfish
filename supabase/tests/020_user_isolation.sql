begin;
select plan(4);

-- Two users, created directly in auth.users as the postgres role.
insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 'a@example.test'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.test');

insert into public.profiles (user_id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222');

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

select * from finish();
rollback;
