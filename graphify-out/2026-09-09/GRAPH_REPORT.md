# Graph Report - feral-build  (2026-09-09)

## Corpus Check
- 187 files · ~102,505 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2319 nodes · 3262 edges · 136 communities (115 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `84fdf50b`
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
- browse_screen_test.dart
- DataClass
- user_tables.dart
- money_path_test.dart
- package:timezone/timezone.dart
- settings_screen.dart
- content_repository.dart
- purchase_controller_test.dart
- identity.dart
- diagnostic_result_screen.dart
- sync_push_test.dart
- progress_repository.dart
- sync_reconcile_test.dart
- first_run_offline_test.dart
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- balance_state.dart
- contentRepositoryProvider
- seed_snapshot_test.dart
- generate_seed_snapshot.dart
- marks_test.dart
- entitlement_repository.dart
- dashboard_screen_test.dart
- ../support/pump.dart
- two_device_test.dart
- identity_repository.dart
- FeralDatabase
- package:test/test.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- package:feral/l10n/app_localizations.dart
- campaign.dart
- sync_scheduler_test.dart
- delete_account_screen.dart
- replace_confirm_screen_test.dart
- run_state.dart
- day_log.dart
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- settings_restore_test.dart
- revenuecat_outcome_test.dart
- pack_list_screen.dart
- completion_screen.dart
- ../core/l10n_ext.dart
- _HomeRouterState
- dashboard_screen.dart
- purchase.dart
- auth_gateway.dart
- replace_confirm_screen.dart
- package:flutter/material.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- package:feral/src/core/clock.dart
- sync_state.dart
- diagnostic.dart
- app_sync_wiring_test.dart
- run.dart
- run_reconciler.dart
- diagnostic_scorer_test.dart
- account_api.dart
- balance.dart
- ../domain/grade.dart
- link_flow_test.dart
- package:flutter_test/flutter_test.dart
- account_deletion_test.dart
- balance_test.dart
- email_link_test.dart
- purchase_gateway.dart
- diagnostic_scorer.dart
- diagnostic_repository_test.dart
- StatelessWidget
- unlock_sheet_test.dart
- auth.users
- supabase_bootstrap.dart
- link_flow.dart
- doctrine.dart
- String?
- report_sheet.dart
- 0001_content_schema.sql
- Money path integration test
- pack_views_test.dart
- sync_tables.dart
- entitlement.dart
- balance_state_test.dart
- run_engine.dart
- completion_test.dart
- email_code_screen_test.dart
- DateTime
- _boot
- completion_screen_test.dart
- l10n_ext.dart
- ConnectivityGate
- List
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- public.entitlements
- run_state_test.dart
- content_repository_test.dart
- persistence_restart_test.dart
- delete_account_screen_test.dart
- sync_status.dart
- _buildHome
- ../domain/pack.dart

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 30 edges
2. `_HomeRouterState` - 19 edges
3. `AppLocalizations` - 17 edges
4. `DataClass` - 16 edges
5. `FakePurchaseGateway` - 9 edges
6. `SyncRepository` - 8 edges
7. `ContentRepository` - 7 edges
8. `_buildHome` - 7 edges
9. `Clock` - 7 edges
10. `PurchaseGateway` - 7 edges

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

## Communities (136 total, 4 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (149): migration, schemaVersion, setWatermark, watermarkFor, class CampaignArchetypeRow extends, class DiagnosticOptionRow extends, class DiagnosticQuestionRow extends, class DiagnosticResultRow extends (+141 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.02
Nodes (128): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+120 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.02
Nodes (117): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+109 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.06
Nodes (33): backoff, clock, _connectivity, _connectivitySub, _consecutiveFailures, consumeNotices, _current, dispose (+25 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (53): build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState, dispose (+45 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (53): accountApiProvider, androidKey, authGatewayProvider, campaignsByPack, clockProvider, connectivityGateProvider, content, contentRepositoryProvider (+45 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (30): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+22 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (38): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+30 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.06
Nodes (33): archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayIndex, description (+25 more)

### Community 9 - "browse_screen_test.dart"
Cohesion: 0.08
Nodes (23): core, edge, main, resolver, unlocked, unpriced, corePack, killer (+15 more)

### Community 10 - "DataClass"
Cohesion: 0.11
Nodes (33): Insertable, UpdateCompanion, ActionRow, ActionsCompanion, ArchetypeRow, ArchetypesCompanion, CampaignArchetypeRow, CampaignArchetypesCompanion (+25 more)

### Community 11 - "user_tables.dart"
Cohesion: 0.06
Nodes (30): acquiredAt, actionId, campaignId, committedAt, completedAt, dayIndex, dirty, displayName (+22 more)

### Community 12 - "money_path_test.dart"
Cohesion: 0.07
Nodes (29): actionIdFor, client, close, configure, content, db, Device, entitlements (+21 more)

### Community 13 - "package:timezone/timezone.dart"
Cohesion: 0.17
Nodes (10): deviceZone, info, berlin, dayFor, engine, losAngeles, main, package:flutter_timezone/flutter_timezone.dart (+2 more)

### Community 14 - "settings_screen.dart"
Cohesion: 0.07
Nodes (28): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+20 more)

### Community 15 - "content_repository.dart"
Cohesion: 0.07
Nodes (27): actionFor, actionsFor, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById, _at (+19 more)

### Community 16 - "purchase_controller_test.dart"
Cohesion: 0.10
Nodes (24): buy, entitlements, gateway, packId, PurchaseComplete, PurchaseController, PurchaseIdle, PurchaseInProgress (+16 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (26): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+18 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.09
Nodes (21): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+13 more)

### Community 19 - "sync_push_test.dart"
Cohesion: 0.08
Nodes (23): db, entitlementRow, fetched, fetchSince, main, repoWith, rows, upsert (+15 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.08
Nodes (23): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+15 more)

### Community 21 - "sync_reconcile_test.dart"
Cohesion: 0.10
Nodes (20): SyncRepository, SyncRunner, api, db, insertLocalRun, main, remoteLog, sync (+12 more)

### Community 22 - "first_run_offline_test.dart"
Cohesion: 0.18
Nodes (10): api, at, attempts, berlin, content, db, fetchSince, main (+2 more)

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
Cohesion: 0.19
Nodes (15): _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked, _linkWithEmail, _openDoctrine, _openSettings, _openUnlockSheet (+7 more)

### Community 27 - "seed_snapshot_test.dart"
Cohesion: 0.12
Nodes (15): content, db, loadIfEmpty, SeedSnapshotLoader, ContentRepository, content, db, fetchSince (+7 more)

### Community 28 - "generate_seed_snapshot.dart"
Cohesion: 0.15
Nodes (12): main, close, connection, file, main, snapshot, tables, writeAsString (+4 more)

### Community 29 - "marks_test.dart"
Cohesion: 0.15
Nodes (11): earnedFor, main, marks, run, targets, main, run, package:feral/src/domain/grade.dart (+3 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.11
Nodes (18): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+10 more)

### Community 31 - "dashboard_screen_test.dart"
Cohesion: 0.10
Nodes (19): archetypes, l10n, main, pump, state, action, archetypes, balance (+11 more)

### Community 32 - "../support/pump.dart"
Cohesion: 0.17
Nodes (11): dismissals, links, main, pump, main, pump, completion_screen_test.dart, ModalBarrier (+3 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.08
Nodes (24): a, actionIdFor, api, b, backdate, campaignId, client, close (+16 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.10
Nodes (19): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+11 more)

### Community 35 - "FeralDatabase"
Cohesion: 0.07
Nodes (34): _, @DriftDatabase, FeralDatabase, db, ddl, main, probe, raw (+26 more)

### Community 36 - "package:test/test.dart"
Cohesion: 0.12
Nodes (16): main, b, main, engine, log, main, misses, engine (+8 more)

### Community 37 - "settings_screen_test.dart"
Cohesion: 0.10
Nodes (19): disable, enable, enabled, isEnabled, l10n, main, offeredTime, permissionGranted (+11 more)

### Community 38 - "reminder_scheduler.dart"
Cohesion: 0.11
Nodes (18): disable, enable, _enabledKey, _hourKey, isEnabled, LocalReminderScheduler, _minuteKey, _notificationId (+10 more)

### Community 39 - "identity_repository_test.dart"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "package:feral/l10n/app_localizations.dart"
Cohesion: 0.15
Nodes (12): wrap, l10n, main, pair, questions, l10n, main, package:feral/l10n/app_localizations.dart (+4 more)

### Community 41 - "campaign.dart"
Cohesion: 0.11
Nodes (17): ActionSpec, archetypeId, bodyMd, campaignId, dayIndex, difficulty, effort, id (+9 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.11
Nodes (17): SyncScheduler, calls, consumeNotices, _controller, dispose, gate, goOffline, goOnline (+9 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (19): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+11 more)

### Community 44 - "replace_confirm_screen_test.dart"
Cohesion: 0.12
Nodes (15): cancels, chosen, main, pump, allText, cancels, confirms, main (+7 more)

### Community 45 - "run_state.dart"
Cohesion: 0.12
Nodes (16): campaign, currentDay, derive, grade, isCommittedToday, isFinalDay, isFinished, isReportedToday (+8 more)

### Community 46 - "day_log.dart"
Cohesion: 0.12
Nodes (15): actionId, committedAt, dayIndex, DayLog, id, isReported, note, outcome (+7 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.12
Nodes (16): AppleCredentials, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor, labelFor (+8 more)

### Community 48 - "unlock_sheet.dart"
Cohesion: 0.12
Nodes (16): build, _busy, buyKey, campaigns, closeKey, onBuy, onClose, onRestore (+8 more)

### Community 49 - "mapping.ts"
Cohesion: 0.16
Nodes (11): RFC-4122, ADR-0017, ADR-0019, asProductId(), asUserId(), asUserIds(), planWrites(), ADR-0017 (+3 more)

### Community 50 - "@DataClassName"
Cohesion: 0.23
Nodes (16): @DataClassName, Actions, Archetypes, CampaignArchetypes, Campaigns, DiagnosticOptions, DiagnosticQuestions, DoctrineEntries (+8 more)

### Community 51 - "revenuecat_gateway.dart"
Cohesion: 0.12
Nodes (15): apiKey, _changes, configure, _configured, forgetUser, outcomeForErrorCode, _ownedFrom, ownedProductChanges (+7 more)

### Community 52 - "settings_restore_test.dart"
Cohesion: 0.15
Nodes (13): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+5 more)

### Community 53 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "pack_list_screen.dart"
Cohesion: 0.14
Nodes (12): toAction, toCampaign, Pack, build, campaigns, isUnlocked, pack, PackListScreen (+4 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (15): build, campaign, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey, marksEarned (+7 more)

### Community 56 - "../core/l10n_ext.dart"
Cohesion: 0.11
Nodes (17): build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance, onStart, onUnlock (+9 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.15
Nodes (16): accountApiProvider, _bootstrapContent, _dismissLinkPrompt, HomeRouter, _HomeRouterState, _homeScreen, _openDeleteAccount, _openLinkFlow (+8 more)

### Community 58 - "dashboard_screen.dart"
Cohesion: 0.13
Nodes (14): RunState, balance, banner, build, onCommit, onOpenDoctrine, onOpenSettings, _report (+6 more)

### Community 59 - "purchase.dart"
Cohesion: 0.18
Nodes (10): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+2 more)

### Community 60 - "auth_gateway.dart"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "replace_confirm_screen.dart"
Cohesion: 0.13
Nodes (13): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+5 more)

### Community 62 - "package:flutter/material.dart"
Cohesion: 0.10
Nodes (19): Backoff, base, delayFor, max, standard, appName, Brand, colorSeed (+11 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.14
Nodes (13): ../app/balance_state.dart, build, fillColor, gridColor, paint, _RadarPainter, shouldRepaint, size (+5 more)

### Community 65 - "package:feral/src/core/clock.dart"
Cohesion: 0.17
Nodes (10): EntitlementRepository, main, core, db, edge, gateway, main, repo (+2 more)

### Community 66 - "sync_state.dart"
Cohesion: 0.25
Nodes (7): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, ../domain/sync_status.dart, providers.dart

### Community 67 - "diagnostic.dart"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 68 - "app_sync_wiring_test.dart"
Cohesion: 0.05
Nodes (38): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, _key (+30 more)

### Community 69 - "run.dart"
Cohesion: 0.11
Nodes (16): earnsMark, fromKey, Grade, key, campaignId, completedAt, fromKey, grade (+8 more)

### Community 70 - "run_reconciler.dart"
Cohesion: 0.15
Nodes (11): CampaignRun, earned, MarkCalculator, abandon, isConflict, keep, localSurvived, Reconciliation (+3 more)

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "account_api.dart"
Cohesion: 0.18
Nodes (11): AccountApi, AccountDeletionFailed, _client, deleteAccount, message, SupabaseAccountApi, toString, PackLocked (+3 more)

### Community 73 - "balance.dart"
Cohesion: 0.17
Nodes (11): BalanceCalculator, BalanceWeights, baseFor, compute, done, halfLifeDays, _localDate, partial (+3 more)

### Community 74 - "../domain/grade.dart"
Cohesion: 0.17
Nodes (10): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, gradeName, outcomeLabel, ../domain/grade.dart (+2 more)

### Community 75 - "link_flow_test.dart"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.17
Nodes (10): main, entries, groups, l10n, main, package:feral/src/app/link_prompt_state.dart, package:feral/src/domain/doctrine.dart, package:feral/src/ui/doctrine/doctrine_entry_screen.dart (+2 more)

### Community 77 - "account_deletion_test.dart"
Cohesion: 0.09
Nodes (23): NoStoreGateway, PurchaseGateway, RevenueCatGateway, api, auth, calls, db, deleteAccount (+15 more)

### Community 78 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 79 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

### Community 80 - "purchase_gateway.dart"
Cohesion: 0.18
Nodes (10): configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, restore, switchUser (+2 more)

### Community 81 - "diagnostic_scorer.dart"
Cohesion: 0.25
Nodes (7): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, ../domain/diagnostic.dart

### Community 82 - "diagnostic_repository_test.dart"
Cohesion: 0.18
Nodes (10): DiagnosticRepository, db, fetchSince, main, now, repo, seedArchetype, seedCampaign (+2 more)

### Community 83 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): CompletionScreen, ArchetypeRadar, DashboardScreen, LinkSheet, DiagnosticResultScreen, UnlockSheet, _SectionHeading, StatelessWidget

### Community 84 - "unlock_sheet_test.dart"
Cohesion: 0.13
Nodes (15): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, of, buys, campaigns, closes, edge (+7 more)

### Community 85 - "auth.users"
Cohesion: 0.29
Nodes (10): auth.users, public.actions, public.campaigns, public.packs, public.campaign_runs, public.day_logs, public.diagnostic_results, public.entitlements (+2 more)

### Community 86 - "supabase_bootstrap.dart"
Cohesion: 0.07
Nodes (28): OfflineApi, _client, ContentApi, fetchSince, SupabaseContentApi, _client, _conflictTargets, fetchSince (+20 more)

### Community 87 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 88 - "doctrine.dart"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineEntry, DoctrineGroup, groupId, id, relatedArchetypeId, sort (+1 more)

### Community 89 - "String?"
Cohesion: 0.20
Nodes (9): coverPath, description, id, isCore, key, sort, storeProductId, title (+1 more)

### Community 90 - "report_sheet.dart"
Cohesion: 0.18
Nodes (13): build, _controller, createState, dispose, outcome, ReportSheet, _ReportSheetState, DiagnosticScreen (+5 more)

### Community 91 - "0001_content_schema.sql"
Cohesion: 0.38
Nodes (8): public, public.actions, public.archetypes, public.campaign_archetypes, public.campaigns, public.doctrine_entries, public.doctrine_groups, public.packs

### Community 92 - "Money path integration test"
Cohesion: 0.25
Nodes (9): Feral CI Workflow, CI database job (supabase test db, pgTAP), CI functions job (Edge Function type-check and test), Headless Linux runner has no device target, Money path integration test, Two-device integration test, RevenueCat webhook mapping test, purchases_flutter (RevenueCat) integration (+1 more)

### Community 93 - "pack_views_test.dart"
Cohesion: 0.25
Nodes (7): core, edge, free, main, paid, views, package:feral/src/domain/campaign.dart

### Community 94 - "sync_tables.dart"
Cohesion: 0.22
Nodes (8): lastPulledAt, primaryKey, SyncState, syncTable, watermark, DateTimeColumn get, Set, TextColumn get

### Community 95 - "entitlement.dart"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 96 - "balance_state_test.dart"
Cohesion: 0.22
Nodes (8): actions, archetypes, berlin, build, log, main, run, start

### Community 97 - "run_engine.dart"
Cohesion: 0.22
Nodes (8): currentDay, daysNeedingMissed, grade, missAllowance, missCount, RunEngine, ../domain/day_log.dart, grade_thresholds.dart

### Community 98 - "completion_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays

### Community 99 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 100 - "DateTime"
Cohesion: 0.38
Nodes (6): Clock, FixedClock, _instant, nowUtc, SystemClock, DateTime

### Community 101 - "_boot"
Cohesion: 0.50
Nodes (4): _boot, _syncSoon, diagnosticRepositoryProvider, syncSchedulerProvider

### Community 102 - "completion_screen_test.dart"
Cohesion: 0.29
Nodes (6): campaign, killer, l10n, main, pump, package:feral/src/domain/archetype.dart

### Community 103 - "l10n_ext.dart"
Cohesion: 0.33
Nodes (5): l10n, L10nContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 104 - "ConnectivityGate"
Cohesion: 0.67
Nodes (3): ConnectivityGate, ConnectivityPlusGate, FakeGate

### Community 105 - "List"
Cohesion: 0.12
Nodes (15): SyncNoticeNotifier, build, DoctrineListScreen, entriesByGroup, groups, build, _choose, createState (+7 more)

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 131 - "run_state_test.dart"
Cohesion: 0.22
Nodes (8): action, berlin, campaign, log, main, run, started, stateOn

### Community 132 - "content_repository_test.dart"
Cohesion: 0.15
Nodes (12): SilentContentApi, actionRow, archetypeRow, db, FakeContentApi, fetchSince, main, rows (+4 more)

### Community 133 - "persistence_restart_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, dbFile, dir, main, open, Directory, package:feral/src/app/run_state.dart

### Community 135 - "delete_account_screen_test.dart"
Cohesion: 0.22
Nodes (8): allText, arm, cancels, deleted, main, pump, serverSucceeds, package:feral/src/ui/settings/delete_account_screen.dart

### Community 136 - "sync_status.dart"
Cohesion: 0.29
Nodes (6): kind, message, occurredAt, SyncNotice, SyncNoticeKind, SyncStatus

### Community 137 - "_buildHome"
Cohesion: 0.47
Nodes (6): balance, _buildHome, _startRun, clockProvider, progressRepositoryProvider, zoneProvider

### Community 138 - "../domain/pack.dart"
Cohesion: 0.40
Nodes (4): EntitlementResolver, isUnlocked, unlockedPackIds, ../domain/pack.dart

## Knowledge Gaps
- **1590 isolated node(s):** `_ContentTable`, `db`, `api`, `_tables`, `name` (+1585 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1780 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `FeralDatabase` to `database.dart`, `providers.dart`, `sync_repository.dart`, `money_path_test.dart`, `purchase_controller_test.dart`, `sync_push_test.dart`, `progress_repository.dart`, `sync_reconcile_test.dart`, `first_run_offline_test.dart`, `diagnostic_repository.dart`, `seed_snapshot_test.dart`, `two_device_test.dart`, `identity_repository.dart`, `identity_repository_test.dart`, `package:feral/src/core/clock.dart`, `link_flow_test.dart`, `account_deletion_test.dart`, `diagnostic_repository_test.dart`, `completion_test.dart`?**
  _High betweenness centrality (0.096) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `unlock_sheet_test.dart` to `app_localizations.dart`, `settings_screen_test.dart`, `completion_screen_test.dart`, `package:feral/l10n/app_localizations.dart`, `browse_screen_test.dart`, `package:flutter_test/flutter_test.dart`, `settings_restore_test.dart`, `dashboard_screen_test.dart`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `_ContentTable`, `db`, `api` to the rest of the system?**
  _1590 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.013333333333333334 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.015503875968992248 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.01694915254237288 - nodes in this community are weakly interconnected._
- **Should `sync_scheduler.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._