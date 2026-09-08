begin;
select plan(4);

-- The control that stops a client granting itself a pack. Plan 1 Task 10 gave
-- entitlements a select policy and no write policy; this asserts that is still
-- true, because a future migration adding one would be silent.

insert into auth.users (id, email)
  values ('11111111-1111-1111-1111-111111111111', 'a@example.com');
insert into public.profiles (user_id)
  values ('11111111-1111-1111-1111-111111111111');

set local role authenticated;
set local request.jwt.claims to
  '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select throws_ok(
  $$ insert into public.entitlements (user_id, pack_id, source)
     values ('11111111-1111-1111-1111-111111111111',
             (select id from public.packs where not is_core limit 1),
             'store') $$,
  '42501',
  null,
  'an authenticated user cannot grant themselves a pack'
);

select throws_ok(
  $$ update public.entitlements set source = 'grant' $$,
  '42501',
  null,
  'an authenticated user cannot update entitlements'
);

select throws_ok(
  $$ delete from public.entitlements $$,
  '42501',
  null,
  'an authenticated user cannot delete entitlements'
);

reset role;

-- And the service role, which the webhook uses, can.
insert into public.entitlements (user_id, pack_id, source)
values ('11111111-1111-1111-1111-111111111111',
        (select id from public.packs where not is_core limit 1),
        'store');

select is(
  (select count(*)::int from public.entitlements
    where user_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'the service role writes it, because the webhook must'
);

select * from finish();
rollback;
