# Graph Report - feral-build  (2026-09-14)

## Corpus Check
- 250 files · ~181,170 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3334 nodes · 4592 edges · 190 communities (151 shown, 14 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a1b0182d`
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
- unlock_sheet_test.dart
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
- package:timezone/timezone.dart
- package:test/test.dart
- entitlement_repository.dart
- archetype_radar_test.dart
- balance_playground_test.dart
- two_device_test.dart
- identity_repository.dart
- package:drift/native.dart
- List
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- day_log.dart
- 2. Syntax Reference
- sync_scheduler_test.dart
- delete_account_screen.dart
- settings_restore_test.dart
- run_state.dart
- balance_playground.dart
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
- day.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- dashboard_screen_test.dart
- AppDelegate
- balance_state_test.dart
- Implementing Routing and Deep Linking
- balance_scenario.dart
- theme_test.dart
- diagnostic_scorer_test.dart
- String?
- balance.dart
- grade_thresholds.dart
- link_flow_test.dart
- balance_presets.dart
- paid_content_boundary_test.dart
- seed_snapshot_test.dart
- Implementing Dart and Flutter Test Coverage
- purchase_gateway.dart
- Writing Dart API Documentation
- public.action_bodies
- Building Dart CLI Applications
- supabase_bootstrap.dart
- auth.users
- Implementing Dart Patterns
- Resolving Dart Static Analysis Errors
- campaign.dart
- campaign_detail_screen.dart
- package:supabase_flutter/supabase_flutter.dart
- 0001_content_schema.sql
- Money path integration test
- Architecting Flutter Applications
- sync_tables.dart
- account_api.dart
- run.dart
- run_engine.dart
- main.dart
- bool get
- package:feral/src/core/clock.dart
- Testing and Mocking Dart Applications
- Implementing Flutter Integration Tests
- tokens.dart
- purchase.dart
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- content_repository_test.dart
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
- pack_list_screen.dart
- Resolving Flutter Layout Errors
- Serializing JSON Manually in Flutter
- Using Examples in Dartdoc
- Implementing Flutter Networking
- purchase_delivery_test.dart
- package:flutter/material.dart
- package:flutter_test/flutter_test.dart
- link_flow.dart
- DateTime
- email_link_test.dart
- first_run_offline_test.dart
- backoff.dart
- body_purge_test.dart
- ContentApi
- persistence_restart_test.dart
- l10n/app_localizations.dart
- dart:async
- _ArchetypeRadarState
- ContentRepository
- seed_snapshot.dart
- run_reconciler.dart
- diagnostic_repository_test.dart
- State
- pack_views_test.dart
- run_state_test.dart
- entitlement_resolver_test.dart
- FeralDatabase
- _RadarLayout
- _RadarPainter
- progress_repository_lock_test.dart
- FakePurchaseGateway
- theme.dart
- AppLocalizations
- Clock
- l10n_ext.dart
- browse_screen_test.dart
- PurchaseComplete
- static const
- _buildHome
- PurchaseDelivering
- PurchaseIdle
- PurchaseProblem
- ../domain/run.dart

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 27 edges
2. `DataClass` - 21 edges
3. `_HomeRouterState` - 19 edges
4. `AppLocalizations` - 14 edges
5. `Key Syntax Differences and Pitfalls` - 11 edges
6. `SyncRepository` - 10 edges
7. `Migrating Dart Tests to Package Checks` - 10 edges
8. `Compiling C Code into Code Assets with Native Assets Hooks` - 10 edges
9. `ContentRepository` - 9 edges
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

## Communities (190 total, 14 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (165): backfillDayLogActions, clearWatermark, _legacyActionArchetypes, migration, schemaVersion, setWatermark, watermarkFor, class ActionArchetypeRow extends (+157 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (159): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+151 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (148): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+140 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.06
Nodes (36): backoff, clock, _connectivity, ConnectivityGate, ConnectivityPlusGate, _connectivitySub, _consecutiveFailures, consumeNotices (+28 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (55): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+47 more)

### Community 5 - "providers.dart"
Cohesion: 0.04
Nodes (51): accountApiProvider, androidKey, authGatewayProvider, campaignsByPack, clockProvider, connectivityGateProvider, content, contentRepositoryProvider (+43 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.05
Nodes (39): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+31 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (40): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+32 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.05
Nodes (39): actionId, archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayId (+31 more)

### Community 9 - "unlock_sheet_test.dart"
Cohesion: 0.18
Nodes (10): buys, campaigns, closes, edge, l10n, main, pump, restores (+2 more)

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
Cohesion: 0.06
Nodes (33): actionsFor, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById, _at, campaignById (+25 more)

### Community 16 - "purchase_state.dart"
Cohesion: 0.10
Nodes (24): NoStoreGateway, buy, clock, content, _deliver, entitlements, gateway, packId (+16 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (26): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+18 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.08
Nodes (22): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+14 more)

### Community 19 - "sync_push_test.dart"
Cohesion: 0.07
Nodes (26): main, db, entitlementRow, fetched, fetchedSince, fetchSince, main, repoWith (+18 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.08
Nodes (25): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+17 more)

### Community 21 - "day_log_action_sync_test.dart"
Cohesion: 0.07
Nodes (29): SyncRepository, api, db, insertLocalLog, insertLocalRun, insertLocalTick, remoteTick, sync (+21 more)

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
Nodes (16): _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked, _linkWithEmail, _openDoctrine, _openSettings, _openUnlockSheet (+8 more)

### Community 27 - "generate_seed_snapshot.dart"
Cohesion: 0.13
Nodes (14): close, connection, file, leaked, main, paidActionIds, paidActions, paidDayIds (+6 more)

### Community 28 - "package:timezone/timezone.dart"
Cohesion: 0.10
Nodes (18): deviceZone, info, berlin, campaign, day1, dayN, db, main (+10 more)

### Community 29 - "package:test/test.dart"
Cohesion: 0.09
Nodes (21): main, b, main, berlin, dayFor, engine, losAngeles, main (+13 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.10
Nodes (19): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+11 more)

### Community 31 - "archetype_radar_test.dart"
Cohesion: 0.08
Nodes (24): archetypes, l10n, main, state, archetypes, figure, l10n, main (+16 more)

### Community 32 - "balance_playground_test.dart"
Cohesion: 0.12
Nodes (15): main, main, first, main, open, read, second, tap (+7 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.09
Nodes (21): a, actionIdFor, api, b, backdate, campaignId, client, close (+13 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.09
Nodes (22): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+14 more)

### Community 35 - "package:drift/native.dart"
Cohesion: 0.07
Nodes (36): _, @DriftDatabase, FeralDatabase, main, db, ddl, main, probe (+28 more)

### Community 36 - "List"
Cohesion: 0.13
Nodes (13): SyncNoticeNotifier, build, DoctrineListScreen, entriesByGroup, groups, copyWith, forSort, lerp (+5 more)

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
Cohesion: 0.09
Nodes (21): calls, consumeNotices, _controller, delay, dispose, FakeGate, gate, goOffline (+13 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (17): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+9 more)

### Community 44 - "settings_restore_test.dart"
Cohesion: 0.16
Nodes (12): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+4 more)

### Community 45 - "run_state.dart"
Cohesion: 0.08
Nodes (25): actionsById, campaign, completedActionIdsToday, currentDay, derive, engine, grade, isCommittedToday (+17 more)

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

### Community 52 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 53 - "revenuecat_outcome_test.dart"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "sign_in_restore_test.dart"
Cohesion: 0.05
Nodes (38): l10n, main, pair, questions, entries, groups, l10n, main (+30 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (16): build, campaign, CompletionScreen, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey (+8 more)

### Community 56 - "Generating FFI Bindings using package:ffigen"
Cohesion: 0.09
Nodes (21): 1. `FfiGenerator`, 2. `Headers`, 3. `Functions`, 4. `Output`, AFTER: Generating via FFIgen (The Correct Pattern), BEFORE: Manual FFI Binding (The Anti-Pattern), Concrete Example: Binding a C Library, Constraints (+13 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.13
Nodes (18): accountApiProvider, _bootstrapContent, _dismissLinkPrompt, HomeRouter, _HomeRouterState, _homeScreen, _openDeleteAccount, _syncSoon (+10 more)

### Community 58 - "dashboard_screen.dart"
Cohesion: 0.06
Nodes (32): ActionSpec, RunState, action, balance, banner, build, child, isCompleted (+24 more)

### Community 59 - "Internationalizing Flutter Applications"
Cohesion: 0.10
Nodes (19): 1. Add Dependencies, 1. Define ARB Files, 2. Enable Code Generation, 2. Generate Localization Classes, 3. Consume Localized Strings, 3. Create Configuration File, 4. Configure the App Entry Point, Advanced Formatting (+11 more)

### Community 60 - "auth_gateway.dart"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "unlock_refreshes_detail_test.dart"
Cohesion: 0.04
Nodes (63): ../app/app_sync_wiring_test.dart, _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, build (+55 more)

### Community 62 - "day.dart"
Cohesion: 0.06
Nodes (28): actions, bodyMd, campaignId, dayIndex, DayKind, DaySpec, fromKey, id (+20 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.04
Nodes (47): AnimationController, ../../app/balance_summary.dart, _angles, build, _clockOrder, _controller, createState, _currentFractions (+39 more)

### Community 65 - "dashboard_screen_test.dart"
Cohesion: 0.12
Nodes (15): action, archetypes, balance, berlin, campaign, l10n, main, optional (+7 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "balance_state_test.dart"
Cohesion: 0.14
Nodes (12): actions, archetypes, berlin, build, log, main, run, start (+4 more)

### Community 68 - "Implementing Routing and Deep Linking"
Cohesion: 0.11
Nodes (17): 1. Scaffold the Application, 2. Configure the Router, Contents, Core Concepts, Examples, High-Fidelity Shell Widget Implementation, If configuring for Android:, If configuring for iOS: (+9 more)

### Community 69 - "balance_scenario.dart"
Cohesion: 0.07
Nodes (26): ../app/balance_state.dart, actionId, advance, archetypes, BalanceScenario, cleared, clockOffsetDays, copyWith (+18 more)

### Community 70 - "theme_test.dart"
Cohesion: 0.33
Nodes (8): @immutable, ArchetypePalette, AppTokens, main, package:feral/src/ui/theme/archetype_palette.dart, package:feral/src/ui/theme/theme.dart, package:feral/src/ui/theme/tokens.dart, ThemeExtension

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
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "balance_presets.dart"
Cohesion: 0.12
Nodes (15): all, BalancePreset, blurb, cap, capBuster, days, even, fullAxis (+7 more)

### Community 77 - "paid_content_boundary_test.dart"
Cohesion: 0.07
Nodes (27): client, close, configure, content, corePack, db, Device, entitlements (+19 more)

### Community 78 - "seed_snapshot_test.dart"
Cohesion: 0.15
Nodes (12): fetchSince, main, RecordingContentApi, content, db, fetchSince, loader, main (+4 more)

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

### Community 84 - "supabase_bootstrap.dart"
Cohesion: 0.18
Nodes (10): attempt, auth, ensureAnonymousSession, existing, initialize, initializeSupabase, _retryDelay, seconds (+2 more)

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
Cohesion: 0.06
Nodes (35): ActionSpec, archetypeWeights, archetypeWeightsFromShares, bodyMd, dayId, difficulty, effort, id (+27 more)

### Community 89 - "campaign_detail_screen.dart"
Cohesion: 0.11
Nodes (16): toAction, toCampaign, toDay, Campaign, build, campaign, CampaignDetailScreen, hasActiveRun (+8 more)

### Community 90 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.13
Nodes (17): OfflineApi, _client, ContentApi, fetchSince, SupabaseContentApi, _client, _conflictTargets, fetchSince (+9 more)

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

### Community 95 - "account_api.dart"
Cohesion: 0.29
Nodes (7): AccountApi, _client, deleteAccount, message, SupabaseAccountApi, toString, FakeAccountApi

### Community 96 - "run.dart"
Cohesion: 0.15
Nodes (12): campaignId, completedAt, fromKey, grade, id, isHardened, key, RunStatus (+4 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.13
Nodes (14): currentDay, daysNeedingMissed, deriveOutcome, grade, missAllowance, missCount, pointsFor, RunEngine (+6 more)

### Community 98 - "main.dart"
Cohesion: 0.15
Nodes (12): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, src/app/providers.dart (+4 more)

### Community 99 - "bool get"
Cohesion: 0.18
Nodes (9): earnsMark, fromKey, Grade, key, fromKey, isMiss, key, Outcome (+1 more)

### Community 100 - "package:feral/src/core/clock.dart"
Cohesion: 0.07
Nodes (29): EntitlementRepository, main, api, auth, calls, db, deleteAccount, identity (+21 more)

### Community 101 - "Testing and Mocking Dart Applications"
Cohesion: 0.17
Nodes (11): Contents, Examples, Feedback Loop: Test Failures, Generating Mocks, High-Fidelity Mocking and Testing Example, Implementing Unit Tests, Managing Dependencies, Structuring Code for Testability (+3 more)

### Community 104 - "Implementing Flutter Integration Tests"
Cohesion: 0.17
Nodes (11): Contents, Examples, Execution and Profiling, Host Driver Script (`test_driver/integration_test.dart`), Implementing Flutter Integration Tests, Interactive Exploration via MCP, Performance Profiling Driver Script (`test_driver/perf_driver.dart`), Project Setup and Dependencies (+3 more)

### Community 105 - "tokens.dart"
Cohesion: 0.07
Nodes (30): copyWith, EaseOutQuart, hairline, ink, lerp, mutedInk, panel, r0 (+22 more)

### Community 106 - "purchase.dart"
Cohesion: 0.20
Nodes (9): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+1 more)

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 112 - "content_repository_test.dart"
Cohesion: 0.20
Nodes (9): actionArchetypeRow, actionRow, archetypeRow, dayRow, db, fetchSince, main, rows (+1 more)

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
Cohesion: 0.18
Nodes (10): PurchaseController, controller, core, db, edge, fetchSince, gateway, main (+2 more)

### Community 137 - "Analyzing and Fixing Dart Code"
Cohesion: 0.20
Nodes (9): Analysis Configuration, Analyzing and Fixing Dart Code, Comprehensive `analysis_options.yaml`, Contents, Diagnostic Suppression, Examples, Inline Diagnostic Suppression, Workflow: Applying Automated Fixes (+1 more)

### Community 142 - "Writing Flutter Widget Tests"
Cohesion: 0.20
Nodes (9): Contents, Core Components, Examples, High-Fidelity Widget Test Implementation, Interaction & State Management, Setup & Configuration, Task Progress, Workflow: Implementing a Widget Test (+1 more)

### Community 143 - "pack_list_screen.dart"
Cohesion: 0.11
Nodes (16): coverPath, description, id, isCore, key, Pack, sort, storeProductId (+8 more)

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
Cohesion: 0.11
Nodes (17): at, bodyPresentAfterPulls, buildTestController, clock, db, delay, fetchSince, gateway (+9 more)

### Community 149 - "package:flutter/material.dart"
Cohesion: 0.09
Nodes (22): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+14 more)

### Community 150 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.06
Nodes (36): main, dismissals, links, main, pump, allText, arm, cancels (+28 more)

### Community 151 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 152 - "DateTime"
Cohesion: 0.11
Nodes (16): backfillActionArchetypes, acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source (+8 more)

### Community 153 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

### Community 154 - "first_run_offline_test.dart"
Cohesion: 0.18
Nodes (10): api, at, attempts, berlin, content, db, fetchSince, main (+2 more)

### Community 155 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 156 - "body_purge_test.dart"
Cohesion: 0.10
Nodes (20): SilentProgressApi, api, apiThrows, at, db, FakeProgressApi, fetchSince, Harness (+12 more)

### Community 157 - "ContentApi"
Cohesion: 0.29
Nodes (7): SilentContentApi, DelayedBodyContentApi, FakeContentApi, EmptyContentApi, OfflineContentApi, _NoopApi, ContentApi

### Community 158 - "persistence_restart_test.dart"
Cohesion: 0.14
Nodes (12): main, berlin, campaign, dbFile, dir, main, open, Directory (+4 more)

### Community 159 - "l10n/app_localizations.dart"
Cohesion: 0.17
Nodes (10): balanceSummary, bandFor, bands, distribution, earned, radarSummary, purchaseProblemText, ../app/purchase_state.dart (+2 more)

### Community 160 - "dart:async"
Cohesion: 0.40
Nodes (4): testExecutable, testMain, dart:async, package:google_fonts/google_fonts.dart

### Community 161 - "_ArchetypeRadarState"
Cohesion: 0.67
Nodes (3): ArchetypeRadar, _ArchetypeRadarState, SingleTickerProviderStateMixin

### Community 163 - "seed_snapshot.dart"
Cohesion: 0.20
Nodes (9): content, db, loadIfEmpty, _partialTables, SeedSnapshotLoader, ContentRepository, ../local/database.dart, package:flutter/services.dart (+1 more)

### Community 164 - "run_reconciler.dart"
Cohesion: 0.22
Nodes (8): CampaignRun, abandon, isConflict, keep, localSurvived, Reconciliation, resolve, RunReconciler

### Community 165 - "diagnostic_repository_test.dart"
Cohesion: 0.18
Nodes (10): DiagnosticRepository, db, fetchSince, main, now, repo, seedArchetype, seedCampaign (+2 more)

### Community 166 - "State"
Cohesion: 0.27
Nodes (10): BalancePlayground, _BalancePlaygroundState, ReportSheet, _ReportSheetState, DeleteAccountScreen, _DeleteAccountScreenState, SettingsScreen, _SettingsScreenState (+2 more)

### Community 167 - "pack_views_test.dart"
Cohesion: 0.25
Nodes (7): core, edge, free, main, paid, views, package:feral/src/domain/pack.dart

### Community 168 - "run_state_test.dart"
Cohesion: 0.09
Nodes (21): action, berlin, campaign, log, main, mandatory, run, started (+13 more)

### Community 169 - "entitlement_resolver_test.dart"
Cohesion: 0.25
Nodes (7): core, edge, main, resolver, unlocked, unpriced, package:feral/src/engine/entitlement_resolver.dart

### Community 170 - "FeralDatabase"
Cohesion: 0.29
Nodes (6): db, fetchSince, main, seed, FeralDatabase, package:feral/src/data/remote/content_api.dart

### Community 173 - "progress_repository_lock_test.dart"
Cohesion: 0.22
Nodes (8): AccountDeletionFailed, PackLocked, ProgressRepository, IdentityAlreadyAttached, db, main, repo, Exception

### Community 176 - "FakePurchaseGateway"
Cohesion: 0.50
Nodes (4): NoStoreGateway, PurchaseGateway, RevenueCatGateway, FakePurchaseGateway

### Community 177 - "theme.dart"
Cohesion: 0.15
Nodes (12): appDarkTheme, base, archetypePalette, tokens, copyWith, scheme, text, tokens (+4 more)

### Community 178 - "AppLocalizations"
Cohesion: 0.50
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, of, LocalizationsDelegate

### Community 179 - "Clock"
Cohesion: 0.38
Nodes (6): Clock, delay, FixedClock, _instant, nowUtc, SystemClock

### Community 180 - "l10n_ext.dart"
Cohesion: 0.29
Nodes (6): l10n, L10nContext, ThemeContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 181 - "browse_screen_test.dart"
Cohesion: 0.12
Nodes (15): corePack, killer, l10n, long, main, paidPack, short, core (+7 more)

### Community 183 - "static const"
Cohesion: 0.15
Nodes (11): appName, Brand, build, dismissKey, _message, messageKey, notices, status (+3 more)

### Community 185 - "_buildHome"
Cohesion: 0.47
Nodes (6): balance, _buildHome, _startRun, clockProvider, progressRepositoryProvider, zoneProvider

### Community 189 - "../domain/run.dart"
Cohesion: 0.50
Nodes (3): earned, MarkCalculator, ../../domain/run.dart

## Knowledge Gaps
- **2297 isolated node(s):** `PurchaseProblemReason`, `packId`, `reason`, `storeMessage`, `entitlements` (+2292 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2552 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `package:drift/native.dart` to `database.dart`, `seed_snapshot.dart`, `package:feral/src/core/clock.dart`, `providers.dart`, `diagnostic_repository_test.dart`, `identity_repository_test.dart`, `purchase_controller_test.dart`, `link_flow_test.dart`, `money_path_test.dart`, `progress_repository_lock_test.dart`, `sync_push_test.dart`, `day_log_action_sync_test.dart`, `sign_in_restore_test.dart`, `diagnostic_repository.dart`, `DateTime`, `package:timezone/timezone.dart`, `entitlement_repository.dart`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `AppLocalizations` to `app_localizations.dart`, `settings_screen_test.dart`, `unlock_sheet_test.dart`, `settings_restore_test.dart`, `browse_screen_test.dart`, `sign_in_restore_test.dart`, `archetype_radar_test.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `PurchaseGateway` connect `FakePurchaseGateway` to `purchase_gateway.dart`, `providers.dart`, `entitlement_repository.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `PurchaseProblemReason`, `packId`, `reason` to the rest of the system?**
  _2297 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.012048192771084338 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0125 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.013422818791946308 - nodes in this community are weakly interconnected._