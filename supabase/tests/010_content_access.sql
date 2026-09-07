begin;
select plan(6);

-- A known fixture row, inserted as the default (superuser, RLS-bypassing) role,
-- so both client roles below are proven to actually see it — not merely to avoid
-- erroring on an empty/absent result.
insert into public.packs (id, key, title, description, is_core, store_product_id, sort)
values ('aaaaaaaa-1111-1111-1111-111111111111', 'fixture-pack', 'Fixture Pack', 'd',
        false, 'com.feral.fixture', 1);

-- An anonymous visitor can read content. Teasers are public by design.
set local role anon;
select results_eq(
  $$ select key from public.packs where id = 'aaaaaaaa-1111-1111-1111-111111111111' $$,
  array['fixture-pack'],
  'anon can see a known pack row'
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
