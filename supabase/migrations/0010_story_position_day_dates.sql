-- The dates a day of a run actually happened on, and the date a run ended for
-- absence (ADR-0040).
--
-- A campaign day used to be a function of the wall clock: `current_day` was the
-- number of calendar days since the run started, so missing a day meant never
-- seeing that day's content. Two of the three authored campaign shapes —
-- Two-Beat and Escalation Ladder — are defined by one day depending on the last,
-- so skipping a day did not cost the user a day, it broke the arc.
--
-- The content pointer now follows the user's progress and the calendar keeps the
-- score. That needs three things the schema could not say:
--
--   * when a day was worked on and when it was resolved, because absence is the
--     gap between those dates and the calendar, and a date re-derived after the
--     user changes timezone would move their day underneath them;
--   * a nullable `action_id`, so a day whose content was never cached can still
--     be resolved — one that cannot is a day that silently becomes an absence
--     and can end a run the user was present for;
--   * the date a run was abandoned on, materialized for the same reason `grade`
--     is: a terminal run's result should be stable and queryable.
--
-- `missed` goes with them. It existed only for rollover to write on a day
-- nobody attended, and an absent calendar day no longer maps to a day of
-- content at all. Every outcome left is one the user produced.
--
-- No backfill. There is no user data yet, and inventing a date from
-- `started_at + day_index - 1` would write the exact arithmetic ADR-0040 found
-- to be wrong into the honest record.

alter table public.day_logs
  add column worked_on date,
  add column resolved_on date;

comment on column public.day_logs.worked_on is
  'Local calendar date the user first touched this day (commit, tick or '
  'report). Set once and never moved: a day ticked on Monday and resolved by '
  'Wednesday is still Monday''s day.';

comment on column public.day_logs.resolved_on is
  'Local calendar date this day''s outcome was written. Null while the day is '
  'in progress. Rollover stamps it with worked_on, never with the day it runs.';

-- A day whose content is not cached has no action id to offer. Before ADR-0040
-- rollover skipped such a day entirely, which left an elapsed day unresolved.
alter table public.day_logs
  alter column action_id drop not null;

-- Postgres names an inline column check `<table>_<column>_check`.
alter table public.day_logs
  drop constraint day_logs_outcome_check;

alter table public.day_logs
  add constraint day_logs_outcome_check
  check (outcome in ('done', 'partial', 'skipped'));

alter table public.campaign_runs
  add column abandoned_on date;

comment on column public.campaign_runs.abandoned_on is
  'Local date a run ended for three consecutive absent days. Null on every '
  'other run, including one the user abandoned themselves — which is what '
  'tells the two apart. An abandoned run carries no grade: it has no result, '
  'only an ending, which grade_only_when_completed already enforces.';
