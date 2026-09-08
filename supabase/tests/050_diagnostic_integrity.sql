begin;
select plan(6);

select results_eq(
  $$ select count(*)::int from public.diagnostic_questions $$,
  array[8],
  'the instrument has exactly eight questions'
);

select is_empty(
  $$ select q.sort from public.diagnostic_questions q
     where (select count(*) from public.diagnostic_options o
            where o.question_id = q.id) <> 2 $$,
  'every question has exactly two options'
);

select is_empty(
  $$ select q.sort from public.diagnostic_questions q
     where (select count(distinct o.archetype_id) from public.diagnostic_options o
            where o.question_id = q.id) <> 2 $$,
  'every question pits two different archetypes against each other'
);

-- The balance property: wins/4 is only comparable if every archetype is
-- offered the same number of times.
select is_empty(
  $$ select a.key from public.archetypes a
     where (select count(*) from public.diagnostic_options o
            where o.archetype_id = a.id) <> 4 $$,
  'every archetype appears in exactly four questions'
);

select results_eq(
  $$ with pairs as (
       select array_agg(o.archetype_id order by o.archetype_id) as pair
       from public.diagnostic_options o group by o.question_id
     ) select count(distinct pair)::int from pairs $$,
  array[6],
  'all six archetype pairings are covered'
);

select is_empty(
  $$ select o.id from public.diagnostic_options o
     where o.sort not in (0, 1) $$,
  'every option sits on side 0 or side 1'
);

select * from finish();
rollback;
