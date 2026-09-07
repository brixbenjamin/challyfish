# Feral

Feral is a Flutter + Supabase mobile app. This repository is the build: a local
Drift/SQLite database as the runtime source of truth, Supabase Postgres behind it,
and two pure-Dart rule units (`RunEngine`, `BalanceCalculator`) that hold every rule
worth testing.

## Layout

- `app/` — the Flutter application.
- `supabase/` — the Supabase project (Postgres schema, migrations, config).
- `.github/workflows/` — CI: `flutter test`/`analyze`/`format` for the app,
  `supabase test db` for the database.

## Working in this repo

- `cd app && flutter test` runs the Dart test suite, including
  `test/architecture_test.dart`, which enforces the layering rules described in
  `docs/technical/architecture.md` (planning workspace).
- `supabase start` brings up the local Postgres/Auth/Storage stack; `supabase test db`
  runs the pgTAP suite against it.
- The app reads its Supabase URL and anon key via `--dart-define`, never from a
  committed file. Copy the variable names from `app/.env.example` (values come from
  `supabase status`):
  `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

## Provenance

Decisions, specs, and the fork checklist live in the sibling planning workspace,
`feral-maxxing`, not in this repository. `app/lib/src/niche/README.md` lists what a
fork of this app changes.
