begin;
select plan(3);

insert into auth.users (id, email)
values ('11111111-1111-1111-1111-111111111111', 'a@example.test');

insert into public.packs (id, key, title, description, is_core, sort)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'core', 'Core', 'd', true, 1);

insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values
  ('bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001', 'c1', 'One', 'i', 21, 1),
  ('bbbbbbbb-0000-0000-0000-000000000002',
   'aaaaaaaa-0000-0000-0000-000000000001', 'c2', 'Two', 'i', 21, 2);

insert into public.campaign_runs (user_id, campaign_id, status, started_at)
values ('11111111-1111-1111-1111-111111111111',
        'bbbbbbbb-0000-0000-0000-000000000001', 'active', now());

select throws_ok(
  $$ insert into public.campaign_runs (user_id, campaign_id, status, started_at)
     values ('11111111-1111-1111-1111-111111111111',
             'bbbbbbbb-0000-0000-0000-000000000002', 'active', now()) $$,
  '23505',
  null,
  'a second active run for the same user is rejected'
);

-- Abandoning the first frees the slot. Nothing is ever deleted (ADR-0003).
update public.campaign_runs set status = 'abandoned'
where user_id = '11111111-1111-1111-1111-111111111111';

select lives_ok(
  $$ insert into public.campaign_runs (user_id, campaign_id, status, started_at)
     values ('11111111-1111-1111-1111-111111111111',
             'bbbbbbbb-0000-0000-0000-000000000002', 'active', now()) $$,
  'a new run may start once the previous one is abandoned'
);

select throws_ok(
  $$ update public.campaign_runs set grade = 'sovereign' where status = 'active' $$,
  '23514',
  null,
  'an active run cannot carry a grade'
);

select * from finish();
rollback;
