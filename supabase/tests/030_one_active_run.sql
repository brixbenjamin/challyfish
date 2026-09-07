begin;
select plan(3);

insert into auth.users (id, email)
values ('11111111-1111-1111-1111-111111111111', 'a@example.test');

-- A non-core pack, distinct from the real seed's content: this file only needs a
-- pack to attach two campaigns to, not the schema's single core-pack slot
-- (packs_single_core), which the real seed already permanently owns.
insert into public.packs (id, key, title, description, is_core, store_product_id, sort)
values ('aaaaaaaa-3333-3333-3333-333333333333', 'fixture-pack-030', 'Fixture Pack 030', 'd',
        false, 'com.feral.fixture.030', 1);

insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values
  ('bbbbbbbb-3333-3333-3333-333333333331',
   'aaaaaaaa-3333-3333-3333-333333333333', 'c1', 'One', 'i', 21, 1),
  ('bbbbbbbb-3333-3333-3333-333333333332',
   'aaaaaaaa-3333-3333-3333-333333333333', 'c2', 'Two', 'i', 21, 2);

insert into public.campaign_runs (user_id, campaign_id, status, started_at)
values ('11111111-1111-1111-1111-111111111111',
        'bbbbbbbb-3333-3333-3333-333333333331', 'active', now());

select throws_ok(
  $$ insert into public.campaign_runs (user_id, campaign_id, status, started_at)
     values ('11111111-1111-1111-1111-111111111111',
             'bbbbbbbb-3333-3333-3333-333333333332', 'active', now()) $$,
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
             'bbbbbbbb-3333-3333-3333-333333333332', 'active', now()) $$,
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
