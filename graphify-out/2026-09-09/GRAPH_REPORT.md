# Graph Report - feral-build  (2026-09-09)

## Corpus Check
- 189 files · ~106,299 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2413 nodes · 3415 edges · 140 communities (111 shown, 8 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fcf420b7`
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
- sync_entitlements_test.dart
- progress_repository.dart
- sync_push_test.dart
- first_run_offline_test.dart
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- balance_state.dart
- contentRepositoryProvider
- seed_snapshot_test.dart
- balance_test.dart
- completion_test.dart
- entitlement_repository.dart
- dashboard_screen_test.dart
- run_state_test.dart
- two_device_test.dart
- identity_repository.dart
- FeralDatabase
- run_engine_grade_test.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- AppLocalizations
- marks_test.dart
- sync_scheduler_test.dart
- delete_account_screen.dart
- package:flutter_test/flutter_test.dart
- run_state.dart
- day_log.dart
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- link_flow.dart
- revenuecat_outcome_test.dart
- pack_list_screen.dart
- completion_screen.dart
- ../../core/l10n_ext.dart
- _HomeRouterState
- dashboard_screen.dart
- purchase.dart
- auth_gateway.dart
- replace_confirm_screen.dart
- package:flutter/material.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- sign_in_restore_test.dart
- AppDelegate
- diagnostic.dart
- sign_in_from_start_test.dart
- run.dart
- run_reconciler.dart
- diagnostic_scorer_test.dart
- package:test/test.dart
- balance.dart
- ../domain/grade.dart
- link_flow_test.dart
- identity_entitlements_test.dart
- account_deletion_test.dart
- balance_state_test.dart
- email_link_test.dart
- purchase_gateway.dart
- persistence_restart_test.dart
- main.dart
- sync_state.dart
- unlock_sheet_test.dart
- auth.users
- supabase_bootstrap.dart
- StatelessWidget
- campaign.dart
- campaign_detail_screen.dart
- report_sheet.dart
- 0001_content_schema.sql
- Money path integration test
- sync_tables.dart
- entitlement.dart
- entitlement_repository_test.dart
- run_engine.dart
- backoff.dart
- email_code_screen_test.dart
- Clock
- bool get
- completion_screen_test.dart
- l10n_ext.dart
- ConnectivityGate
- List
- State
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- backoff_test.dart
- public.entitlements
- MainActivity.kt
- app
- LaunchImage.imageset/README.md
- _AppLocalizationsDelegate
- DateTime
- _buildHome

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 34 edges
2. `_HomeRouterState` - 19 edges
3. `AppLocalizations` - 18 edges
4. `DataClass` - 16 edges
5. `ContentApi` - 9 edges
6. `FakePurchaseGateway` - 9 edges
7. `Clock` - 8 edges
8. `SyncRepository` - 8 edges
9. `PurchaseGateway` - 8 edges
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

## Communities (140 total, 8 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (149): migration, schemaVersion, setWatermark, watermarkFor, class CampaignArchetypeRow extends, class DiagnosticOptionRow extends, class DiagnosticQuestionRow extends, class DiagnosticResultRow extends (+141 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (135): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+127 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.02
Nodes (124): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+116 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.05
Nodes (36): backoff, clock, _connectivity, _connectivitySub, _consecutiveFailures, consumeNotices, _current, dispose (+28 more)

### Community 4 - "home_router.dart"
Cohesion: 0.03
Nodes (58): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+50 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (53): accountApiProvider, androidKey, authGatewayProvider, campaignsByPack, clockProvider, connectivityGateProvider, content, contentRepositoryProvider (+45 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (28): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+20 more)

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
Nodes (25): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+17 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.09
Nodes (21): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+13 more)

### Community 19 - "sync_entitlements_test.dart"
Cohesion: 0.15
Nodes (12): db, entitlementRow, fetched, fetchSince, main, repoWith, rows, upsert (+4 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.08
Nodes (23): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+15 more)

### Community 21 - "sync_push_test.dart"
Cohesion: 0.06
Nodes (33): SyncRepository, SyncRunner, main, api, db, insertLocalRun, main, remoteLog (+25 more)

### Community 22 - "first_run_offline_test.dart"
Cohesion: 0.07
Nodes (28): DiagnosticRepository, actionRow, archetypeRow, db, fetchSince, main, rows, db (+20 more)

### Community 23 - "diagnostic_repository.dart"
Cohesion: 0.07
Nodes (29): campaignId, _Candidate, clock, content, db, difficulty, hasCompleted, latestFor (+21 more)

### Community 24 - "fake_purchase_gateway.dart"
Cohesion: 0.09
Nodes (22): catalogue, _changes, configure, configureCalls, currentUserId, dispose, failSwitchUser, forgetUser (+14 more)

### Community 25 - "balance_state.dart"
Cohesion: 0.17
Nodes (11): archetypes, balance, BalanceState, load, marks, marksFor, maxValue, normalizedFor (+3 more)

### Community 26 - "contentRepositoryProvider"
Cohesion: 0.16
Nodes (15): _archetypesFor, _bootstrapContent, browse, _configurePurchases, _isCampaignUnlocked, _openUnlockSheet, _openUnlockSheetFor, _restoreThenBoot (+7 more)

### Community 27 - "seed_snapshot_test.dart"
Cohesion: 0.07
Nodes (27): content, db, loadIfEmpty, SeedSnapshotLoader, ContentRepository, main, content, db (+19 more)

### Community 28 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 29 - "completion_test.dart"
Cohesion: 0.20
Nodes (9): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays (+1 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.10
Nodes (19): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+11 more)

### Community 31 - "dashboard_screen_test.dart"
Cohesion: 0.10
Nodes (20): archetypes, l10n, main, pump, state, action, archetypes, balance (+12 more)

### Community 32 - "run_state_test.dart"
Cohesion: 0.22
Nodes (8): action, berlin, campaign, log, main, run, started, stateOn

### Community 33 - "two_device_test.dart"
Cohesion: 0.10
Nodes (19): a, actionIdFor, api, b, backdate, campaignId, client, close (+11 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.10
Nodes (19): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+11 more)

### Community 35 - "FeralDatabase"
Cohesion: 0.07
Nodes (33): _, @DriftDatabase, FeralDatabase, ProgressRepository, db, ddl, main, probe (+25 more)

### Community 36 - "run_engine_grade_test.dart"
Cohesion: 0.17
Nodes (11): engine, log, main, misses, engine, log, main, package:feral/src/domain/day_log.dart (+3 more)

### Community 37 - "settings_screen_test.dart"
Cohesion: 0.06
Nodes (32): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+24 more)

### Community 38 - "reminder_scheduler.dart"
Cohesion: 0.11
Nodes (18): disable, enable, _enabledKey, _hourKey, isEnabled, LocalReminderScheduler, _minuteKey, _notificationId (+10 more)

### Community 39 - "identity_repository_test.dart"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "AppLocalizations"
Cohesion: 0.10
Nodes (21): AppLocalizations, AppLocalizationsEn, of, l10n, main, pair, questions, entries (+13 more)

### Community 41 - "marks_test.dart"
Cohesion: 0.17
Nodes (10): earnedFor, main, marks, run, targets, main, run, package:feral/src/domain/run.dart (+2 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.11
Nodes (18): calls, consumeNotices, _controller, delay, dispose, gate, goOffline, goOnline (+10 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (17): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+9 more)

### Community 44 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.07
Nodes (29): main, dismissals, links, main, pump, cancels, chosen, main (+21 more)

### Community 45 - "run_state.dart"
Cohesion: 0.12
Nodes (16): campaign, currentDay, derive, grade, isCommittedToday, isFinalDay, isFinished, isReportedToday (+8 more)

### Community 46 - "day_log.dart"
Cohesion: 0.18
Nodes (10): actionId, committedAt, dayIndex, DayLog, id, isReported, note, outcome (+2 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.10
Nodes (20): AppleCredentials, _body, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor (+12 more)

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

### Community 52 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 53 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "pack_list_screen.dart"
Cohesion: 0.14
Nodes (12): toAction, toCampaign, Pack, build, campaigns, isUnlocked, pack, PackListScreen (+4 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (15): build, campaign, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey, marksEarned (+7 more)

### Community 56 - "../../core/l10n_ext.dart"
Cohesion: 0.20
Nodes (9): build, onContinue, onSignIn, signInKey, build, onAccept, PrivacyNoticeScreen, ../../core/l10n_ext.dart (+1 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.13
Nodes (19): accountApiProvider, _dismissLinkPrompt, HomeRouter, _HomeRouterState, _homeScreen, _linkWithEmail, _openDeleteAccount, _openDoctrine (+11 more)

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
Cohesion: 0.12
Nodes (14): appName, Brand, colorSeed, theme, build, dismissKey, _message, messageKey (+6 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.14
Nodes (13): ../app/balance_state.dart, build, fillColor, gridColor, paint, _RadarPainter, shouldRepaint, size (+5 more)

### Community 65 - "sign_in_restore_test.dart"
Cohesion: 0.10
Nodes (19): auth, consumeNotices, db, gate, l10n, main, now, prefs (+11 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "diagnostic.dart"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 68 - "sign_in_from_start_test.dart"
Cohesion: 0.06
Nodes (35): ../app/app_sync_wiring_test.dart, SyncScheduler, auth, db, fetchSince, gate, main, prefs (+27 more)

### Community 69 - "run.dart"
Cohesion: 0.15
Nodes (12): campaignId, completedAt, fromKey, grade, id, isHardened, key, RunStatus (+4 more)

### Community 70 - "run_reconciler.dart"
Cohesion: 0.15
Nodes (11): CampaignRun, earned, MarkCalculator, abandon, isConflict, keep, localSurvived, Reconciliation (+3 more)

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "package:test/test.dart"
Cohesion: 0.22
Nodes (8): berlin, day1, db, main, repoAt, main, package:feral/src/domain/outcome.dart, package:test/test.dart

### Community 73 - "balance.dart"
Cohesion: 0.17
Nodes (11): BalanceCalculator, BalanceWeights, baseFor, compute, done, halfLifeDays, _localDate, partial (+3 more)

### Community 74 - "../domain/grade.dart"
Cohesion: 0.17
Nodes (10): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, gradeName, outcomeLabel, ../domain/grade.dart (+2 more)

### Community 75 - "link_flow_test.dart"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "identity_entitlements_test.dart"
Cohesion: 0.22
Nodes (8): SignedIn, auth, db, main, ownedRow, purchases, repo, package:feral/src/data/repositories/identity_repository.dart

### Community 77 - "account_deletion_test.dart"
Cohesion: 0.12
Nodes (15): AccountDeletionFailed, PackLocked, IdentityAlreadyAttached, api, auth, calls, db, deleteAccount (+7 more)

### Community 78 - "balance_state_test.dart"
Cohesion: 0.22
Nodes (8): actions, archetypes, berlin, build, log, main, run, start

### Community 79 - "email_link_test.dart"
Cohesion: 0.11
Nodes (18): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+10 more)

### Community 80 - "purchase_gateway.dart"
Cohesion: 0.18
Nodes (10): configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, restore, switchUser (+2 more)

### Community 81 - "persistence_restart_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, dbFile, dir, main, open, Directory, package:feral/src/app/run_state.dart

### Community 82 - "main.dart"
Cohesion: 0.09
Nodes (20): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, _key (+12 more)

### Community 83 - "sync_state.dart"
Cohesion: 0.22
Nodes (8): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, SyncStatus, ../domain/sync_status.dart, providers.dart

### Community 84 - "unlock_sheet_test.dart"
Cohesion: 0.10
Nodes (19): allText, arm, cancels, deleted, main, pump, serverSucceeds, buys (+11 more)

### Community 85 - "auth.users"
Cohesion: 0.29
Nodes (10): auth.users, public.actions, public.campaigns, public.packs, public.campaign_runs, public.day_logs, public.diagnostic_results, public.entitlements (+2 more)

### Community 86 - "supabase_bootstrap.dart"
Cohesion: 0.07
Nodes (29): OfflineApi, _client, ContentApi, fetchSince, SupabaseContentApi, _client, _conflictTargets, fetchSince (+21 more)

### Community 87 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): CompletionScreen, ArchetypeRadar, DashboardScreen, LinkSheet, DoctrineIntroScreen, UnlockSheet, _SectionHeading, StatelessWidget

### Community 88 - "campaign.dart"
Cohesion: 0.05
Nodes (35): ActionSpec, archetypeId, bodyMd, campaignId, dayIndex, difficulty, effort, id (+27 more)

### Community 89 - "campaign_detail_screen.dart"
Cohesion: 0.18
Nodes (10): Campaign, build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance, onStart (+2 more)

### Community 90 - "report_sheet.dart"
Cohesion: 0.29
Nodes (7): build, _controller, createState, dispose, outcome, ReportSheet, _ReportSheetState

### Community 91 - "0001_content_schema.sql"
Cohesion: 0.38
Nodes (8): public, public.actions, public.archetypes, public.campaign_archetypes, public.campaigns, public.doctrine_entries, public.doctrine_groups, public.packs

### Community 92 - "Money path integration test"
Cohesion: 0.25
Nodes (9): Feral CI Workflow, CI database job (supabase test db, pgTAP), CI functions job (Edge Function type-check and test), Headless Linux runner has no device target, Money path integration test, Two-device integration test, RevenueCat webhook mapping test, purchases_flutter (RevenueCat) integration (+1 more)

### Community 94 - "sync_tables.dart"
Cohesion: 0.22
Nodes (8): lastPulledAt, primaryKey, SyncState, syncTable, watermark, DateTimeColumn get, Set, TextColumn get

### Community 95 - "entitlement.dart"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 96 - "entitlement_repository_test.dart"
Cohesion: 0.14
Nodes (13): NoStoreGateway, PurchaseGateway, RevenueCatGateway, EntitlementRepository, core, db, edge, gateway (+5 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.22
Nodes (8): currentDay, daysNeedingMissed, grade, missAllowance, missCount, RunEngine, ../domain/day_log.dart, grade_thresholds.dart

### Community 98 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 99 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 100 - "Clock"
Cohesion: 0.47
Nodes (5): Clock, FixedClock, _instant, nowUtc, SystemClock

### Community 101 - "bool get"
Cohesion: 0.18
Nodes (9): earnsMark, fromKey, Grade, key, fromKey, isMiss, key, Outcome (+1 more)

### Community 102 - "completion_screen_test.dart"
Cohesion: 0.14
Nodes (12): core, edge, free, main, paid, views, campaign, killer (+4 more)

### Community 103 - "l10n_ext.dart"
Cohesion: 0.33
Nodes (5): l10n, L10nContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 104 - "ConnectivityGate"
Cohesion: 0.67
Nodes (3): ConnectivityGate, ConnectivityPlusGate, FakeGate

### Community 105 - "List"
Cohesion: 0.12
Nodes (15): SyncNoticeNotifier, build, DoctrineListScreen, entriesByGroup, groups, build, _choose, createState (+7 more)

### Community 106 - "State"
Cohesion: 0.27
Nodes (10): EmailCodeScreen, _EmailCodeScreenState, DiagnosticScreen, _DiagnosticScreenState, DeleteAccountScreen, _DeleteAccountScreenState, SettingsScreen, _SettingsScreenState (+2 more)

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 112 - "backoff_test.dart"
Cohesion: 0.50
Nodes (3): b, main, package:feral/src/engine/backoff.dart

### Community 136 - "DateTime"
Cohesion: 0.29
Nodes (6): kind, message, occurredAt, SyncNotice, SyncNoticeKind, DateTime

### Community 137 - "_buildHome"
Cohesion: 0.47
Nodes (6): balance, _buildHome, _startRun, clockProvider, progressRepositoryProvider, zoneProvider

## Knowledge Gaps
- **1650 isolated node(s):** `localeName`, `delegate`, `localizationsDelegates`, `supportedLocales`, `commitButton` (+1645 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1850 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `FeralDatabase` to `database.dart`, `providers.dart`, `sync_repository.dart`, `money_path_test.dart`, `content_repository.dart`, `purchase_controller_test.dart`, `sync_entitlements_test.dart`, `progress_repository.dart`, `sync_push_test.dart`, `first_run_offline_test.dart`, `diagnostic_repository.dart`, `seed_snapshot_test.dart`, `completion_test.dart`, `entitlement_repository.dart`, `two_device_test.dart`, `identity_repository.dart`, `identity_repository_test.dart`, `sign_in_from_start_test.dart`, `package:test/test.dart`, `link_flow_test.dart`, `identity_entitlements_test.dart`, `account_deletion_test.dart`, `entitlement_repository_test.dart`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `AppLocalizations` to `app_localizations.dart`, `sign_in_restore_test.dart`, `settings_screen_test.dart`, `completion_screen_test.dart`, `_AppLocalizationsDelegate`, `browse_screen_test.dart`, `unlock_sheet_test.dart`, `dashboard_screen_test.dart`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `PurchaseOutcome` connect `revenuecat_outcome_test.dart` to `fake_purchase_gateway.dart`, `purchase.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **What connects `localeName`, `delegate`, `localizationsDelegates` to the rest of the system?**
  _1650 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.013333333333333334 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.014705882352941176 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.016 - nodes in this community are weakly interconnected._