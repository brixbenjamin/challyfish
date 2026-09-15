begin;
select plan(8);

-- Two users with a full set of rows each. Deleting one must take everything of
-- theirs and nothing of the other's.
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'a@example.com'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.com');

insert into public.profiles (user_id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222');

insert into public.campaign_runs (id, user_id, campaign_id, status, started_at)
select
  gen_random_uuid(),
  u.id,
  (select id from public.campaigns order by sort limit 1),
  'active',
  now()
from (values
  ('11111111-1111-1111-1111-111111111111'::uuid),
  ('22222222-2222-2222-2222-222222222222'::uuid)
) as u(id);

insert into public.day_logs (id, user_id, run_id, day_index, action_id, outcome)
select
  gen_random_uuid(),
  r.user_id,
  r.id,
  1,
  (select a.id from public.actions a
     join public.days d on d.id = a.day_id
    where d.campaign_id = r.campaign_id and d.day_index = 1
      and not a.is_optional),
  'done'
from public.campaign_runs r;

-- A tick per user, hanging off the day log inserted above. This is the row the
-- composite foreign key (run_id, day_index) -> day_logs has to carry away.
insert into public.day_log_actions (id, user_id, run_id, day_index, action_id)
select gen_random_uuid(), l.user_id, l.run_id, l.day_index, l.action_id
from public.day_logs l;

insert into public.diagnostic_results
  (id, user_id, taken_at, scores, weakest_archetype_id, recommended_campaign_id)
select
  gen_random_uuid(),
  r.user_id,
  now(),
  '{"psycho":0.25,"killer":0.75,"trickster":0.5,"beast":0.5}'::jsonb,
  (select id from public.archetypes order by sort limit 1),
  r.campaign_id
from public.campaign_runs r;

insert into public.entitlements (user_id, pack_id, source, acquired_at)
select r.user_id, (select id from public.packs order by sort limit 1), 'grant', now()
from public.campaign_runs r;

-- The delete under test: exactly what the Edge Function performs.
delete from auth.users where id = '11111111-1111-1111-1111-111111111111';

select is(
  (select count(*)::int from public.profiles
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'profiles cascaded'
);

select is(
  (select count(*)::int from public.campaign_runs
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'campaign_runs cascaded'
);

select is(
  (select count(*)::int from public.day_logs
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'day_logs cascaded — the honest record is genuinely gone'
);

select is(
  (select count(*)::int from public.diagnostic_results
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'diagnostic_results cascaded'
);

select is(
  (select count(*)::int from public.entitlements
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'entitlements cascaded'
);

-- The tick reaches auth.users by two routes -- its own user_id FK and the
-- composite key into day_logs -- and both have to be cascades. A restrict on
-- either would make account deletion fail outright rather than leave a
-- remnant, which is why this is asserted rather than assumed.
select is(
  (select count(*)::int from public.day_log_actions
    where user_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'day_log_actions cascaded — which acts were done is gone too'
);

select is(
  (select count(*)::int from public.day_logs
    where user_id = '22222222-2222-2222-2222-222222222222'),
  1,
  'the other user is untouched'
);

select is(
  (select count(*)::int from public.day_log_actions
    where user_id = '22222222-2222-2222-2222-222222222222'),
  1,
  'the other user keeps their ticks'
);

select * from finish();
rollback;
