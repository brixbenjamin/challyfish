# Graph Report - feral-build  (2026-09-10)

## Corpus Check
- 199 files · ~115,429 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2565 nodes · 3676 edges · 170 communities (127 shown, 21 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2db07280`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- database.dart
- app_localizations.dart
- app_localizations_en.dart
- sync_scheduler.dart
- home_router.dart
- providers.dart
- email_code_screen.dart
- sync_repository.dart
- content_tables.dart
- package:flutter/material.dart
- DataClass
- user_tables.dart
- money_path_test.dart
- settings_restore_test.dart
- settings_screen.dart
- content_repository.dart
- purchase_state.dart
- identity.dart
- diagnostic_result_screen.dart
- sync_entitlements_test.dart
- progress_repository.dart
- FeralDatabase
- diagnostic_repository_test.dart
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- balance_state.dart
- contentRepositoryProvider
- generate_seed_snapshot.dart
- link_flow.dart
- ../../core/l10n_ext.dart
- entitlement_repository.dart
- dashboard_screen_test.dart
- main.dart
- two_device_test.dart
- identity_repository.dart
- package:test/test.dart
- package:supabase_flutter/supabase_flutter.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- day_log.dart
- package:feral/src/domain/run.dart
- sync_scheduler_test.dart
- delete_account_screen.dart
- ../support/pump.dart
- run_state.dart
- purchase_delivery_test.dart
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- static const
- purchase.dart
- purchase_controller_test.dart
- completion_screen.dart
- seed_snapshot_test.dart
- _HomeRouterState
- dashboard_screen.dart
- balance_test.dart
- auth_gateway.dart
- replace_confirm_screen.dart
- package:feral/src/core/clock.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- package:feral/src/domain/outcome.dart
- AppDelegate
- diagnostic.dart
- sign_in_restore_test.dart
- run.dart
- run_reconciler.dart
- diagnostic_scorer_test.dart
- String?
- balance.dart
- ../domain/grade.dart
- link_flow_test.dart
- unlock_refreshes_detail_test.dart
- paid_content_boundary_test.dart
- first_run_offline_test.dart
- package:timezone/timezone.dart
- purchase_gateway.dart
- persistence_restart_test.dart
- public.action_bodies
- sync_state.dart
- unlock_sheet_test.dart
- auth.users
- body_purge_test.dart
- balance_state_test.dart
- campaign.dart
- campaign_detail_screen.dart
- report_sheet.dart
- 0001_content_schema.sql
- Money path integration test
- diagnostic_screen.dart
- sync_tables.dart
- entitlement.dart
- account_deletion_test.dart
- run_engine.dart
- package:flutter_test/flutter_test.dart
- email_code_screen_test.dart
- Clock
- sync_push_test.dart
- accountApiProvider
- email_link_test.dart
- l10n_ext.dart
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- clockProvider
- contentRepositoryProvider
- doctrine_screen_test.dart
- MainActivity.kt
- diagnosticRepositoryProvider
- app
- LaunchImage.imageset/README.md
- State
- DateTime
- _buildHome
- identityRepositoryProvider
- pack.dart
- run_state_test.dart
- completion_test.dart
- linkPromptStateProvider
- progressRepositoryProvider
- StatelessWidget
- purchaseGatewayProvider
- revenuecat_outcome_test.dart
- pack_list_screen.dart
- PurchaseGateway
- reminderSchedulerProvider
- seedSnapshotLoaderProvider
- syncSchedulerProvider
- userIdProvider
- zoneProvider
- supabase_bootstrap.dart
- progress_repository_lock_test.dart
- List
- package:feral/src/domain/pack.dart
- account_api.dart
- pack_views_test.dart
- backoff.dart
- package:timezone/data/latest.dart
- ContentApi
- ../../domain/pack.dart
- backoff_test.dart
- _AppLocalizationsDelegate

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 28 edges
2. `_HomeRouterState` - 19 edges
3. `AppLocalizations` - 17 edges
4. `DataClass` - 17 edges
5. `contentRepositoryProvider` - 13 edges
6. `userIdProvider` - 13 edges
7. `Clock` - 9 edges
8. `FakePurchaseGateway` - 8 edges
9. `PurchaseUiState` - 8 edges
10. `_buildHome` - 7 edges

## Surprising Connections (you probably didn't know these)
- `CI app job (format, analyze, test)` --implements--> `Strict Dart static analysis config`  [INFERRED]
  .github/workflows/ci.yml → app/analysis_options.yaml
- `CI app job (format, analyze, test)` --references--> `architecture_test.dart layering enforcement`  [INFERRED]
  .github/workflows/ci.yml → README.md
- `Feral CI Workflow` --implements--> `Supabase URL/anon key via --dart-define, never committed`  [INFERRED]
  .github/workflows/ci.yml → README.md
- `Money path integration test` --shares_data_with--> `purchases_flutter (RevenueCat) integration`  [INFERRED]
  .github/workflows/ci.yml → app/pubspec.yaml
- `Supabase URL/anon key via --dart-define, never committed` --rationale_for--> `Two-device integration test`  [INFERRED]
  README.md → .github/workflows/ci.yml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Fork surface: vocabulary, brand, and seed content** — app_lib_src_niche_readme_fork_checklist, app_lib_src_niche_readme_niche_arb_keys, app_lib_src_niche_readme_brand_dart, app_lib_src_niche_readme_supabase_seed [EXTRACTED 1.00]
- **CI pipeline: app, database, and functions jobs** — _github_workflows_ci_app_job, _github_workflows_ci_database_job, _github_workflows_ci_functions_job [EXTRACTED 1.00]
- **RevenueCat money path verification** — _github_workflows_ci_money_path_integration_test, _github_workflows_ci_webhook_mapping_test, app_pubspec_revenuecat_purchases [INFERRED 0.80]

## Communities (170 total, 21 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (150): clearWatermark, migration, schemaVersion, setWatermark, watermarkFor, class CampaignArchetypeRow extends, class DiagnosticOptionRow extends, class DiagnosticQuestionRow extends (+142 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (138): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+130 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.02
Nodes (127): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+119 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.05
Nodes (38): backoff, clock, _connectivity, ConnectivityGate, ConnectivityPlusGate, _connectivitySub, _consecutiveFailures, consumeNotices (+30 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (56): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+48 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (46): AccountApi, androidKey, authGatewayProvider, campaignsByPack, connectivityGateProvider, content, databaseProvider, db (+38 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (28): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+20 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (40): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+32 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.06
Nodes (34): actionId, archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayIndex (+26 more)

### Community 9 - "package:flutter/material.dart"
Cohesion: 0.07
Nodes (34): AppLocalizations, AppLocalizationsEn, of, wrap, archetypes, l10n, main, pump (+26 more)

### Community 10 - "DataClass"
Cohesion: 0.11
Nodes (35): Insertable, UpdateCompanion, ActionBodiesCompanion, ActionBodyRow, ActionRow, ActionsCompanion, ArchetypeRow, ArchetypesCompanion (+27 more)

### Community 11 - "user_tables.dart"
Cohesion: 0.06
Nodes (30): acquiredAt, actionId, campaignId, committedAt, completedAt, dayIndex, dirty, displayName (+22 more)

### Community 12 - "money_path_test.dart"
Cohesion: 0.07
Nodes (29): actionIdFor, client, close, configure, content, db, Device, entitlements (+21 more)

### Community 13 - "settings_restore_test.dart"
Cohesion: 0.15
Nodes (13): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+5 more)

### Community 14 - "settings_screen.dart"
Cohesion: 0.07
Nodes (30): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+22 more)

### Community 15 - "content_repository.dart"
Cohesion: 0.07
Nodes (29): actionFor, actionsFor, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById, _at (+21 more)

### Community 16 - "purchase_state.dart"
Cohesion: 0.11
Nodes (23): buy, clock, content, _deliver, entitlements, gateway, packId, PurchaseComplete (+15 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (26): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+18 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.08
Nodes (22): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+14 more)

### Community 19 - "sync_entitlements_test.dart"
Cohesion: 0.14
Nodes (13): db, entitlementRow, fetched, fetchedSince, fetchSince, main, repoWith, rows (+5 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.08
Nodes (23): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+15 more)

### Community 21 - "FeralDatabase"
Cohesion: 0.09
Nodes (23): _, @DriftDatabase, FeralDatabase, SyncRepository, api, db, insertLocalRun, main (+15 more)

### Community 22 - "diagnostic_repository_test.dart"
Cohesion: 0.12
Nodes (16): ContentApi, SupabaseContentApi, DiagnosticRepository, SilentContentApi, db, fetchSince, main, _NoopApi (+8 more)

### Community 23 - "diagnostic_repository.dart"
Cohesion: 0.09
Nodes (22): campaignId, _Candidate, clock, content, db, difficulty, hasCompleted, latestFor (+14 more)

### Community 24 - "fake_purchase_gateway.dart"
Cohesion: 0.09
Nodes (22): catalogue, _changes, configure, configureCalls, currentUserId, dispose, failSwitchUser, forgetUser (+14 more)

### Community 25 - "balance_state.dart"
Cohesion: 0.17
Nodes (11): archetypes, balance, BalanceState, load, marks, marksFor, maxValue, normalizedFor (+3 more)

### Community 26 - "contentRepositoryProvider"
Cohesion: 0.17
Nodes (16): contentRepositoryProvider, purchaseGatewayProvider, reminderSchedulerProvider, userIdProvider, _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked (+8 more)

### Community 27 - "generate_seed_snapshot.dart"
Cohesion: 0.11
Nodes (17): main, main, close, connection, file, leaked, main, paid (+9 more)

### Community 28 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 29 - "../../core/l10n_ext.dart"
Cohesion: 0.18
Nodes (10): build, DoctrineIntroScreen, onContinue, onSignIn, signInKey, build, onAccept, PrivacyNoticeScreen (+2 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.12
Nodes (15): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+7 more)

### Community 31 - "dashboard_screen_test.dart"
Cohesion: 0.15
Nodes (12): action, archetypes, balance, berlin, campaign, l10n, main, pump (+4 more)

### Community 32 - "main.dart"
Cohesion: 0.15
Nodes (12): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, src/app/providers.dart (+4 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.10
Nodes (19): a, actionIdFor, api, b, backdate, campaignId, client, close (+11 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.09
Nodes (22): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+14 more)

### Community 35 - "package:test/test.dart"
Cohesion: 0.07
Nodes (31): main, db, ddl, main, probe, raw, _schemaStatementsFor, _v1Tables (+23 more)

### Community 36 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.18
Nodes (11): _client, fetchSince, _client, _conflictTargets, fetchSince, ProgressApi, SupabaseProgressApi, upsert (+3 more)

### Community 37 - "settings_screen_test.dart"
Cohesion: 0.10
Nodes (19): disable, enable, enabled, isEnabled, l10n, main, offeredTime, permissionGranted (+11 more)

### Community 38 - "reminder_scheduler.dart"
Cohesion: 0.11
Nodes (18): disable, enable, _enabledKey, _hourKey, isEnabled, LocalReminderScheduler, _minuteKey, _notificationId (+10 more)

### Community 39 - "identity_repository_test.dart"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "day_log.dart"
Cohesion: 0.12
Nodes (15): actionId, committedAt, dayIndex, DayLog, id, isReported, note, outcome (+7 more)

### Community 41 - "package:feral/src/domain/run.dart"
Cohesion: 0.15
Nodes (11): earnedFor, main, marks, run, targets, main, run, package:feral/src/domain/grade.dart (+3 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.10
Nodes (20): SyncRunner, SyncScheduler, calls, consumeNotices, _controller, delay, dispose, FakeSync (+12 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (17): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+9 more)

### Community 44 - "../support/pump.dart"
Cohesion: 0.06
Nodes (35): dismissals, links, main, pump, allText, arm, cancels, deleted (+27 more)

### Community 45 - "run_state.dart"
Cohesion: 0.11
Nodes (17): campaign, currentDay, derive, grade, isCommittedToday, isFinalDay, isFinished, isReportedToday (+9 more)

### Community 46 - "purchase_delivery_test.dart"
Cohesion: 0.12
Nodes (16): at, bodyPresentAfterPulls, buildTestController, clock, db, delay, fetchSince, gateway (+8 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.10
Nodes (20): AppleCredentials, _body, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor (+12 more)

### Community 48 - "unlock_sheet.dart"
Cohesion: 0.11
Nodes (18): build, _busy, buyKey, campaigns, closeKey, deliveringKey, onBuy, onClose (+10 more)

### Community 49 - "mapping.ts"
Cohesion: 0.16
Nodes (11): ADR-0017, ADR-0019, RFC-4122, asProductId(), asUserId(), asUserIds(), planWrites(), ADR-0017 (+3 more)

### Community 50 - "@DataClassName"
Cohesion: 0.22
Nodes (17): @DataClassName, ActionBodies, Actions, Archetypes, CampaignArchetypes, Campaigns, DiagnosticOptions, DiagnosticQuestions (+9 more)

### Community 51 - "revenuecat_gateway.dart"
Cohesion: 0.12
Nodes (15): apiKey, _changes, configure, _configured, forgetUser, outcomeForErrorCode, _ownedFrom, ownedProductChanges (+7 more)

### Community 52 - "static const"
Cohesion: 0.14
Nodes (12): appName, Brand, colorSeed, theme, build, dismissKey, _message, messageKey (+4 more)

### Community 53 - "purchase.dart"
Cohesion: 0.18
Nodes (10): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+2 more)

### Community 54 - "purchase_controller_test.dart"
Cohesion: 0.11
Nodes (18): PurchaseController, controller, core, db, edge, fetchSince, gateway, main (+10 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (15): build, campaign, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey, marksEarned (+7 more)

### Community 56 - "seed_snapshot_test.dart"
Cohesion: 0.12
Nodes (15): content, db, loadIfEmpty, _partialTables, SeedSnapshotLoader, ContentRepository, content, db (+7 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.13
Nodes (18): accountApiProvider, diagnosticRepositoryProvider, identityRepositoryProvider, linkPromptStateProvider, seedSnapshotLoaderProvider, syncSchedulerProvider, _bootstrapContent, _dismissLinkPrompt (+10 more)

### Community 58 - "dashboard_screen.dart"
Cohesion: 0.12
Nodes (15): balance, banner, build, onCommit, onOpenDoctrine, onOpenSettings, _report, state (+7 more)

### Community 59 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 60 - "auth_gateway.dart"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "replace_confirm_screen.dart"
Cohesion: 0.13
Nodes (13): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+5 more)

### Community 62 - "package:feral/src/core/clock.dart"
Cohesion: 0.17
Nodes (10): EntitlementRepository, main, core, db, edge, gateway, main, repo (+2 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.14
Nodes (13): ../app/balance_state.dart, build, fillColor, gridColor, paint, _RadarPainter, shouldRepaint, size (+5 more)

### Community 65 - "package:feral/src/domain/outcome.dart"
Cohesion: 0.18
Nodes (11): engine, log, main, misses, engine, log, main, package:feral/src/domain/day_log.dart (+3 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "diagnostic.dart"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 68 - "sign_in_restore_test.dart"
Cohesion: 0.10
Nodes (19): auth, consumeNotices, db, gate, l10n, main, now, prefs (+11 more)

### Community 69 - "run.dart"
Cohesion: 0.11
Nodes (16): earnsMark, fromKey, Grade, key, campaignId, completedAt, fromKey, grade (+8 more)

### Community 70 - "run_reconciler.dart"
Cohesion: 0.15
Nodes (11): CampaignRun, earned, MarkCalculator, abandon, isConflict, keep, localSurvived, Reconciliation (+3 more)

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "String?"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineGroup, groupId, id, relatedArchetypeId, sort, title (+1 more)

### Community 73 - "balance.dart"
Cohesion: 0.17
Nodes (11): BalanceCalculator, BalanceWeights, baseFor, compute, done, halfLifeDays, _localDate, partial (+3 more)

### Community 74 - "../domain/grade.dart"
Cohesion: 0.17
Nodes (10): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, gradeName, outcomeLabel, ../domain/grade.dart (+2 more)

### Community 75 - "link_flow_test.dart"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "unlock_refreshes_detail_test.dart"
Cohesion: 0.04
Nodes (59): ../app/app_sync_wiring_test.dart, _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, auth (+51 more)

### Community 77 - "paid_content_boundary_test.dart"
Cohesion: 0.07
Nodes (29): client, close, configure, content, corePack, db, Device, entitlements (+21 more)

### Community 78 - "first_run_offline_test.dart"
Cohesion: 0.09
Nodes (21): fetchSince, main, actionRow, archetypeRow, db, fetchSince, main, rows (+13 more)

### Community 79 - "package:timezone/timezone.dart"
Cohesion: 0.18
Nodes (9): deviceZone, info, berlin, day1, db, main, repoAt, package:flutter_timezone/flutter_timezone.dart (+1 more)

### Community 80 - "purchase_gateway.dart"
Cohesion: 0.18
Nodes (10): configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, restore, switchUser (+2 more)

### Community 81 - "persistence_restart_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, dbFile, dir, main, open, Directory, package:feral/src/app/run_state.dart

### Community 83 - "sync_state.dart"
Cohesion: 0.25
Nodes (7): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, ../domain/sync_status.dart, providers.dart

### Community 84 - "unlock_sheet_test.dart"
Cohesion: 0.18
Nodes (10): buys, campaigns, closes, edge, l10n, main, pump, restores (+2 more)

### Community 85 - "auth.users"
Cohesion: 0.23
Nodes (12): auth.users, public.actions, public.campaigns, public.entitlements, public.packs, public.campaign_runs, public.day_logs, public.diagnostic_results (+4 more)

### Community 86 - "body_purge_test.dart"
Cohesion: 0.12
Nodes (16): api, apiThrows, at, db, fetchSince, Harness, into, main (+8 more)

### Community 87 - "balance_state_test.dart"
Cohesion: 0.22
Nodes (8): actions, archetypes, berlin, build, log, main, run, start

### Community 88 - "campaign.dart"
Cohesion: 0.11
Nodes (17): ActionSpec, archetypeId, bodyMd, campaignId, dayIndex, difficulty, effort, id (+9 more)

### Community 89 - "campaign_detail_screen.dart"
Cohesion: 0.18
Nodes (10): Campaign, build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance, onStart (+2 more)

### Community 90 - "report_sheet.dart"
Cohesion: 0.33
Nodes (5): build, _controller, createState, dispose, outcome

### Community 91 - "0001_content_schema.sql"
Cohesion: 0.35
Nodes (9): public, public.action_bodies, public.actions, public.archetypes, public.campaign_archetypes, public.campaigns, public.doctrine_entries, public.doctrine_groups (+1 more)

### Community 92 - "Money path integration test"
Cohesion: 0.25
Nodes (9): Feral CI Workflow, CI database job (supabase test db, pgTAP), CI functions job (Edge Function type-check and test), Headless Linux runner has no device target, Money path integration test, Two-device integration test, RevenueCat webhook mapping test, purchases_flutter (RevenueCat) integration (+1 more)

### Community 93 - "diagnostic_screen.dart"
Cohesion: 0.13
Nodes (14): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, build, _choose (+6 more)

### Community 94 - "sync_tables.dart"
Cohesion: 0.22
Nodes (8): lastPulledAt, primaryKey, SyncState, syncTable, watermark, DateTimeColumn get, Set, TextColumn get

### Community 95 - "entitlement.dart"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 96 - "account_deletion_test.dart"
Cohesion: 0.09
Nodes (21): PurchaseGateway, RevenueCatGateway, api, auth, calls, db, deleteAccount, identity (+13 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.22
Nodes (8): currentDay, daysNeedingMissed, grade, missAllowance, missCount, RunEngine, ../domain/day_log.dart, grade_thresholds.dart

### Community 98 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.14
Nodes (13): main, l10n, main, pair, questions, l10n, main, package:feral/src/app/link_prompt_state.dart (+5 more)

### Community 99 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 100 - "Clock"
Cohesion: 0.32
Nodes (7): Clock, delay, FixedClock, _instant, nowUtc, SystemClock, InstantClock

### Community 101 - "sync_push_test.dart"
Cohesion: 0.17
Nodes (11): api, callLog, db, failFetch, fetchSince, remote, seedRunAndLog, sync (+3 more)

### Community 105 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

### Community 106 - "l10n_ext.dart"
Cohesion: 0.33
Nodes (5): l10n, L10nContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 114 - "doctrine_screen_test.dart"
Cohesion: 0.25
Nodes (7): entries, groups, l10n, main, package:feral/src/domain/doctrine.dart, package:feral/src/ui/doctrine/doctrine_entry_screen.dart, package:feral/src/ui/doctrine/doctrine_list_screen.dart

### Community 135 - "State"
Cohesion: 0.27
Nodes (10): ReportSheet, _ReportSheetState, EmailCodeScreen, _EmailCodeScreenState, DiagnosticScreen, _DiagnosticScreenState, DeleteAccountScreen, _DeleteAccountScreenState (+2 more)

### Community 136 - "DateTime"
Cohesion: 0.25
Nodes (7): kind, message, occurredAt, SyncNotice, SyncNoticeKind, SyncStatus, DateTime

### Community 137 - "_buildHome"
Cohesion: 0.47
Nodes (6): clockProvider, progressRepositoryProvider, zoneProvider, balance, _buildHome, _startRun

### Community 143 - "pack.dart"
Cohesion: 0.20
Nodes (9): coverPath, description, id, isCore, key, Pack, sort, storeProductId (+1 more)

### Community 144 - "run_state_test.dart"
Cohesion: 0.22
Nodes (8): action, berlin, campaign, log, main, run, started, stateOn

### Community 145 - "completion_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays

### Community 148 - "StatelessWidget"
Cohesion: 0.29
Nodes (7): CompletionScreen, ArchetypeRadar, DashboardScreen, LinkSheet, UnlockSheet, _SectionHeading, StatelessWidget

### Community 150 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 151 - "pack_list_screen.dart"
Cohesion: 0.15
Nodes (11): toAction, toCampaign, build, campaigns, isUnlocked, pack, PackListScreen, packs (+3 more)

### Community 152 - "PurchaseGateway"
Cohesion: 0.67
Nodes (3): NoStoreGateway, NoStoreGateway, PurchaseGateway

### Community 158 - "supabase_bootstrap.dart"
Cohesion: 0.18
Nodes (10): attempt, auth, ensureAnonymousSession, existing, initialize, initializeSupabase, _retryDelay, seconds (+2 more)

### Community 159 - "progress_repository_lock_test.dart"
Cohesion: 0.20
Nodes (9): AccountDeletionFailed, PackLocked, ProgressRepository, IdentityAlreadyAttached, db, main, repo, Exception (+1 more)

### Community 160 - "List"
Cohesion: 0.22
Nodes (8): SyncNoticeNotifier, build, DoctrineListScreen, entriesByGroup, groups, ../domain/doctrine.dart, List, Notifier

### Community 161 - "package:feral/src/domain/pack.dart"
Cohesion: 0.22
Nodes (8): core, edge, main, resolver, unlocked, unpriced, package:feral/src/domain/pack.dart, package:feral/src/engine/entitlement_resolver.dart

### Community 162 - "account_api.dart"
Cohesion: 0.29
Nodes (7): AccountApi, _client, deleteAccount, message, SupabaseAccountApi, toString, FakeAccountApi

### Community 163 - "pack_views_test.dart"
Cohesion: 0.25
Nodes (7): core, edge, free, main, paid, views, package:feral/src/domain/campaign.dart

### Community 164 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 165 - "package:timezone/data/latest.dart"
Cohesion: 0.29
Nodes (6): berlin, dayFor, engine, losAngeles, main, package:timezone/data/latest.dart

### Community 166 - "ContentApi"
Cohesion: 0.33
Nodes (6): OfflineApi, _SilentContentApi, DelayedBodyContentApi, RecordingContentApi, FakeContentApi, ContentApi

### Community 167 - "../../domain/pack.dart"
Cohesion: 0.40
Nodes (4): EntitlementResolver, isUnlocked, unlockedPackIds, ../../domain/pack.dart

### Community 168 - "backoff_test.dart"
Cohesion: 0.50
Nodes (3): b, main, package:feral/src/engine/backoff.dart

## Knowledge Gaps
- **1743 isolated node(s):** `Device`, `ownedProductChanges`, `client`, `userId`, `db` (+1738 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1959 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **21 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `FeralDatabase` to `database.dart`, `completion_test.dart`, `progress_repository.dart`, `diagnostic_repository_test.dart`, `diagnostic_repository.dart`, `entitlement_repository.dart`, `progress_repository_lock_test.dart`, `two_device_test.dart`, `package:test/test.dart`, `identity_repository_test.dart`, `seed_snapshot_test.dart`, `package:feral/src/core/clock.dart`, `sign_in_restore_test.dart`, `link_flow_test.dart`, `unlock_refreshes_detail_test.dart`, `first_run_offline_test.dart`, `package:timezone/timezone.dart`, `account_deletion_test.dart`, `sync_push_test.dart`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `package:flutter/material.dart` to `app_localizations.dart`, `package:flutter_test/flutter_test.dart`, `settings_screen_test.dart`, `_AppLocalizationsDelegate`, `settings_restore_test.dart`, `doctrine_screen_test.dart`, `unlock_sheet_test.dart`, `dashboard_screen_test.dart`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `AppLocalizationsEn` connect `package:flutter/material.dart` to `app_localizations_en.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `Device`, `ownedProductChanges`, `client` to the rest of the system?**
  _1743 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.013245033112582781 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.014388489208633094 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.015625 - nodes in this community are weakly interconnected._