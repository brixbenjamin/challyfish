begin;
select plan(5);

-- Structural validation only. The safety floor in design spec section 9 cannot
-- be checked by a machine and is an authoring obligation (Q11).

select is_empty(
  $$ select c.key from public.campaigns c
     where (select count(*) from public.actions a where a.campaign_id = c.id)
           <> c.length_days $$,
  'every campaign has exactly length_days actions'
);

select is_empty(
  $$ select c.key from public.campaigns c
     where exists (
       select 1 from generate_series(1, c.length_days) g(day)
       where not exists (
         select 1 from public.actions a
         where a.campaign_id = c.id and a.day_index = g.day
       )
     ) $$,
  'every campaign has a contiguous day_index from 1 to length_days'
);

select is_empty(
  $$ select p.key from public.packs p
     where not p.is_core and p.store_product_id is null $$,
  'every non-core pack has a store product id'
);

select results_eq(
  $$ select count(*)::int from public.archetypes $$,
  array[4],
  'there are exactly four archetypes'
);

select results_eq(
  $$ select array_agg(key order by key) from public.archetypes $$,
  $$ select array['alchemist', 'creature', 'killer', 'psycho'] $$,
  'the four archetype keys are exactly the fixed set'
);

select * from finish();
rollback;
