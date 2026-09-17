begin;
select plan(6);

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

-- ADR-0040. A run ended for three consecutive absent days has an ending but no
-- result, so it carries a date and no grade. `grade_only_when_completed`
-- already enforces the second half, which is why no new constraint was added.
select lives_ok(
  $$ update public.campaign_runs
        set status = 'abandoned', abandoned_on = current_date
      where status = 'active' $$,
  'an abandoned run may carry the date it was abandoned on'
);

select throws_ok(
  $$ update public.campaign_runs
        set grade = 'passed'
      where abandoned_on is not null $$,
  '23514',
  null,
  'an abandoned run cannot carry a grade, however it ended'
);

-- `missed` is gone: an absent calendar day no longer maps to a day of content,
-- so there is no row for the product to write an outcome on.
select throws_ok(
  $$ insert into public.day_logs (user_id, run_id, day_index, outcome)
     select '11111111-1111-1111-1111-111111111111', id, 1, 'missed'
       from public.campaign_runs
      where user_id = '11111111-1111-1111-1111-111111111111'
      limit 1 $$,
  '23514',
  null,
  'missed is no longer an outcome the schema accepts'
);

select * from finish();
rollback;
