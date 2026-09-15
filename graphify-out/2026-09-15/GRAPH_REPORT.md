# Graph Report - feral-build  (2026-09-15)

## Corpus Check
- 252 files · ~259,041 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3409 nodes · 4688 edges · 201 communities (148 shown, 28 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1121ec1c`
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
- run_state_test.dart
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
- package:feral/src/core/clock.dart
- Compiling C Code into Code Assets with Native Assets Hooks
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- balance_state.dart
- contentRepositoryProvider
- generate_seed_snapshot.dart
- balance_state_test.dart
- day.dart
- entitlement_repository.dart
- account_api.dart
- body_purge_test.dart
- two_device_test.dart
- identity_repository.dart
- package:test/test.dart
- delete_account_screen_test.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- run.dart
- 2. Syntax Reference
- sync_scheduler_test.dart
- delete_account_screen.dart
- ../support/pump.dart
- run_state.dart
- balance_playground.dart
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- diagnostic.dart
- revenuecat_outcome_test.dart
- sign_in_restore_test.dart
- completion_screen.dart
- Generating FFI Bindings using package:ffigen
- _HomeRouterState
- dashboard_screen.dart
- Internationalizing Flutter Applications
- auth_gateway.dart
- unlock_refreshes_detail_test.dart
- day_log.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- pack_list_screen.dart
- AppDelegate
- package:flutter/material.dart
- Implementing Routing and Deep Linking
- balance_scenario.dart
- email_code_screen_test.dart
- diagnostic_scorer_test.dart
- String?
- balance.dart
- grade_thresholds.dart
- link_flow_test.dart
- balance_presets.dart
- paid_content_boundary_test.dart
- first_run_offline_test.dart
- Implementing Dart and Flutter Test Coverage
- purchase_gateway.dart
- Writing Dart API Documentation
- public.action_bodies
- Building Dart CLI Applications
- package:supabase_flutter/supabase_flutter.dart
- auth.users
- Implementing Dart Patterns
- Resolving Dart Static Analysis Errors
- campaign.dart
- bool get
- purchase.dart
- 0001_content_schema.sql
- Money path integration test
- Architecting Flutter Applications
- sync_tables.dart
- package:flutter_test/flutter_test.dart
- dashboard_screen_test.dart
- run_engine.dart
- main.dart
- package:timezone/timezone.dart
- balance_test.dart
- Testing and Mocking Dart Applications
- Implementing Flutter Integration Tests
- tokens.dart
- campaign_detail_screen.dart
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- email_link_test.dart
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
- run_engine_grade_test.dart
- static const
- sync_entitlements_test.dart
- diagnostic_repository_test.dart
- DateTime
- persistence_restart_test.dart
- _RadarLayout
- backoff.dart
- purchase_delivery_test.dart
- day_panel.dart
- accountApiProvider
- replace_confirm_screen.dart
- clockProvider
- contentRepositoryProvider
- diagnosticRepositoryProvider
- balance_summary.dart
- theme.dart
- identityRepositoryProvider
- report_sheet.dart
- List
- unlock_sheet_test.dart
- account_deletion_test.dart
- diagnostic_scorer.dart
- run_reconciler.dart
- _ArchetypeDots
- linkPromptStateProvider
- completion_test.dart
- sync_status.dart
- _AppLocalizationsDelegate
- clock.dart
- ../domain/pack.dart
- ../../domain/run.dart
- PurchaseComplete
- browse_screen_test.dart
- _buildHome
- PurchaseDelivering
- PurchaseIdle
- PurchaseProblem
- progressRepositoryProvider
- sync_state.dart
- ../../domain/campaign.dart
- purchaseGatewayProvider
- reminderSchedulerProvider
- seedSnapshotLoaderProvider
- syncSchedulerProvider
- userIdProvider
- zoneProvider
- _ArchetypeRadarState
- PurchaseGateway
- EaseOutQuart

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 26 edges
2. `DataClass` - 21 edges
3. `_HomeRouterState` - 19 edges
4. `contentRepositoryProvider` - 13 edges
5. `userIdProvider` - 13 edges
6. `AppLocalizations` - 12 edges
7. `Key Syntax Differences and Pitfalls` - 11 edges
8. `Migrating Dart Tests to Package Checks` - 10 edges
9. `Compiling C Code into Code Assets with Native Assets Hooks` - 10 edges
10. `FakePurchaseGateway` - 9 edges

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

## Communities (201 total, 28 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (165): backfillDayLogActions, clearWatermark, _legacyActionArchetypes, migration, schemaVersion, setWatermark, watermarkFor, class ActionArchetypeRow extends (+157 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (166): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+158 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (155): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+147 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.06
Nodes (36): backoff, clock, _connectivity, ConnectivityGate, ConnectivityPlusGate, _connectivitySub, _consecutiveFailures, consumeNotices (+28 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (54): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+46 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (48): AccountApi, androidKey, authGatewayProvider, campaignsByPack, connectivityGateProvider, content, databaseProvider, db (+40 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (30): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+22 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (42): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+34 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.05
Nodes (39): actionId, archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayId (+31 more)

### Community 9 - "run_state_test.dart"
Cohesion: 0.15
Nodes (12): action, berlin, campaign, day3, log, main, mandatory, run (+4 more)

### Community 10 - "DataClass"
Cohesion: 0.09
Nodes (43): Insertable, UpdateCompanion, ActionArchetypeRow, ActionArchetypesCompanion, ActionBodiesCompanion, ActionBodyRow, ActionRow, ActionsCompanion (+35 more)

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
Nodes (29): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+21 more)

### Community 15 - "content_repository.dart"
Cohesion: 0.05
Nodes (42): content, db, loadIfEmpty, _partialTables, SeedSnapshotLoader, actionsFor, _advanceWatermark, api (+34 more)

### Community 16 - "purchase_state.dart"
Cohesion: 0.10
Nodes (24): buy, clock, content, _deliver, entitlements, gateway, packId, PurchaseComplete (+16 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (25): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+17 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.08
Nodes (23): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+15 more)

### Community 19 - "sync_push_test.dart"
Cohesion: 0.12
Nodes (15): main, main, api, callLog, db, failFetch, fetchSince, main (+7 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.07
Nodes (26): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+18 more)

### Community 21 - "package:feral/src/core/clock.dart"
Cohesion: 0.07
Nodes (30): SyncRepository, main, api, db, insertLocalLog, insertLocalRun, insertLocalTick, remoteTick (+22 more)

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
Cohesion: 0.17
Nodes (16): contentRepositoryProvider, purchaseGatewayProvider, reminderSchedulerProvider, userIdProvider, _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked (+8 more)

### Community 27 - "generate_seed_snapshot.dart"
Cohesion: 0.13
Nodes (14): close, connection, file, leaked, main, paidActionIds, paidActions, paidDayIds (+6 more)

### Community 28 - "balance_state_test.dart"
Cohesion: 0.10
Nodes (19): actions, archetypes, berlin, build, log, main, run, start (+11 more)

### Community 29 - "day.dart"
Cohesion: 0.12
Nodes (15): actions, bodyMd, campaignId, dayIndex, DayKind, DaySpec, fromKey, id (+7 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.12
Nodes (16): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+8 more)

### Community 31 - "account_api.dart"
Cohesion: 0.18
Nodes (11): AccountApi, AccountDeletionFailed, _client, deleteAccount, message, SupabaseAccountApi, toString, PackLocked (+3 more)

### Community 32 - "body_purge_test.dart"
Cohesion: 0.12
Nodes (15): api, apiThrows, at, db, fetchSince, Harness, main, packIds (+7 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.09
Nodes (21): a, actionIdFor, api, b, backdate, campaignId, client, close (+13 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.09
Nodes (21): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+13 more)

### Community 35 - "package:test/test.dart"
Cohesion: 0.06
Nodes (45): _, @DriftDatabase, FeralDatabase, main, main, db, ddl, main (+37 more)

### Community 36 - "delete_account_screen_test.dart"
Cohesion: 0.11
Nodes (16): allText, arm, cancels, deleted, main, pump, serverSucceeds, allText (+8 more)

### Community 37 - "settings_screen_test.dart"
Cohesion: 0.10
Nodes (19): disable, enable, enabled, isEnabled, l10n, main, offeredTime, permissionGranted (+11 more)

### Community 38 - "reminder_scheduler.dart"
Cohesion: 0.11
Nodes (18): disable, enable, _enabledKey, _hourKey, isEnabled, LocalReminderScheduler, _minuteKey, _notificationId (+10 more)

### Community 39 - "identity_repository_test.dart"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "run.dart"
Cohesion: 0.15
Nodes (12): campaignId, completedAt, fromKey, grade, id, isHardened, key, RunStatus (+4 more)

### Community 41 - "2. Syntax Reference"
Cohesion: 0.08
Nodes (23): 1. Overview, 2.1 Basic Class Header Syntax, 2.2 Declaring, Initializing, and Plain Parameters, 2.3 Constant Primary Constructors, 2.4 Extension Types, 2.5 Empty Body Semicolon Shorthand (`;`), 2.6 The In-Body Part of a Primary Constructor (`this ...`), 2.7 Abbreviated Concise Constructor Syntax (+15 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.10
Nodes (19): calls, consumeNotices, _controller, delay, dispose, gate, goOffline, goOnline (+11 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (19): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+11 more)

### Community 44 - "../support/pump.dart"
Cohesion: 0.11
Nodes (18): cancels, chosen, main, pump, deletes, links, main, pump (+10 more)

### Community 45 - "run_state.dart"
Cohesion: 0.08
Nodes (25): ActionSpec? get, actionsById, campaign, completedActionIdsToday, currentDay, derive, engine, grade (+17 more)

### Community 46 - "balance_playground.dart"
Cohesion: 0.05
Nodes (42): _applyWeights, archetypes, build, _ClockControls, createState, devArchetypes, _effort, _jumps (+34 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.09
Nodes (21): AppleCredentials, _body, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor (+13 more)

### Community 48 - "unlock_sheet.dart"
Cohesion: 0.11
Nodes (18): build, _busy, buyKey, campaigns, closeKey, deliveringKey, onBuy, onClose (+10 more)

### Community 49 - "mapping.ts"
Cohesion: 0.16
Nodes (11): RFC-4122, ADR-0017, ADR-0019, asProductId(), asUserId(), asUserIds(), planWrites(), ADR-0017 (+3 more)

### Community 50 - "@DataClassName"
Cohesion: 0.18
Nodes (21): @DataClassName, ActionArchetypes, ActionBodies, Actions, Archetypes, CampaignArchetypes, Campaigns, DayBodies (+13 more)

### Community 51 - "revenuecat_gateway.dart"
Cohesion: 0.12
Nodes (15): apiKey, _changes, configure, _configured, forgetUser, outcomeForErrorCode, _ownedFrom, ownedProductChanges (+7 more)

### Community 52 - "diagnostic.dart"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 53 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "sign_in_restore_test.dart"
Cohesion: 0.07
Nodes (29): l10n, main, pair, questions, l10n, main, auth, consumeNotices (+21 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (16): build, campaign, CompletionScreen, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey (+8 more)

### Community 56 - "Generating FFI Bindings using package:ffigen"
Cohesion: 0.09
Nodes (21): 1. `FfiGenerator`, 2. `Headers`, 3. `Functions`, 4. `Output`, AFTER: Generating via FFIgen (The Correct Pattern), BEFORE: Manual FFI Binding (The Anti-Pattern), Concrete Example: Binding a C Library, Constraints (+13 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.13
Nodes (18): accountApiProvider, diagnosticRepositoryProvider, identityRepositoryProvider, linkPromptStateProvider, seedSnapshotLoaderProvider, syncSchedulerProvider, _bootstrapContent, _dismissLinkPrompt (+10 more)

### Community 58 - "dashboard_screen.dart"
Cohesion: 0.07
Nodes (27): ActionSpec, action, balance, banner, build, child, _committed, isCompleted (+19 more)

### Community 59 - "Internationalizing Flutter Applications"
Cohesion: 0.10
Nodes (19): 1. Add Dependencies, 1. Define ARB Files, 2. Enable Code Generation, 2. Generate Localization Classes, 3. Consume Localized Strings, 3. Create Configuration File, 4. Configure the App Entry Point, Advanced Formatting (+11 more)

### Community 60 - "auth_gateway.dart"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "unlock_refreshes_detail_test.dart"
Cohesion: 0.04
Nodes (57): ../app/app_sync_wiring_test.dart, _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, auth (+49 more)

### Community 62 - "day_log.dart"
Cohesion: 0.17
Nodes (11): actionId, committedAt, completedActionIds, dayIndex, DayLog, id, isReported, note (+3 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.04
Nodes (48): AnimationController, ../../app/balance_summary.dart, _angles, build, _clockOrder, _controller, createState, _currentFractions (+40 more)

### Community 65 - "pack_list_screen.dart"
Cohesion: 0.08
Nodes (24): archetypes, archetypesByCampaign, _ArchetypeTag, build, campaign, _CampaignRow, campaigns, isLast (+16 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "package:flutter/material.dart"
Cohesion: 0.08
Nodes (26): wrap, campaign, killer, l10n, main, pump, _alchemist, _c1 (+18 more)

### Community 68 - "Implementing Routing and Deep Linking"
Cohesion: 0.11
Nodes (17): 1. Scaffold the Application, 2. Configure the Router, Contents, Core Concepts, Examples, High-Fidelity Shell Widget Implementation, If configuring for Android:, If configuring for iOS: (+9 more)

### Community 69 - "balance_scenario.dart"
Cohesion: 0.07
Nodes (27): ../app/balance_state.dart, actionId, advance, archetypes, BalanceScenario, cleared, clockOffsetDays, copyWith (+19 more)

### Community 70 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "String?"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineGroup, groupId, id, relatedArchetypeId, sort, title (+1 more)

### Community 73 - "balance.dart"
Cohesion: 0.17
Nodes (11): BalanceCalculator, BalanceWeights, compute, fullAxisValue, halfLifeDays, _localDate, pointsPerFullDay, standard (+3 more)

### Community 74 - "grade_thresholds.dart"
Cohesion: 0.29
Nodes (6): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, static const GradeThresholds

### Community 75 - "link_flow_test.dart"
Cohesion: 0.10
Nodes (20): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, auth (+12 more)

### Community 76 - "balance_presets.dart"
Cohesion: 0.12
Nodes (15): all, BalancePreset, blurb, cap, capBuster, days, even, fullAxis (+7 more)

### Community 77 - "paid_content_boundary_test.dart"
Cohesion: 0.07
Nodes (27): client, close, configure, content, corePack, db, Device, entitlements (+19 more)

### Community 78 - "first_run_offline_test.dart"
Cohesion: 0.05
Nodes (43): SilentContentApi, DelayedBodyContentApi, fetchSince, main, RecordingContentApi, actionArchetypeRow, actionRow, archetypeRow (+35 more)

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

### Community 84 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.08
Nodes (27): OfflineApi, _client, ContentApi, fetchSince, SupabaseContentApi, _client, _conflictTargets, fetchSince (+19 more)

### Community 85 - "auth.users"
Cohesion: 0.08
Nodes (34): auth.users, public.actions, public.archetypes, public.assert_action_has_archetype, public.campaigns, public.day_logs, public.entitlements, public.packs (+26 more)

### Community 86 - "Implementing Dart Patterns"
Cohesion: 0.14
Nodes (13): Algebraic Data Types (Sealed Classes), Contents, Core Pattern Implementations, Examples, Feedback Loop: Exhaustiveness Checking, Guard Clauses and Logical-or, Implementing Dart Patterns, JSON Validation and Destructuring (+5 more)

### Community 87 - "Resolving Dart Static Analysis Errors"
Cohesion: 0.15
Nodes (12): Contents, Core Concepts & Guidelines, Error Handling, Example: Fixing Dynamic List Assignments, Example: Fixing Method Overrides (Contravariance), Example: Fixing Null Safety with `late`, Examples, Null Safety (+4 more)

### Community 88 - "campaign.dart"
Cohesion: 0.10
Nodes (19): ActionSpec, archetypeWeights, archetypeWeightsFromShares, bodyMd, dayId, difficulty, effort, id (+11 more)

### Community 89 - "bool get"
Cohesion: 0.18
Nodes (9): earnsMark, fromKey, Grade, key, fromKey, isMiss, key, Outcome (+1 more)

### Community 90 - "purchase.dart"
Cohesion: 0.18
Nodes (10): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+2 more)

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

### Community 95 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.08
Nodes (25): main, first, main, open, read, second, tap, dismissals (+17 more)

### Community 96 - "dashboard_screen_test.dart"
Cohesion: 0.06
Nodes (36): archetypes, l10n, main, state, archetypes, figure, l10n, main (+28 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.13
Nodes (14): currentDay, daysNeedingMissed, deriveOutcome, grade, missAllowance, missCount, pointsFor, RunEngine (+6 more)

### Community 98 - "main.dart"
Cohesion: 0.09
Nodes (20): main, build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone (+12 more)

### Community 99 - "package:timezone/timezone.dart"
Cohesion: 0.12
Nodes (14): deviceZone, info, ProgressRepository, db, main, repo, berlin, day1 (+6 more)

### Community 100 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 101 - "Testing and Mocking Dart Applications"
Cohesion: 0.17
Nodes (11): Contents, Examples, Feedback Loop: Test Failures, Generating Mocks, High-Fidelity Mocking and Testing Example, Implementing Unit Tests, Managing Dependencies, Structuring Code for Testability (+3 more)

### Community 104 - "Implementing Flutter Integration Tests"
Cohesion: 0.17
Nodes (11): Contents, Examples, Execution and Profiling, Host Driver Script (`test_driver/integration_test.dart`), Implementing Flutter Integration Tests, Interactive Exploration via MCP, Performance Profiling Driver Script (`test_driver/perf_driver.dart`), Project Setup and Dependencies (+3 more)

### Community 105 - "tokens.dart"
Cohesion: 0.07
Nodes (28): copyWith, hairline, ink, lerp, mutedInk, panel, r0, r2 (+20 more)

### Community 106 - "campaign_detail_screen.dart"
Cohesion: 0.18
Nodes (10): Campaign, build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance, onStart (+2 more)

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 112 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

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
Nodes (19): PurchaseController, EntitlementRepository, controller, core, db, edge, fetchSince, gateway (+11 more)

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

### Community 148 - "run_engine_grade_test.dart"
Cohesion: 0.12
Nodes (15): berlin, dayFor, engine, losAngeles, main, engine, log, main (+7 more)

### Community 149 - "static const"
Cohesion: 0.13
Nodes (12): appName, Brand, build, DoctrineIntroScreen, onContinue, onSignIn, signInKey, build (+4 more)

### Community 150 - "sync_entitlements_test.dart"
Cohesion: 0.12
Nodes (15): SilentProgressApi, FakeProgressApi, db, entitlementRow, FakeProgressApi, fetched, fetchedSince, fetchSince (+7 more)

### Community 151 - "diagnostic_repository_test.dart"
Cohesion: 0.18
Nodes (10): DiagnosticRepository, db, fetchSince, main, now, repo, seedArchetype, seedCampaign (+2 more)

### Community 152 - "DateTime"
Cohesion: 0.18
Nodes (10): backfillActionArchetypes, acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source (+2 more)

### Community 153 - "persistence_restart_test.dart"
Cohesion: 0.22
Nodes (8): berlin, campaign, dbFile, dir, main, open, Directory, package:feral/src/app/run_state.dart

### Community 155 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 156 - "purchase_delivery_test.dart"
Cohesion: 0.12
Nodes (15): at, bodyPresentAfterPulls, buildTestController, clock, db, delay, fetchSince, gateway (+7 more)

### Community 157 - "day_panel.dart"
Cohesion: 0.15
Nodes (15): BalancePlayground, _BalancePlaygroundState, bodyMd, build, createState, DayPanel, _DayPanelState, _isExpanded (+7 more)

### Community 159 - "replace_confirm_screen.dart"
Cohesion: 0.13
Nodes (13): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+5 more)

### Community 163 - "balance_summary.dart"
Cohesion: 0.25
Nodes (7): balanceSummary, bandFor, bands, distribution, earned, radarSummary, balance_state.dart

### Community 164 - "theme.dart"
Cohesion: 0.08
Nodes (27): @immutable, l10n, L10nContext, ArchetypePalette, copyWith, forSort, lerp, roles (+19 more)

### Community 166 - "report_sheet.dart"
Cohesion: 0.18
Nodes (11): build, _controller, createState, dispose, outcome, ReportResult, ReportSheet, _ReportSheetState (+3 more)

### Community 167 - "List"
Cohesion: 0.09
Nodes (24): SyncNoticeNotifier, build, DoctrineListScreen, entriesByGroup, groups, build, _choose, createState (+16 more)

### Community 168 - "unlock_sheet_test.dart"
Cohesion: 0.10
Nodes (20): AppLocalizations, AppLocalizationsEn, of, entries, groups, l10n, main, buys (+12 more)

### Community 169 - "account_deletion_test.dart"
Cohesion: 0.09
Nodes (23): NoStoreGateway, PurchaseGateway, RevenueCatGateway, SignedIn, api, auth, calls, db (+15 more)

### Community 170 - "diagnostic_scorer.dart"
Cohesion: 0.25
Nodes (7): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, ../domain/diagnostic.dart

### Community 171 - "run_reconciler.dart"
Cohesion: 0.22
Nodes (8): CampaignRun, abandon, isConflict, keep, localSurvived, Reconciliation, resolve, RunReconciler

### Community 172 - "_ArchetypeDots"
Cohesion: 0.67
Nodes (3): _ArchetypeDots, _RadarPainter, CustomPainter

### Community 176 - "completion_test.dart"
Cohesion: 0.12
Nodes (14): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays (+6 more)

### Community 177 - "sync_status.dart"
Cohesion: 0.29
Nodes (6): kind, message, occurredAt, SyncNotice, SyncNoticeKind, SyncStatus

### Community 179 - "clock.dart"
Cohesion: 0.38
Nodes (6): Clock, delay, FixedClock, _instant, nowUtc, SystemClock

### Community 180 - "../domain/pack.dart"
Cohesion: 0.40
Nodes (4): EntitlementResolver, isUnlocked, unlockedPackIds, ../domain/pack.dart

### Community 181 - "../../domain/run.dart"
Cohesion: 0.50
Nodes (3): earned, MarkCalculator, ../../domain/run.dart

### Community 183 - "browse_screen_test.dart"
Cohesion: 0.06
Nodes (31): alchemist, core, edge, free, killer, main, paid, views (+23 more)

### Community 185 - "_buildHome"
Cohesion: 0.47
Nodes (6): clockProvider, progressRepositoryProvider, zoneProvider, balance, _buildHome, _startRun

### Community 190 - "sync_state.dart"
Cohesion: 0.25
Nodes (7): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, ../domain/sync_status.dart, providers.dart

### Community 191 - "../../domain/campaign.dart"
Cohesion: 0.29
Nodes (6): toAction, toCampaign, toDay, database.dart, ../../domain/campaign.dart, ../domain/day.dart

### Community 198 - "_ArchetypeRadarState"
Cohesion: 0.67
Nodes (3): ArchetypeRadar, _ArchetypeRadarState, SingleTickerProviderStateMixin

## Knowledge Gaps
- **2344 isolated node(s):** `campaignId`, `db`, `clock`, `zone`, `engine` (+2339 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2618 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **28 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `package:test/test.dart` to `database.dart`, `package:timezone/timezone.dart`, `identity_repository_test.dart`, `purchase_controller_test.dart`, `account_deletion_test.dart`, `link_flow_test.dart`, `money_path_test.dart`, `content_repository.dart`, `sync_push_test.dart`, `package:feral/src/core/clock.dart`, `sync_entitlements_test.dart`, `diagnostic_repository.dart`, `DateTime`, `diagnostic_repository_test.dart`, `sign_in_restore_test.dart`, `entitlement_repository.dart`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `unlock_sheet_test.dart` to `app_localizations.dart`, `package:flutter/material.dart`, `settings_screen_test.dart`, `../support/pump.dart`, `_AppLocalizationsDelegate`, `sign_in_restore_test.dart`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `PurchaseOutcome` connect `revenuecat_outcome_test.dart` to `fake_purchase_gateway.dart`, `purchase.dart`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `campaignId`, `db`, `clock` to the rest of the system?**
  _2344 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.012048192771084338 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.011976047904191617 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.01282051282051282 - nodes in this community are weakly interconnected._