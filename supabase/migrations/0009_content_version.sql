-- A single number that changes whenever the authored library changes.
--
-- The client used to reconcile content incrementally, asking each table for
-- rows with `updated_at` newer than a per-device watermark. That can never
-- observe a deletion: a deleted row carries no newer timestamp, so a campaign
-- removed on the server stayed on every device that had already pulled it,
-- until the app was reinstalled. The same hole was already known for
-- entitlements, where it was closed by fetching the complete set (ADR-0025).
--
-- This closes it for content the same way, and this table is what makes the
-- complete fetch affordable: the client reads one integer on launch and
-- refetches the library only when that integer has moved.
--
-- Firing on `delete` is the entire point. It is the signal `updated_at`
-- structurally cannot carry.

create table public.content_version (
  id         int primary key default 1 check (id = 1),
  version    bigint not null default 1,
  updated_at timestamptz not null default now()
);

insert into public.content_version (id) values (1);

-- Statement-level, not row-level: a content release rewrites many rows at once
-- and the client only needs to know *that* it changed, never how much.
--
-- `security definer` because the bump must happen for whoever wrote the
-- content, and `set search_path = ''` for the same reason the entitlement
-- helpers in 0003 carry it.
create or replace function private.bump_content_version()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.content_version
     set version = version + 1,
         updated_at = now()
   where id = 1;
  return null;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array[
    'archetypes', 'packs', 'campaigns', 'campaign_archetypes',
    'days', 'day_bodies', 'actions', 'action_archetypes', 'action_bodies',
    'doctrine_groups', 'doctrine_entries',
    'diagnostic_questions', 'diagnostic_options'
  ] loop
    execute format(
      'create trigger %I_bump_content_version
         after insert or update or delete or truncate on public.%I
         for each statement execute function private.bump_content_version()',
      t, t
    );
  end loop;
end;
$$;

-- Readable by anyone who may read content, which is everyone (ADR-0008).
-- Written only by the triggers above, which run as their definer.
alter table public.content_version enable row level security;

create policy content_version_read on public.content_version
  for select to anon, authenticated using (true);

grant select on public.content_version to anon, authenticated;
grant select, insert, update, delete on public.content_version to service_role;
