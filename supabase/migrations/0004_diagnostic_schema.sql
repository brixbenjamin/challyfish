-- The onboarding instrument is content, not code (ADR-0009), so it can be
-- rewritten without an app release.

create table public.diagnostic_questions (
  id uuid primary key default gen_random_uuid(),
  prompt text not null,
  sort int not null unique,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.diagnostic_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.diagnostic_questions (id) on delete cascade,
  label text not null,
  archetype_id uuid not null references public.archetypes (id),
  sort int not null check (sort in (0, 1)),
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- One option per side. "Exactly two, on different archetypes" is asserted by
  -- the content validation suite, which can see the whole set at once.
  unique (question_id, sort),
  unique (question_id, archetype_id)
);

create index diagnostic_questions_updated_idx on public.diagnostic_questions (updated_at);
create index diagnostic_options_updated_idx on public.diagnostic_options (updated_at);
create index diagnostic_options_question_idx on public.diagnostic_options (question_id, sort);

-- Same shape as the rest of the content zone (0003): read-only to the client
-- roles, full DML to service_role. Postgres checks table-level GRANTs before
-- RLS policies are consulted, so the policy is inert without the grant.
do $$
declare t text;
begin
  foreach t in array array['diagnostic_questions', 'diagnostic_options'] loop
    execute format(
      'create trigger %I_touch before update on public.%I
         for each row execute function public.touch_updated_at()', t, t);
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy %I_read on public.%I for select to anon, authenticated using (true)',
      t, t);
    execute format('grant select on public.%I to anon, authenticated', t);
    execute format('grant select, insert, update, delete on public.%I to service_role', t);
  end loop;
end;
$$;
