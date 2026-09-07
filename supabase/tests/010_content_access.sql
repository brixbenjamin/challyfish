begin;
select plan(3);

-- An anonymous visitor can read content. Teasers are public by design.
set local role anon;
select lives_ok(
  $$ select count(*) from public.packs $$,
  'anon can read packs'
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

select * from finish();
rollback;
