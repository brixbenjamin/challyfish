begin;
select plan(8);

-- A known fixture row, inserted as the default (superuser, RLS-bypassing) role,
-- so both client roles below are proven to actually see it — not merely to avoid
-- erroring on an empty/absent result.
insert into public.packs (id, key, title, description, is_core, store_product_id, sort)
values ('aaaaaaaa-1111-1111-1111-111111111111', 'fixture-pack', 'Fixture Pack', 'd',
        false, 'com.feral.fixture', 1);

-- A day on a paid pack, so the teaser/body split can be asserted in one place:
-- the title is public, the body is not.
insert into public.campaigns (id, pack_id, key, title, intro_md, length_days, sort)
values ('aaaaaaaa-1111-1111-1111-111111111112',
        'aaaaaaaa-1111-1111-1111-111111111111',
        'fixture-camp', 'Fixture Campaign', 'i', 1, 1);

insert into public.days (id, campaign_id, day_index, title)
values ('aaaaaaaa-1111-1111-1111-111111111113',
        'aaaaaaaa-1111-1111-1111-111111111112', 1, 'Fixture Day');

insert into public.day_bodies (day_id, body_md)
values ('aaaaaaaa-1111-1111-1111-111111111113', 'FIXTURE DAY BODY');

-- An anonymous visitor can read content. Teasers are public by design.
set local role anon;
select results_eq(
  $$ select key from public.packs where id = 'aaaaaaaa-1111-1111-1111-111111111111' $$,
  array['fixture-pack'],
  'anon can see a known pack row'
);

select results_eq(
  $$ select title from public.days
      where id = 'aaaaaaaa-1111-1111-1111-111111111113' $$,
  array['Fixture Day'],
  'anon can read a day title -- days are teaser data'
);

select is_empty(
  $$ select body_md from public.day_bodies
      where day_id = 'aaaaaaaa-1111-1111-1111-111111111113' $$,
  'anon cannot read a paid day body -- day_bodies is not in the teaser loop'
);

-- ...and cannot write it.
select throws_ok(
  $$ insert into public.packs (key, title, description, is_core, sort)
     values ('hax', 'Hax', 'd', true, 99) $$,
  '42501',
  null,
  'anon cannot insert packs'
);

select throws_ok(
  $$ update public.actions set title = 'tampered' $$,
  '42501',
  null,
  'anon cannot update actions'
);

-- Anonymous Supabase sessions carry the `authenticated` role (ADR-0007), so the
-- path most real traffic actually takes must be exercised too, not just `anon`.
set local role authenticated;
select results_eq(
  $$ select key from public.packs where id = 'aaaaaaaa-1111-1111-1111-111111111111' $$,
  array['fixture-pack'],
  'authenticated can see a known pack row'
);

select throws_ok(
  $$ insert into public.packs (key, title, description, is_core, sort)
     values ('hax-auth', 'Hax Auth', 'd', true, 98) $$,
  '42501',
  null,
  'authenticated cannot insert packs'
);

select throws_ok(
  $$ update public.actions set title = 'tampered-auth' $$,
  '42501',
  null,
  'authenticated cannot update actions'
);

select * from finish();
rollback;
