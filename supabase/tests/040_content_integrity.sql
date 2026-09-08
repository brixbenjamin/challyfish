begin;
select plan(11);

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


-- Library shape, per ADR-0018. These are launch requirements, not style: the
-- radar in the dashboard is meaningless if the free library only exercises two
-- archetypes.

select results_eq(
  $$ select count(*)::int from public.packs where is_core $$,
  array[1],
  'there is exactly one core pack'
);

select results_eq(
  $$ select count(*)::int from public.campaigns c
     join public.packs p on p.id = c.pack_id
     where p.is_core $$,
  array[3],
  'the core pack has three campaigns (ADR-0018)'
);

select results_eq(
  $$ select array_agg(c.length_days order by c.length_days)
       from public.campaigns c
       join public.packs p on p.id = c.pack_id
      where p.is_core $$,
  $$ select array[7, 21, 30] $$,
  'the core campaigns are 7, 21 and 30 days'
);

select results_eq(
  $$ select count(distinct ca.archetype_id)::int
       from public.campaign_archetypes ca
       join public.campaigns c on c.id = ca.campaign_id
       join public.packs p on p.id = c.pack_id
      where p.is_core $$,
  array[4],
  'the free library targets all four archetypes between its three campaigns'
);

select results_eq(
  $$ select count(*)::int from public.campaigns c
     join public.packs p on p.id = c.pack_id
     where not p.is_core $$,
  array[3],
  'the paid pack has three campaigns (ADR-0018)'
);

-- ADR-0019: one product per pack. Two packs on one product id would pay one
-- purchase into two entitlements.
select is_empty(
  $$ select store_product_id from public.packs
      where store_product_id is not null
      group by store_product_id having count(*) > 1 $$,
  'no two packs share a store product id'
);

select * from finish();
rollback;
