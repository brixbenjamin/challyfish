begin;
select plan(20);

-- Structural validation only. The safety floor in design spec section 9 cannot
-- be checked by a machine and is an authoring obligation (Q11).

-- Exactly one mandatory action per day (ADR-0030), asserted against day_id now
-- that the day is a row. The count is of mandatory rows only: optionals are
-- authored freely on top and must not make a well-formed campaign look malformed.
select is_empty(
  $$ select d.id from public.days d
     where (select count(*) from public.actions a
            where a.day_id = d.id and not a.is_optional) <> 1 $$,
  'every day has exactly one mandatory action'
);

-- An optional action on a day with no mandatory one is an orphan: the grade
-- would have nothing to depend on and the day could never resolve to `done`.
select is_empty(
  $$ select a.id from public.actions a
     where a.is_optional
       and not exists (
         select 1 from public.actions m
         where m.day_id = a.day_id and not m.is_optional) $$,
  'no optional action sits on a day without a mandatory one'
);

-- Contiguity, previously unenforceable: before ADR-0034 there was no row to
-- constrain, and docs/technical/data-model.md asserted this on trust.
select is_empty(
  $$ select c.key from public.campaigns c
     where exists (
       select 1 from generate_series(1, c.length_days) g(day)
       where not exists (
         select 1 from public.days d
         where d.campaign_id = c.id and d.day_index = g.day
       )
     ) $$,
  'every campaign has a contiguous day_index from 1 to length_days'
);

-- The other half of the same invariant. Contiguity alone permits a 21-day
-- campaign carrying 30 days; campaigns.length_days stays authoritative.
select is_empty(
  $$ select c.key from public.campaigns c
     where (select count(*) from public.days d where d.campaign_id = c.id)
           <> c.length_days $$,
  'every campaign has exactly length_days days'
);

-- Every day is readable. A day with no body is a day the user cannot decide to
-- commit to, which is the whole point of the body existing (ADR-0034).
select is_empty(
  $$ select d.id from public.days d
      left join public.day_bodies b on b.day_id = d.id
      where b.day_id is null $$,
  'every day has a body'
);

-- The gate that stops unauthored copy shipping must still see it, exactly as
-- it must for action bodies. If this passes while placeholders are present,
-- the gate has stopped looking rather than the copy having been written.
select isnt_empty(
  $$ select b.day_id from public.day_bodies b
      where b.body_md like '%[TO AUTHOR]%' or b.body_md like '%[PLACEHOLDER]%' $$,
  'placeholder day bodies are still visible to an unauthored-copy check'
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
  -- Alphabetical, because the query above aggregates `order by key`. The
  -- pre-rename keys were alphabetical by luck, so this literal could be written
  -- in conceptual order and still pass; renaming to trickster and beast broke
  -- that coincidence.
  $$ select array['beast', 'killer', 'psycho', 'trickster'] $$,
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

-- 0007: an action's archetypes are a join table, so the invariants the dropped
-- not-null column carried for free are checked here as well as by the deferred
-- constraint trigger. The trigger catches a write; this catches a library that
-- was assembled correctly one row at a time and is still wrong as a whole.
select is_empty(
  $$ select a.id from public.actions a
      left join public.action_archetypes aa on aa.action_id = a.id
      where aa.action_id is null $$,
  'every action carries at least one archetype'
);

-- Authoring discipline, not a schema limit. An action tagged with three or four
-- of the four drives is undifferentiated effort: it moves every axis a little
-- and tells the radar nothing. Relax this deliberately if content practice
-- disagrees; do not relax it to make a seed pass.
select is_empty(
  $$ select aa.action_id from public.action_archetypes aa
      group by aa.action_id having count(*) > 2 $$,
  'no action is spread across more than two archetypes'
);

-- The split has to be exercised by real content, not only by unit tests: a
-- library where every action is single-tagged would let the whole normalisation
-- path rot unnoticed behind a seed that never uses it.
select isnt_empty(
  $$ select aa.action_id from public.action_archetypes aa
      group by aa.action_id having count(*) > 1 $$,
  'at least one seeded action divides its effort across two archetypes'
);

-- ADR-0025: the authored copy lives in its own table now.

-- Every action has exactly one body. A seeded action without one is a day the
-- app cannot render; a body without an action is a row nothing can reach.
select is_empty(
  $$ select a.id from public.actions a
      left join public.action_bodies b on b.action_id = a.id
      where b.action_id is null $$,
  'every action has a body'
);

-- The gate that stops unauthored copy shipping must still see it. If this passes
-- while placeholders are present, the gate has stopped looking rather than the
-- copy having been written.
select isnt_empty(
  $$ select b.action_id from public.action_bodies b
      where b.body_md like '%[TO AUTHOR]%' or b.body_md like '%[PLACEHOLDER]%' $$,
  'placeholder bodies are still visible to an unauthored-copy check'
);

select * from finish();
rollback;
