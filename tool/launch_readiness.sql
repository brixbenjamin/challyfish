-- Launch gate. Run with:
--   psql "$(supabase status -o json | jq -r '.DB_URL')" -f tool/launch_readiness.sql
--
-- Structural CI checks say the library is well-formed. This says it is written.
-- Passing it is not the same as having reviewed it: the safety floor is a human
-- gate (ADR-0020, docs/product/content-review.md).
--
-- Two markers, not one. Plan 1's seed wrote [PLACEHOLDER] and plan 4's wrote
-- [TO AUTHOR]; a gate that knows only the newer one waves the older rows
-- through, which is the exact failure this file exists to prevent.

\set ON_ERROR_STOP on

do $$
declare
  unauthored int;
begin
  select count(*) into unauthored
  from (
    -- The copy left public.actions for public.action_bodies (ADR-0025). Read
    -- through the join: a predicate against the old column matches nothing and
    -- the gate passes everything, reporting success because it stopped looking.
    select 1
      from public.actions a
      join public.action_bodies b on b.action_id = a.id
      where b.body_md like '%[TO AUTHOR]%' or a.title like '%[TO AUTHOR]%'
         or b.body_md like '%[PLACEHOLDER]%' or a.title like '%[PLACEHOLDER]%'
    union all
    -- Day titles and day bodies carry the same markers as action copy
    -- (ADR-0034). A day the user cannot read is a day they cannot decide to
    -- commit to, so a missing body is a launch blocker, not a gap.
    select 1
      from public.days d
      join public.day_bodies b on b.day_id = d.id
      where b.body_md like '%[TO AUTHOR]%' or d.title like '%[TO AUTHOR]%'
         or b.body_md like '%[PLACEHOLDER]%' or d.title like '%[PLACEHOLDER]%'
    union all
    -- The synthesized title 0008's backfill writes, and seed/days.sql writes for
    -- the generated campaigns. Not placeholder copy that was written and left
    -- unreviewed -- copy that was never written at all, which no marker catches.
    select 1 from public.days where title ~ '^Day [0-9]+$'
    union all
    select 1 from public.campaigns
      where intro_md like '%[TO AUTHOR]%'
         or coalesce(subtitle, '') like '%[TO AUTHOR]%'
         or intro_md like '%[PLACEHOLDER]%'
         or coalesce(subtitle, '') like '%[PLACEHOLDER]%'
    union all
    select 1 from public.packs
      where description like '%[TO AUTHOR]%'
         or description like '%[PLACEHOLDER]%'
    union all
    select 1 from public.doctrine_entries
      where body_md like '%[TO AUTHOR]%' or title like '%[TO AUTHOR]%'
         or body_md like '%[PLACEHOLDER]%' or title like '%[PLACEHOLDER]%'
  ) t;

  if unauthored > 0 then
    raise exception
      'launch gate: % rows still carry an unauthored-content marker', unauthored;
  end if;

  if exists (
    select 1 from public.packs
     where not is_core and store_product_id like 'com.example.%'
  ) then
    raise exception
      'launch gate: a pack still carries the placeholder store product id';
  end if;

  if exists (
    select 1 from public.days d
     where not exists (select 1 from public.day_bodies b where b.day_id = d.id)
  ) then
    raise exception
      'launch gate: a day has no body -- it cannot be committed to unread';
  end if;

  raise notice 'launch gate: content is authored and product ids are real';
end;
$$;
