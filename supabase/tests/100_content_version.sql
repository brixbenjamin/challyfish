begin;
select plan(4);

-- Snapshots of the counter, taken between writes. A temporary table rather than
-- expressions inline, because each assertion needs to compare the value before
-- a write with the value after it, and the write has to have already happened.
create temporary table seen (label text primary key, value bigint);

select is(
  (select count(*)::int from public.content_version),
  1,
  'content_version holds exactly one row'
);

insert into seen values ('start', (select version from public.content_version));

insert into public.packs
  (id, key, title, description, is_core, store_product_id, sort)
values
  ('aaaaaaaa-9999-9999-9999-999999999999', 'fixture-pack-100',
   'Fixture Pack 100', 'd', false, 'com.feral.fixture.100', 1);

insert into seen values ('inserted', (select version from public.content_version));

update public.packs
   set title = 'Renamed'
 where id = 'aaaaaaaa-9999-9999-9999-999999999999';

insert into seen values ('updated', (select version from public.content_version));

delete from public.packs
 where id = 'aaaaaaaa-9999-9999-9999-999999999999';

insert into seen values ('deleted', (select version from public.content_version));

select cmp_ok(
  (select value from seen where label = 'inserted'), '>',
  (select value from seen where label = 'start'),
  'an insert raises the content version'
);

select cmp_ok(
  (select value from seen where label = 'updated'), '>',
  (select value from seen where label = 'inserted'),
  'an update raises the content version'
);

-- The one that matters, and the reason this table exists at all: a deleted row
-- carries no newer updated_at, so nothing else in the schema can tell a client
-- that it is gone.
select cmp_ok(
  (select value from seen where label = 'deleted'), '>',
  (select value from seen where label = 'updated'),
  'a delete raises the content version'
);

select * from finish();
rollback;
