-- The seed is an index, not a file. Content lives in seed/ so that a change to
-- the campaign library and a change to the axes are separate diffs (ADR-0021).
--
-- Order is insertion order: everything references axes.sql, so it is first, and
-- actions reference campaigns. Plan 2 adds doctrine.sql and diagnostic.sql after
-- axes.sql; both reference archetypes and nothing references them.
--
-- Run this directly with `psql -f supabase/seed.sql` to apply it as written.
-- `supabase db reset` seeds over the wire protocol rather than through psql, so
-- it cannot interpret `\i`; config.toml's [db.seed].sql_paths lists these same
-- same files in this same order as the CLI-executable equivalent. Keep both in
-- sync if the include order ever changes.
\i seed/axes.sql
\i seed/diagnostic.sql
\i seed/packs.sql
\i seed/campaigns.sql
\i seed/actions.sql
