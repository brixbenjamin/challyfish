# Graph Report - feral-build  (2026-09-11)

## Corpus Check
- 237 files · ~157,272 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3155 nodes · 4323 edges · 191 communities (156 shown, 13 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `76092101`
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
- Key Syntax Differences and Pitfalls
- settings_screen.dart
- content_repository.dart
- purchase_state.dart
- identity.dart
- diagnostic_result_screen.dart
- sync_push_test.dart
- progress_repository.dart
- day_log_action_sync_test.dart
- Compiling C Code into Code Assets with Native Assets Hooks
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- balance_state.dart
- contentRepositoryProvider
- generate_seed_snapshot.dart
- settings_restore_test.dart
- ../core/l10n_ext.dart
- entitlement_repository.dart
- package:flutter_test/flutter_test.dart
- main.dart
- two_device_test.dart
- identity_repository.dart
- package:test/test.dart
- email_link_test.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- day_log.dart
- 2. Syntax Reference
- sync_scheduler_test.dart
- delete_account_screen.dart
- ../support/pump.dart
- run_state.dart
- SilentProgressApi
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- balance_test.dart
- revenuecat_outcome_test.dart
- sign_in_restore_test.dart
- completion_screen.dart
- Generating FFI Bindings using package:ffigen
- _HomeRouterState
- dashboard_screen.dart
- Internationalizing Flutter Applications
- auth_gateway.dart
- unlock_refreshes_detail_test.dart
- package:timezone/timezone.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- balance_state_test.dart
- AppDelegate
- diagnostic.dart
- Implementing Routing and Deep Linking
- run.dart
- run_reconciler.dart
- diagnostic_scorer_test.dart
- String?
- balance.dart
- grade_thresholds.dart
- link_flow_test.dart
- package:feral/src/domain/outcome.dart
- paid_content_boundary_test.dart
- diagnostic_repository_test.dart
- Implementing Dart and Flutter Test Coverage
- purchase_gateway.dart
- Writing Dart API Documentation
- public.action_bodies
- Building Dart CLI Applications
- unlock_sheet_test.dart
- auth.users
- Implementing Dart Patterns
- Resolving Dart Static Analysis Errors
- campaign.dart
- campaign_detail_screen.dart
- _ArchetypeRadarState
- 0001_content_schema.sql
- Money path integration test
- Architecting Flutter Applications
- sync_tables.dart
- Clock
- dashboard_screen_test.dart
- run_engine.dart
- link_prompt_state.dart
- email_code_screen_test.dart
- package:feral/src/core/clock.dart
- Testing and Mocking Dart Applications
- Implementing Flutter Integration Tests
- tokens.dart
- diagnostic_screen.dart
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- private.action_body_readable
- Previewing Flutter Widgets
- Testing Dart and Flutter Applications
- MainActivity.kt
- Managing Dart Dependencies
- app
- LaunchImage.imageset/README.md
- Implementing Adaptive Layouts
- purchase_controller_test.dart
- Analyzing and Fixing Dart Code
- Writing Flutter Widget Tests
- pack.dart
- Resolving Flutter Layout Errors
- Serializing JSON Manually in Flutter
- Using Examples in Dartdoc
- Implementing Flutter Networking
- purchase_delivery_test.dart
- replace_confirm_screen.dart
- theme_context.dart
- purchase.dart
- entitlement.dart
- theme.dart
- supabase_bootstrap.dart
- backoff.dart
- body_purge_test.dart
- State
- run_state_test.dart
- balance_summary.dart
- dart:async
- package:supabase_flutter/supabase_flutter.dart
- l10n_ext.dart
- link_flow.dart
- dart:io
- first_run_offline_test.dart
- bool get
- ConnectivityGate
- report_sheet.dart
- _AppLocalizationsDelegate
- ../domain/campaign.dart
- _RadarLayout
- _RadarPainter
- completion_test.dart
- ../../domain/run.dart
- SyncRunner
- List
- backoff_test.dart
- seed_snapshot.dart
- sync_state.dart
- account_api.dart
- pack_views_test.dart
- diagnostic_scorer.dart
- sync_status.dart
- Map
- _buildHome
- progress_repository_test.dart
- ContentApi
- package:timezone/data/latest.dart
- PackLocked
- RunState?

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 27 edges
2. `_HomeRouterState` - 19 edges
3. `DataClass` - 18 edges
4. `AppLocalizations` - 16 edges
5. `Key Syntax Differences and Pitfalls` - 11 edges
6. `Migrating Dart Tests to Package Checks` - 10 edges
7. `SyncRepository` - 10 edges
8. `Compiling C Code into Code Assets with Native Assets Hooks` - 10 edges
9. `ContentApi` - 9 edges
10. `ProgressApi` - 9 edges

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

## Communities (191 total, 13 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (155): backfillDayLogActions, clearWatermark, migration, schemaVersion, setWatermark, watermarkFor, class CampaignArchetypeRow extends, class DiagnosticOptionRow extends (+147 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (159): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+151 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (148): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+140 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.06
Nodes (32): backoff, clock, _connectivity, _connectivitySub, _consecutiveFailures, consumeNotices, _current, dispose (+24 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (54): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+46 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (51): accountApiProvider, androidKey, authGatewayProvider, campaignsByPack, clockProvider, connectivityGateProvider, content, contentRepositoryProvider (+43 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (28): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+20 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (40): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+32 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.06
Nodes (35): actionId, archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayIndex (+27 more)

### Community 9 - "package:flutter/material.dart"
Cohesion: 0.07
Nodes (34): AppLocalizations, AppLocalizationsEn, of, wrap, corePack, killer, l10n, long (+26 more)

### Community 10 - "DataClass"
Cohesion: 0.10
Nodes (37): Insertable, UpdateCompanion, ActionBodiesCompanion, ActionBodyRow, ActionRow, ActionsCompanion, ArchetypeRow, ArchetypesCompanion (+29 more)

### Community 11 - "user_tables.dart"
Cohesion: 0.06
Nodes (31): acquiredAt, actionId, campaignId, committedAt, completed, completedAt, dayIndex, dirty (+23 more)

### Community 12 - "money_path_test.dart"
Cohesion: 0.07
Nodes (28): actionIdFor, client, close, configure, content, db, Device, entitlements (+20 more)

### Community 13 - "Key Syntax Differences and Pitfalls"
Cohesion: 0.05
Nodes (37): 10. Dynamic Map / JSON Lookup Casting, 1. Collection Equality Pitfall (`equals` vs `deepEquals`), 1. Dependency Setup, 1. Simple Custom Expectations (using `expect`), 1. Specific Error Matchers, 2. Identify and Plan Target Files, 2. Nested Property Extraction (using `nest` or `has`), 2. The `anything` Matcher (+29 more)

### Community 14 - "settings_screen.dart"
Cohesion: 0.07
Nodes (28): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+20 more)

### Community 15 - "content_repository.dart"
Cohesion: 0.06
Nodes (30): actionFor, actionsFor, actionsForDay, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById (+22 more)

### Community 16 - "purchase_state.dart"
Cohesion: 0.11
Nodes (23): buy, clock, content, _deliver, entitlements, gateway, packId, PurchaseComplete (+15 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (26): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+18 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.08
Nodes (22): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+14 more)

### Community 19 - "sync_push_test.dart"
Cohesion: 0.06
Nodes (32): OfflineApi, ProgressApi, _SilentProgressApi, SilentProgressApi, FakeProgressApi, main, db, entitlementRow (+24 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.07
Nodes (26): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+18 more)

### Community 21 - "day_log_action_sync_test.dart"
Cohesion: 0.08
Nodes (28): SyncRepository, api, db, insertLocalLog, insertLocalRun, insertLocalTick, remoteTick, sync (+20 more)

### Community 22 - "Compiling C Code into Code Assets with Native Assets Hooks"
Cohesion: 0.07
Nodes (28): 1. Defining Target Hashes (`lib/src/hook_helpers/hashes.dart`), 1. Local Execution Sandbox, 2. Hook Downloader Helper (`lib/src/hook_helpers/download.dart`), 2. Verify Target Outputs, 3. Implementing `hook/build.dart`, 3. Verify Tree-Shaking Stripping, 4. Verify Offline Compliance (User Defines), C Source and Bindings Setup (+20 more)

### Community 23 - "diagnostic_repository.dart"
Cohesion: 0.09
Nodes (22): campaignId, _Candidate, clock, content, db, difficulty, hasCompleted, latestFor (+14 more)

### Community 24 - "fake_purchase_gateway.dart"
Cohesion: 0.09
Nodes (22): catalogue, _changes, configure, configureCalls, currentUserId, dispose, failSwitchUser, forgetUser (+14 more)

### Community 25 - "balance_state.dart"
Cohesion: 0.14
Nodes (13): allTimePoints, archetypes, balance, BalanceState, load, marks, marksFor, maxValue (+5 more)

### Community 26 - "contentRepositoryProvider"
Cohesion: 0.15
Nodes (18): _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked, _linkWithEmail, _openDoctrine, _openSettings, _openUnlockSheet (+10 more)

### Community 27 - "generate_seed_snapshot.dart"
Cohesion: 0.15
Nodes (12): close, connection, file, leaked, main, paid, paidIds, partialTables (+4 more)

### Community 28 - "settings_restore_test.dart"
Cohesion: 0.16
Nodes (12): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+4 more)

### Community 29 - "../core/l10n_ext.dart"
Cohesion: 0.18
Nodes (10): build, DoctrineIntroScreen, onContinue, onSignIn, signInKey, build, onAccept, PrivacyNoticeScreen (+2 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.10
Nodes (19): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+11 more)

### Community 31 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.10
Nodes (21): archetypes, l10n, main, state, archetypes, figure, l10n, main (+13 more)

### Community 32 - "main.dart"
Cohesion: 0.14
Nodes (13): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, src/app/providers.dart (+5 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.09
Nodes (21): a, actionIdFor, api, b, backdate, campaignId, client, close (+13 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.08
Nodes (24): NoStoreGateway, attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked (+16 more)

### Community 35 - "package:test/test.dart"
Cohesion: 0.07
Nodes (35): main, main, db, ddl, main, probe, raw, _schemaStatementsFor (+27 more)

### Community 36 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

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
Cohesion: 0.15
Nodes (12): actionId, committedAt, completedActionIds, dayIndex, DayLog, id, isReported, note (+4 more)

### Community 41 - "2. Syntax Reference"
Cohesion: 0.08
Nodes (23): 1. Overview, 2.1 Basic Class Header Syntax, 2.2 Declaring, Initializing, and Plain Parameters, 2.3 Constant Primary Constructors, 2.4 Extension Types, 2.5 Empty Body Semicolon Shorthand (`;`), 2.6 The In-Body Part of a Primary Constructor (`this ...`), 2.7 Abbreviated Concise Constructor Syntax (+15 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.10
Nodes (19): SyncScheduler, calls, consumeNotices, _controller, delay, dispose, gate, goOffline (+11 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (17): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+9 more)

### Community 44 - "../support/pump.dart"
Cohesion: 0.06
Nodes (34): dismissals, links, main, pump, allText, arm, cancels, deleted (+26 more)

### Community 45 - "run_state.dart"
Cohesion: 0.08
Nodes (25): actionsById, campaign, completedActionIdsToday, currentDay, derive, engine, grade, isCommittedToday (+17 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.10
Nodes (20): AppleCredentials, _body, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor (+12 more)

### Community 48 - "unlock_sheet.dart"
Cohesion: 0.11
Nodes (17): build, _busy, buyKey, campaigns, closeKey, deliveringKey, onBuy, onClose (+9 more)

### Community 49 - "mapping.ts"
Cohesion: 0.16
Nodes (11): RFC-4122, ADR-0017, ADR-0019, asProductId(), asUserId(), asUserIds(), planWrites(), ADR-0017 (+3 more)

### Community 50 - "@DataClassName"
Cohesion: 0.21
Nodes (18): @DataClassName, ActionBodies, Actions, Archetypes, CampaignArchetypes, Campaigns, DiagnosticOptions, DiagnosticQuestions (+10 more)

### Community 51 - "revenuecat_gateway.dart"
Cohesion: 0.12
Nodes (15): apiKey, _changes, configure, _configured, forgetUser, outcomeForErrorCode, _ownedFrom, ownedProductChanges (+7 more)

### Community 52 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 53 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "sign_in_restore_test.dart"
Cohesion: 0.07
Nodes (29): l10n, main, pair, questions, l10n, main, auth, consumeNotices (+21 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (15): build, campaign, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey, marksEarned (+7 more)

### Community 56 - "Generating FFI Bindings using package:ffigen"
Cohesion: 0.09
Nodes (21): 1. `FfiGenerator`, 2. `Headers`, 3. `Functions`, 4. `Output`, AFTER: Generating via FFIgen (The Correct Pattern), BEFORE: Manual FFI Binding (The Anti-Pattern), Concrete Example: Binding a C Library, Constraints (+13 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.15
Nodes (16): accountApiProvider, _bootstrapContent, _dismissLinkPrompt, HomeRouter, _HomeRouterState, _homeScreen, _openDeleteAccount, ConsumerState (+8 more)

### Community 58 - "dashboard_screen.dart"
Cohesion: 0.06
Nodes (35): ActionSpec, ../app/balance_state.dart, RunState, CompletionScreen, _VertexLabel, action, balance, banner (+27 more)

### Community 59 - "Internationalizing Flutter Applications"
Cohesion: 0.10
Nodes (19): 1. Add Dependencies, 1. Define ARB Files, 2. Enable Code Generation, 2. Generate Localization Classes, 3. Consume Localized Strings, 3. Create Configuration File, 4. Configure the App Entry Point, Advanced Formatting (+11 more)

### Community 60 - "auth_gateway.dart"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "unlock_refreshes_detail_test.dart"
Cohesion: 0.05
Nodes (50): ../app/app_sync_wiring_test.dart, auth, db, fetchSince, gate, main, prefs, pumpApp (+42 more)

### Community 62 - "package:timezone/timezone.dart"
Cohesion: 0.11
Nodes (17): deviceZone, info, ProgressRepository, berlin, campaign, dbFile, dir, main (+9 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.04
Nodes (49): AnimationController, ../../app/balance_summary.dart, _angles, build, _clockOrder, _controller, createState, _currentFractions (+41 more)

### Community 65 - "balance_state_test.dart"
Cohesion: 0.10
Nodes (19): actions, archetypes, berlin, build, log, main, run, start (+11 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "diagnostic.dart"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 68 - "Implementing Routing and Deep Linking"
Cohesion: 0.11
Nodes (17): 1. Scaffold the Application, 2. Configure the Router, Contents, Core Concepts, Examples, High-Fidelity Shell Widget Implementation, If configuring for Android:, If configuring for iOS: (+9 more)

### Community 69 - "run.dart"
Cohesion: 0.15
Nodes (12): campaignId, completedAt, fromKey, grade, id, isHardened, key, RunStatus (+4 more)

### Community 70 - "run_reconciler.dart"
Cohesion: 0.22
Nodes (8): CampaignRun, abandon, isConflict, keep, localSurvived, Reconciliation, resolve, RunReconciler

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "String?"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineGroup, groupId, id, relatedArchetypeId, sort, title (+1 more)

### Community 73 - "balance.dart"
Cohesion: 0.18
Nodes (10): BalanceCalculator, BalanceWeights, compute, halfLifeDays, _localDate, pointsPerFullDay, standard, dart:math (+2 more)

### Community 74 - "grade_thresholds.dart"
Cohesion: 0.29
Nodes (6): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, static const GradeThresholds

### Community 75 - "link_flow_test.dart"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "package:feral/src/domain/outcome.dart"
Cohesion: 0.12
Nodes (16): main, engine, log, main, misses, action, engine, main (+8 more)

### Community 77 - "paid_content_boundary_test.dart"
Cohesion: 0.07
Nodes (27): client, close, configure, content, corePack, db, Device, entitlements (+19 more)

### Community 78 - "diagnostic_repository_test.dart"
Cohesion: 0.06
Nodes (35): ContentApi, SeedSnapshotLoader, DiagnosticRepository, _SilentContentApi, DelayedBodyContentApi, fetchSince, main, RecordingContentApi (+27 more)

### Community 79 - "Implementing Dart and Flutter Test Coverage"
Cohesion: 0.12
Nodes (15): 1. Add Dependencies, 1. Run Tests with VM Service, 2. Collect Coverage and Generate LCOV, 2. Collect Raw Coverage, 3. Feedback Loop: Validate Output, 3. Format to LCOV, Contents, Coverage Directives (+7 more)

### Community 80 - "purchase_gateway.dart"
Cohesion: 0.18
Nodes (10): configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, restore, switchUser (+2 more)

### Community 81 - "Writing Dart API Documentation"
Cohesion: 0.13
Nodes (14): 1. Banned Tags vs. Prose, 1. Scope and Structure, 2. The Annotation Placement Trap, 2. Tone and Openers, 3. Openers and Tone, 3. Strict Anti-Patterns (Banned), 4. Constructor Linking, 4. Technical Placement & Resolution (+6 more)

### Community 83 - "Building Dart CLI Applications"
Cohesion: 0.14
Nodes (13): Argument Parsing & Command Routing, Building Dart CLI Applications, Compilation & Distribution, Contents, Example: CommandRunner Implementation, Example: Integration Testing with Subprocesses, Examples, Execution & Error Handling (+5 more)

### Community 84 - "unlock_sheet_test.dart"
Cohesion: 0.18
Nodes (10): buys, campaigns, closes, edge, l10n, main, pump, restores (+2 more)

### Community 85 - "auth.users"
Cohesion: 0.19
Nodes (13): auth.users, public.actions, public.day_logs, public.campaign_runs, public.day_logs, public.diagnostic_results, public.entitlements, public.profiles (+5 more)

### Community 86 - "Implementing Dart Patterns"
Cohesion: 0.14
Nodes (13): Algebraic Data Types (Sealed Classes), Contents, Core Pattern Implementations, Examples, Feedback Loop: Exhaustiveness Checking, Guard Clauses and Logical-or, Implementing Dart Patterns, JSON Validation and Destructuring (+5 more)

### Community 87 - "Resolving Dart Static Analysis Errors"
Cohesion: 0.15
Nodes (12): Contents, Core Concepts & Guidelines, Error Handling, Example: Fixing Dynamic List Assignments, Example: Fixing Method Overrides (Contravariance), Example: Fixing Null Safety with `late`, Examples, Null Safety (+4 more)

### Community 88 - "campaign.dart"
Cohesion: 0.11
Nodes (18): ActionSpec, archetypeId, bodyMd, campaignId, dayIndex, difficulty, effort, id (+10 more)

### Community 89 - "campaign_detail_screen.dart"
Cohesion: 0.18
Nodes (10): Campaign, build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance, onStart (+2 more)

### Community 90 - "_ArchetypeRadarState"
Cohesion: 0.67
Nodes (3): ArchetypeRadar, _ArchetypeRadarState, SingleTickerProviderStateMixin

### Community 91 - "0001_content_schema.sql"
Cohesion: 0.35
Nodes (9): public, public.action_bodies, public.actions, public.archetypes, public.campaign_archetypes, public.campaigns, public.doctrine_entries, public.doctrine_groups (+1 more)

### Community 92 - "Money path integration test"
Cohesion: 0.25
Nodes (9): Feral CI Workflow, CI database job (supabase test db, pgTAP), CI functions job (Edge Function type-check and test), Headless Linux runner has no device target, Money path integration test, Two-device integration test, RevenueCat webhook mapping test, purchases_flutter (RevenueCat) integration (+1 more)

### Community 93 - "Architecting Flutter Applications"
Cohesion: 0.15
Nodes (12): Architecting Flutter Applications, Architectural Layers, Contents, Data Layer, Data Layer: Service and Repository, Examples, Logic Layer (Domain - Optional), Project Structure (+4 more)

### Community 94 - "sync_tables.dart"
Cohesion: 0.22
Nodes (8): lastPulledAt, primaryKey, SyncState, syncTable, watermark, DateTimeColumn get, Set, TextColumn get

### Community 95 - "Clock"
Cohesion: 0.28
Nodes (8): Clock, delay, FixedClock, _instant, nowUtc, SystemClock, InstantClock, DateTime

### Community 96 - "dashboard_screen_test.dart"
Cohesion: 0.12
Nodes (15): action, archetypes, balance, berlin, campaign, l10n, main, optional (+7 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.14
Nodes (13): currentDay, daysNeedingMissed, deriveOutcome, grade, missAllowance, missCount, pointsFor, RunEngine (+5 more)

### Community 98 - "link_prompt_state.dart"
Cohesion: 0.17
Nodes (10): _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, main, package:feral/src/app/link_prompt_state.dart (+2 more)

### Community 99 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 100 - "package:feral/src/core/clock.dart"
Cohesion: 0.06
Nodes (34): _, @DriftDatabase, NoStoreGateway, FeralDatabase, PurchaseGateway, RevenueCatGateway, EntitlementRepository, api (+26 more)

### Community 101 - "Testing and Mocking Dart Applications"
Cohesion: 0.17
Nodes (11): Contents, Examples, Feedback Loop: Test Failures, Generating Mocks, High-Fidelity Mocking and Testing Example, Implementing Unit Tests, Managing Dependencies, Structuring Code for Testability (+3 more)

### Community 104 - "Implementing Flutter Integration Tests"
Cohesion: 0.17
Nodes (11): Contents, Examples, Execution and Profiling, Host Driver Script (`test_driver/integration_test.dart`), Implementing Flutter Integration Tests, Interactive Exploration via MCP, Performance Profiling Driver Script (`test_driver/perf_driver.dart`), Project Setup and Dependencies (+3 more)

### Community 105 - "tokens.dart"
Cohesion: 0.07
Nodes (30): copyWith, EaseOutQuart, hairline, ink, lerp, mutedInk, panel, r0 (+22 more)

### Community 106 - "diagnostic_screen.dart"
Cohesion: 0.25
Nodes (8): build, _choose, createState, DiagnosticScreen, _DiagnosticScreenState, _index, _picks, questions

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 112 - "private.action_body_readable"
Cohesion: 0.33
Nodes (5): public.entitlements, private.action_body_readable(), public.actions, public.campaigns, public.packs

### Community 113 - "Previewing Flutter Widgets"
Cohesion: 0.17
Nodes (11): Basic Preview, Contents, Creating a Widget Preview, Custom Preview with Runtime Transformation, Examples, Handling Limitations, Interacting with Previews, MultiPreview Implementation (+3 more)

### Community 114 - "Testing Dart and Flutter Applications"
Cohesion: 0.18
Nodes (10): Contents, Examples, Executing Tests, Mocking with Mockito, Standard Unit Test Suite, Structuring Test Files, Task Progress, Test Implementation Workflow (+2 more)

### Community 132 - "Managing Dart Dependencies"
Cohesion: 0.18
Nodes (10): Contents, Core Concepts, Examples, Managing Dart Dependencies, Surgical Lockfile Removal, Tightening Constraints, Version Constraints, Workflow: Auditing Dependencies (+2 more)

### Community 135 - "Implementing Adaptive Layouts"
Cohesion: 0.18
Nodes (10): Adaptive Layout using LayoutBuilder, Constraining Width on Large Screens, Contents, Device and Orientation Behaviors, Examples, Implementing Adaptive Layouts, Space Measurement Guidelines, Widget Sizing and Constraints (+2 more)

### Community 136 - "purchase_controller_test.dart"
Cohesion: 0.10
Nodes (18): PurchaseController, controller, core, db, edge, fetchSince, gateway, main (+10 more)

### Community 137 - "Analyzing and Fixing Dart Code"
Cohesion: 0.20
Nodes (9): Analysis Configuration, Analyzing and Fixing Dart Code, Comprehensive `analysis_options.yaml`, Contents, Diagnostic Suppression, Examples, Inline Diagnostic Suppression, Workflow: Applying Automated Fixes (+1 more)

### Community 142 - "Writing Flutter Widget Tests"
Cohesion: 0.20
Nodes (9): Contents, Core Components, Examples, High-Fidelity Widget Test Implementation, Interaction & State Management, Setup & Configuration, Task Progress, Workflow: Implementing a Widget Test (+1 more)

### Community 143 - "pack.dart"
Cohesion: 0.20
Nodes (9): coverPath, description, id, isCore, key, Pack, sort, storeProductId (+1 more)

### Community 144 - "Resolving Flutter Layout Errors"
Cohesion: 0.20
Nodes (9): Constraint Violation Diagnostics, Contents, Examples, Fixing RenderFlex Overflow, Fixing Unbounded Height (ListView in Column), Fixing Unbounded Width (TextField in Row), Layout Error Resolution Workflow, Resolving Flutter Layout Errors (+1 more)

### Community 145 - "Serializing JSON Manually in Flutter"
Cohesion: 0.20
Nodes (9): Background Parsing (Large Payload), Contents, Core Guidelines, Examples, High-Fidelity Model Implementation, Serializing JSON Manually in Flutter, Synchronous Parsing (Small Payload), Workflow: Fetching and Parsing JSON (+1 more)

### Community 146 - "Using Examples in Dartdoc"
Cohesion: 0.22
Nodes (8): 1. The `{@example}` Directive, 2. Using Regions, 3. Hiding Setup Code, 4. Marker Filtering Rules, 5. Placement and Path Resolution, 6. Verification, Contents, Using Examples in Dartdoc

### Community 147 - "Implementing Flutter Networking"
Cohesion: 0.22
Nodes (8): Background Parsing, Configuration & Permissions, Contents, Examples, High-Fidelity Implementation: Fetching and Parsing in the Background, Implementing Flutter Networking, Request Execution & Response Handling, Workflow: Executing Network Operations

### Community 148 - "purchase_delivery_test.dart"
Cohesion: 0.12
Nodes (16): at, bodyPresentAfterPulls, buildTestController, clock, db, delay, fetchSince, gateway (+8 more)

### Community 149 - "replace_confirm_screen.dart"
Cohesion: 0.13
Nodes (13): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+5 more)

### Community 150 - "theme_context.dart"
Cohesion: 0.29
Nodes (9): @immutable, ArchetypePalette, archetypePalette, tokens, AppTokens, AppTokens get, ArchetypePalette get, ThemeExtension (+1 more)

### Community 151 - "purchase.dart"
Cohesion: 0.18
Nodes (10): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+2 more)

### Community 152 - "entitlement.dart"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 153 - "theme.dart"
Cohesion: 0.25
Nodes (7): appDarkTheme, base, copyWith, scheme, text, tokens, archetype_palette.dart

### Community 154 - "supabase_bootstrap.dart"
Cohesion: 0.18
Nodes (10): attempt, auth, ensureAnonymousSession, existing, initialize, initializeSupabase, _retryDelay, seconds (+2 more)

### Community 155 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 156 - "body_purge_test.dart"
Cohesion: 0.12
Nodes (15): api, apiThrows, at, db, fetchSince, Harness, into, main (+7 more)

### Community 157 - "State"
Cohesion: 0.27
Nodes (10): ReportSheet, _ReportSheetState, EmailCodeScreen, _EmailCodeScreenState, DeleteAccountScreen, _DeleteAccountScreenState, SettingsScreen, _SettingsScreenState (+2 more)

### Community 158 - "run_state_test.dart"
Cohesion: 0.18
Nodes (10): action, berlin, campaign, log, main, mandatory, run, started (+2 more)

### Community 159 - "balance_summary.dart"
Cohesion: 0.25
Nodes (7): balanceSummary, bandFor, bands, distribution, earned, radarSummary, balance_state.dart

### Community 160 - "dart:async"
Cohesion: 0.40
Nodes (4): testExecutable, testMain, dart:async, package:google_fonts/google_fonts.dart

### Community 161 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.18
Nodes (10): _client, fetchSince, SupabaseContentApi, _client, _conflictTargets, fetchSince, SupabaseProgressApi, upsert (+2 more)

### Community 162 - "l10n_ext.dart"
Cohesion: 0.29
Nodes (6): l10n, L10nContext, ThemeContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 163 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 164 - "dart:io"
Cohesion: 0.33
Nodes (5): main, main, dart:convert, dart:io, File

### Community 165 - "first_run_offline_test.dart"
Cohesion: 0.17
Nodes (11): api, at, attempts, berlin, content, db, fetchSince, main (+3 more)

### Community 166 - "bool get"
Cohesion: 0.18
Nodes (9): earnsMark, fromKey, Grade, key, fromKey, isMiss, key, Outcome (+1 more)

### Community 167 - "ConnectivityGate"
Cohesion: 0.67
Nodes (3): ConnectivityGate, ConnectivityPlusGate, FakeGate

### Community 168 - "report_sheet.dart"
Cohesion: 0.20
Nodes (9): build, _controller, createState, dispose, outcome, ReportResult, ../outcome_label.dart, ../theme/theme_context.dart (+1 more)

### Community 170 - "../domain/campaign.dart"
Cohesion: 0.15
Nodes (11): toAction, toCampaign, build, campaigns, isUnlocked, pack, PackListScreen, packs (+3 more)

### Community 173 - "completion_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays

### Community 174 - "../../domain/run.dart"
Cohesion: 0.50
Nodes (3): earned, MarkCalculator, ../domain/run.dart

### Community 176 - "List"
Cohesion: 0.10
Nodes (18): SyncNoticeNotifier, appName, Brand, build, dismissKey, _message, messageKey, notices (+10 more)

### Community 177 - "backoff_test.dart"
Cohesion: 0.50
Nodes (3): b, main, package:feral/src/engine/backoff.dart

### Community 178 - "seed_snapshot.dart"
Cohesion: 0.22
Nodes (8): content, db, loadIfEmpty, _partialTables, ContentRepository, ../local/database.dart, package:flutter/services.dart, ../repositories/content_repository.dart

### Community 179 - "sync_state.dart"
Cohesion: 0.25
Nodes (7): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, ../domain/sync_status.dart, providers.dart

### Community 180 - "account_api.dart"
Cohesion: 0.29
Nodes (7): AccountApi, _client, deleteAccount, message, SupabaseAccountApi, toString, FakeAccountApi

### Community 181 - "pack_views_test.dart"
Cohesion: 0.25
Nodes (7): core, edge, free, main, paid, views, package:feral/src/ui/browse/pack_list_screen.dart

### Community 182 - "diagnostic_scorer.dart"
Cohesion: 0.25
Nodes (7): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, ../domain/diagnostic.dart

### Community 183 - "sync_status.dart"
Cohesion: 0.29
Nodes (6): kind, message, occurredAt, SyncNotice, SyncNoticeKind, SyncStatus

### Community 184 - "Map"
Cohesion: 0.29
Nodes (6): build, DoctrineListScreen, entriesByGroup, groups, ../domain/doctrine.dart, Map

### Community 185 - "_buildHome"
Cohesion: 0.47
Nodes (6): balance, _buildHome, _startRun, clockProvider, progressRepositoryProvider, zoneProvider

### Community 186 - "progress_repository_test.dart"
Cohesion: 0.29
Nodes (6): berlin, day1, db, main, repoAt, FeralDatabase

### Community 187 - "ContentApi"
Cohesion: 0.67
Nodes (3): SilentContentApi, OfflineContentApi, ContentApi

### Community 188 - "package:timezone/data/latest.dart"
Cohesion: 0.29
Nodes (6): berlin, dayFor, engine, losAngeles, main, package:timezone/data/latest.dart

### Community 189 - "PackLocked"
Cohesion: 0.50
Nodes (4): AccountDeletionFailed, PackLocked, IdentityAlreadyAttached, Exception

## Knowledge Gaps
- **2193 isolated node(s):** `localeName`, `delegate`, `localizationsDelegates`, `supportedLocales`, `commitButton` (+2188 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2430 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `package:feral/src/core/clock.dart` to `database.dart`, `package:test/test.dart`, `providers.dart`, `identity_repository_test.dart`, `purchase_controller_test.dart`, `link_flow_test.dart`, `money_path_test.dart`, `diagnostic_repository_test.dart`, `seed_snapshot.dart`, `sync_push_test.dart`, `day_log_action_sync_test.dart`, `diagnostic_repository.dart`, `package:timezone/timezone.dart`, `body_purge_test.dart`, `entitlement_repository.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `package:flutter/material.dart` to `dashboard_screen_test.dart`, `app_localizations.dart`, `settings_screen_test.dart`, `_AppLocalizationsDelegate`, `unlock_sheet_test.dart`, `sign_in_restore_test.dart`, `settings_restore_test.dart`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `localeName`, `delegate`, `localizationsDelegates` to the rest of the system?**
  _2193 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.01282051282051282 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0125 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.013422818791946308 - nodes in this community are weakly interconnected._
- **Should `sync_scheduler.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._