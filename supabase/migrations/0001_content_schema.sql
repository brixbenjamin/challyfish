-- Content zone: anon-readable, service-role-written. Locked packs are browsable
-- teasers by design (ADR-0008), so nothing here is secret.

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.archetypes (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  name text not null,
  blurb text not null,
  color text not null,
  sort int not null,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.doctrine_groups (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  blurb text,
  sort int not null,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.doctrine_entries (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.doctrine_groups (id) on delete cascade,
  title text not null,
  body_md text not null,
  related_archetype_id uuid references public.archetypes (id),
  sort int not null,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.packs (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  title text not null,
  description text not null,
  is_core boolean not null default false,
  store_product_id text,
  cover_path text,
  sort int not null,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- A non-core pack that cannot be bought is a content bug, not a state.
  constraint paid_packs_have_a_product
    check (is_core or store_product_id is not null)
);

-- Exactly one core pack, forever.
create unique index packs_single_core on public.packs ((true)) where is_core;

create table public.campaigns (
  id uuid primary key default gen_random_uuid(),
  pack_id uuid not null references public.packs (id) on delete cascade,
  key text not null unique,
  title text not null,
  subtitle text,
  intro_md text not null,
  length_days int not null check (length_days > 0),
  ramp_days int not null default 0,
  difficulty int not null default 1,
  cover_path text,
  sort int not null,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ramp_fits_inside_campaign
    check (ramp_days >= 0 and ramp_days < length_days)
);

create table public.campaign_archetypes (
  campaign_id uuid not null references public.campaigns (id) on delete cascade,
  archetype_id uuid not null references public.archetypes (id),
  weight numeric not null default 1 check (weight > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (campaign_id, archetype_id)
);

create table public.actions (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns (id) on delete cascade,
  day_index int not null check (day_index > 0),
  title text not null,
  body_md text not null,
  -- Exactly one archetype per action. Not nullable, not a join table (ADR-0004).
  archetype_id uuid not null references public.archetypes (id),
  why_doctrine_id uuid references public.doctrine_entries (id),
  effort int not null default 1,
  min_app_version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (campaign_id, day_index)
);

create index actions_campaign_idx on public.actions (campaign_id, day_index);

-- The watermark pull filters on updated_at across every content table.
create index archetypes_updated_idx on public.archetypes (updated_at);
create index doctrine_groups_updated_idx on public.doctrine_groups (updated_at);
create index doctrine_entries_updated_idx on public.doctrine_entries (updated_at);
create index packs_updated_idx on public.packs (updated_at);
create index campaigns_updated_idx on public.campaigns (updated_at);
create index actions_updated_idx on public.actions (updated_at);

do $$
declare t text;
begin
  foreach t in array array[
    'archetypes', 'doctrine_groups', 'doctrine_entries',
    'packs', 'campaigns', 'campaign_archetypes', 'actions'
  ] loop
    execute format(
      'create trigger %I_touch before update on public.%I
         for each row execute function public.touch_updated_at()',
      t, t
    );
  end loop;
end;
$$;
