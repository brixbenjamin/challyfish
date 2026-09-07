-- User zone: every row scoped to auth.uid(). Policies land in 0003.

create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  onboarded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.diagnostic_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  taken_at timestamptz not null default now(),
  scores jsonb not null,
  weakest_archetype_id uuid not null references public.archetypes (id),
  recommended_campaign_id uuid not null references public.campaigns (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.campaign_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  campaign_id uuid not null references public.campaigns (id),
  status text not null check (status in ('active', 'completed', 'abandoned')),
  is_hardened boolean not null default false,
  started_at timestamptz not null,
  completed_at timestamptz,
  -- Materialized once at completion for stable querying. Must always equal what
  -- RunEngine computes from the day logs; the engine is the definition.
  grade text check (grade in ('sovereign', 'passed', 'broken')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint grade_only_when_completed
    check ((status = 'completed') or grade is null)
);

-- One active run per user. Enforced here rather than in application logic,
-- because two offline devices can each believe they are the only writer.
create unique index campaign_runs_one_active
  on public.campaign_runs (user_id) where status = 'active';

create index campaign_runs_user_status_idx on public.campaign_runs (user_id, status);

create table public.day_logs (
  id uuid primary key default gen_random_uuid(),
  -- Denormalized from the run so row-level security is a single-table predicate.
  user_id uuid not null references auth.users (id) on delete cascade,
  run_id uuid not null references public.campaign_runs (id) on delete cascade,
  day_index int not null check (day_index > 0),
  action_id uuid not null references public.actions (id),
  committed_at timestamptz,
  outcome text check (outcome in ('done', 'partial', 'skipped', 'missed')),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- Makes every sync merge an upsert rather than a duplicate.
  unique (run_id, day_index)
);

create table public.entitlements (
  user_id uuid not null references auth.users (id) on delete cascade,
  pack_id uuid not null references public.packs (id) on delete cascade,
  source text not null,
  acquired_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, pack_id)
);

create index profiles_updated_idx on public.profiles (updated_at);
create index diagnostic_results_updated_idx on public.diagnostic_results (updated_at);
create index campaign_runs_updated_idx on public.campaign_runs (updated_at);
create index day_logs_updated_idx on public.day_logs (updated_at);
create index entitlements_updated_idx on public.entitlements (updated_at);

do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'diagnostic_results', 'campaign_runs', 'day_logs', 'entitlements'
  ] loop
    execute format(
      'create trigger %I_touch before update on public.%I
         for each row execute function public.touch_updated_at()',
      t, t
    );
  end loop;
end;
$$;
