# Graph Report - feral-build  (2026-09-15)

## Corpus Check
- 256 files · ~262,171 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3478 nodes · 4791 edges · 191 communities (151 shown, 15 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a15e16b2`
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
- supabase_bootstrap.dart
- DataClass
- user_tables.dart
- money_path_test.dart
- Key Syntax Differences and Pitfalls
- settings_screen.dart
- content_repository.dart
- purchase_state.dart
- identity.dart
- diagnostic_result_screen.dart
- purchase.dart
- progress_repository.dart
- persistence_restart_test.dart
- Compiling C Code into Code Assets with Native Assets Hooks
- diagnostic_repository.dart
- fake_purchase_gateway.dart
- List
- userIdProvider
- generate_seed_snapshot.dart
- run_state_test.dart
- day.dart
- entitlement_repository.dart
- email_link_test.dart
- purchase_delivery_test.dart
- two_device_test.dart
- identity_repository.dart
- package:test/test.dart
- ../support/pump.dart
- settings_screen_test.dart
- reminder_scheduler.dart
- identity_repository_test.dart
- run.dart
- 2. Syntax Reference
- sync_scheduler_test.dart
- delete_account_screen.dart
- seed_snapshot.dart
- run_state.dart
- balance_playground.dart
- link_sheet.dart
- unlock_sheet.dart
- mapping.ts
- @DataClassName
- revenuecat_gateway.dart
- diagnostic.dart
- dart:async
- sign_in_restore_test.dart
- completion_screen.dart
- Generating FFI Bindings using package:ffigen
- _HomeRouterState
- dashboard_screen.dart
- Internationalizing Flutter Applications
- auth_gateway.dart
- unlock_refreshes_detail_test.dart
- sync_push_test.dart
- Feral (Flutter + Supabase app)
- archetype_radar.dart
- pack_list_screen.dart
- AppDelegate
- pack_list_screen_debug_test.dart
- Implementing Routing and Deep Linking
- balance_scenario.dart
- email_code_screen_test.dart
- diagnostic_scorer_test.dart
- String?
- archetype_tag.dart
- sync_banner.dart
- link_flow_test.dart
- balance_presets.dart
- paid_content_boundary_test.dart
- first_run_offline_test.dart
- Implementing Dart and Flutter Test Coverage
- purchase_gateway.dart
- Writing Dart API Documentation
- public.action_bodies
- Building Dart CLI Applications
- entitlement_repository_test.dart
- auth.users
- Implementing Dart Patterns
- Resolving Dart Static Analysis Errors
- campaign.dart
- package:feral/src/domain/run.dart
- body_purge_test.dart
- 0001_content_schema.sql
- Money path integration test
- Architecting Flutter Applications
- sync_tables.dart
- balance_playground_test.dart
- dashboard_screen_test.dart
- run_engine.dart
- main.dart
- day_log.dart
- package:feral/src/core/clock.dart
- Testing and Mocking Dart Applications
- Implementing Flutter Integration Tests
- tokens.dart
- campaign_detail_screen.dart
- delete-account/index.ts
- public.diagnostic_options
- imports
- imports
- OTP six-digit code email template
- balance_test.dart
- Previewing Flutter Widgets
- Testing Dart and Flutter Applications
- MainActivity.kt
- Managing Dart Dependencies
- app
- LaunchImage.imageset/README.md
- Implementing Adaptive Layouts
- account_deletion_test.dart
- Analyzing and Fixing Dart Code
- Writing Flutter Widget Tests
- pack.dart
- Resolving Flutter Layout Errors
- Serializing JSON Manually in Flutter
- Using Examples in Dartdoc
- Implementing Flutter Networking
- FakeGate
- static const
- link_flow.dart
- diagnostic_repository_test.dart
- entitlement.dart
- account_api.dart
- package:supabase_flutter/supabase_flutter.dart
- progress_api.dart
- identity_entitlements_test.dart
- State
- diagnostic_screen.dart
- doctrine_screen_test.dart
- day_panel.dart
- l10n_ext.dart
- backoff.dart
- bool get
- theme.dart
- grade_thresholds.dart
- report_sheet.dart
- ../domain/grade.dart
- unlock_sheet_test.dart
- purchase_controller_test.dart
- diagnostic_scorer.dart
- ProgressApi
- theme_context.dart
- PackLocked
- campaign_detail_screen_test.dart
- ReminderScheduler
- DateTime
- clock.dart
- package:flutter/material.dart
- SettingsScreen
- PurchaseComplete
- browse_screen_test.dart
- _buildHome
- PurchaseDelivering
- PurchaseIdle
- PurchaseProblem
- ../../domain/run.dart
- FakePurchaseGateway

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 25 edges
2. `DataClass` - 21 edges
3. `_HomeRouterState` - 19 edges
4. `AppLocalizations` - 14 edges
5. `Key Syntax Differences and Pitfalls` - 11 edges
6. `FakePurchaseGateway` - 10 edges
7. `Migrating Dart Tests to Package Checks` - 10 edges
8. `Compiling C Code into Code Assets with Native Assets Hooks` - 10 edges
9. `Writing Dart API Documentation` - 9 edges
10. `Building Dart CLI Applications` - 9 edges

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

## Communities (191 total, 15 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.01
Nodes (165): backfillDayLogActions, clearWatermark, _legacyActionArchetypes, migration, schemaVersion, setWatermark, watermarkFor, class ActionArchetypeRow extends (+157 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (171): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+163 more)

### Community 2 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (160): abandonActiveRunWarning, abandonAndStartButton, actionPoints, actionSemanticMandatory, actionSemanticOptional, actionStateDone, actionStateNotDone, allTimePointsTotal (+152 more)

### Community 3 - "sync_scheduler.dart"
Cohesion: 0.06
Nodes (35): backoff, clock, _connectivity, ConnectivityGate, ConnectivityPlusGate, _connectivitySub, _consecutiveFailures, consumeNotices (+27 more)

### Community 4 - "home_router.dart"
Cohesion: 0.04
Nodes (53): _boot, build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState (+45 more)

### Community 5 - "providers.dart"
Cohesion: 0.03
Nodes (58): AccountApi, accountApiProvider, androidKey, authGatewayProvider, campaignsByPack, clockProvider, connectivityGateProvider, content (+50 more)

### Community 6 - "email_code_screen.dart"
Cohesion: 0.07
Nodes (28): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+20 more)

### Community 7 - "sync_repository.dart"
Cohesion: 0.05
Nodes (40): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+32 more)

### Community 8 - "content_tables.dart"
Cohesion: 0.05
Nodes (39): actionId, archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayId (+31 more)

### Community 9 - "supabase_bootstrap.dart"
Cohesion: 0.18
Nodes (10): attempt, auth, ensureAnonymousSession, existing, initialize, initializeSupabase, _retryDelay, seconds (+2 more)

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
Nodes (28): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+20 more)

### Community 15 - "content_repository.dart"
Cohesion: 0.06
Nodes (33): actionsFor, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById, _at, campaignById (+25 more)

### Community 16 - "purchase_state.dart"
Cohesion: 0.09
Nodes (26): buy, clock, content, _deliver, entitlements, gateway, isBusy, packId (+18 more)

### Community 17 - "identity.dart"
Cohesion: 0.09
Nodes (25): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+17 more)

### Community 18 - "diagnostic_result_screen.dart"
Cohesion: 0.08
Nodes (23): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+15 more)

### Community 19 - "purchase.dart"
Cohesion: 0.15
Nodes (16): error, id, message, ownedProductIds, priceString, PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed (+8 more)

### Community 20 - "progress_repository.dart"
Cohesion: 0.08
Nodes (25): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+17 more)

### Community 21 - "persistence_restart_test.dart"
Cohesion: 0.14
Nodes (13): main, berlin, campaign, dbFile, dir, main, open, main (+5 more)

### Community 22 - "Compiling C Code into Code Assets with Native Assets Hooks"
Cohesion: 0.07
Nodes (28): 1. Defining Target Hashes (`lib/src/hook_helpers/hashes.dart`), 1. Local Execution Sandbox, 2. Hook Downloader Helper (`lib/src/hook_helpers/download.dart`), 2. Verify Target Outputs, 3. Implementing `hook/build.dart`, 3. Verify Tree-Shaking Stripping, 4. Verify Offline Compliance (User Defines), C Source and Bindings Setup (+20 more)

### Community 23 - "diagnostic_repository.dart"
Cohesion: 0.09
Nodes (22): campaignId, _Candidate, clock, content, db, difficulty, hasCompleted, latestFor (+14 more)

### Community 24 - "fake_purchase_gateway.dart"
Cohesion: 0.08
Nodes (25): catalogue, _changes, configure, configureCalls, currentUserId, dispose, failSwitchUser, forgetUser (+17 more)

### Community 25 - "List"
Cohesion: 0.09
Nodes (22): allTimePoints, archetypes, balance, BalanceState, load, marks, marksFor, maxValue (+14 more)

### Community 26 - "userIdProvider"
Cohesion: 0.14
Nodes (18): _archetypesFor, browse, _configurePurchases, _isCampaignUnlocked, _linkWithEmail, _openDoctrine, _openSettings, _openUnlockSheet (+10 more)

### Community 27 - "generate_seed_snapshot.dart"
Cohesion: 0.13
Nodes (14): close, connection, file, leaked, main, paidActionIds, paidActions, paidDayIds (+6 more)

### Community 28 - "run_state_test.dart"
Cohesion: 0.05
Nodes (37): actions, archetypes, berlin, build, log, main, run, start (+29 more)

### Community 29 - "day.dart"
Cohesion: 0.12
Nodes (15): actions, bodyMd, campaignId, dayIndex, DayKind, DaySpec, fromKey, id (+7 more)

### Community 30 - "entitlement_repository.dart"
Cohesion: 0.10
Nodes (19): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+11 more)

### Community 31 - "email_link_test.dart"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

### Community 32 - "purchase_delivery_test.dart"
Cohesion: 0.11
Nodes (17): at, bodyPresentAfterPulls, buildTestController, clock, db, delay, fetchSince, gateway (+9 more)

### Community 33 - "two_device_test.dart"
Cohesion: 0.10
Nodes (20): a, actionIdFor, api, b, backdate, campaignId, client, close (+12 more)

### Community 34 - "identity_repository.dart"
Cohesion: 0.09
Nodes (22): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+14 more)

### Community 35 - "package:test/test.dart"
Cohesion: 0.06
Nodes (38): main, main, db, ddl, main, probe, raw, _schemaStatementsFor (+30 more)

### Community 36 - "../support/pump.dart"
Cohesion: 0.07
Nodes (31): dismissals, links, main, pump, campaign, killer, l10n, main (+23 more)

### Community 37 - "settings_screen_test.dart"
Cohesion: 0.06
Nodes (36): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, of, RestoreSummary, deletes, links, main (+28 more)

### Community 38 - "reminder_scheduler.dart"
Cohesion: 0.12
Nodes (15): disable, enable, _enabledKey, _hourKey, isEnabled, _minuteKey, _notificationId, _plugin (+7 more)

### Community 39 - "identity_repository_test.dart"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "run.dart"
Cohesion: 0.07
Nodes (24): earnsMark, fromKey, Grade, key, campaignId, CampaignRun, completedAt, fromKey (+16 more)

### Community 41 - "2. Syntax Reference"
Cohesion: 0.08
Nodes (23): 1. Overview, 2.1 Basic Class Header Syntax, 2.2 Declaring, Initializing, and Plain Parameters, 2.3 Constant Primary Constructors, 2.4 Extension Types, 2.5 Empty Body Semicolon Shorthand (`;`), 2.6 The In-Body Part of a Primary Constructor (`this ...`), 2.7 Abbreviated Concise Constructor Syntax (+15 more)

### Community 42 - "sync_scheduler_test.dart"
Cohesion: 0.10
Nodes (19): calls, consumeNotices, _controller, delay, dispose, gate, goOffline, goOnline (+11 more)

### Community 43 - "delete_account_screen.dart"
Cohesion: 0.11
Nodes (19): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+11 more)

### Community 44 - "seed_snapshot.dart"
Cohesion: 0.22
Nodes (8): content, db, loadIfEmpty, _partialTables, SeedSnapshotLoader, ../local/database.dart, package:flutter/services.dart, ../repositories/content_repository.dart

### Community 45 - "run_state.dart"
Cohesion: 0.07
Nodes (26): ActionSpec? get, actionsById, campaign, completedActionIdsToday, currentDay, derive, engine, grade (+18 more)

### Community 46 - "balance_playground.dart"
Cohesion: 0.05
Nodes (44): _applyWeights, archetypes, build, _ClockControls, createState, devArchetypes, _effort, _jumps (+36 more)

### Community 47 - "link_sheet.dart"
Cohesion: 0.09
Nodes (21): AppleCredentials, _body, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor (+13 more)

### Community 48 - "unlock_sheet.dart"
Cohesion: 0.06
Nodes (29): balanceSummary, bandFor, bands, distribution, earned, radarSummary, purchaseProblemText, build (+21 more)

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

### Community 53 - "dart:async"
Cohesion: 0.12
Nodes (16): main, owned, testExecutable, testMain, gateway, main, dart:async, fake_purchase_gateway.dart (+8 more)

### Community 54 - "sign_in_restore_test.dart"
Cohesion: 0.10
Nodes (19): auth, consumeNotices, db, gate, l10n, main, now, prefs (+11 more)

### Community 55 - "completion_screen.dart"
Cohesion: 0.12
Nodes (16): build, campaign, CompletionScreen, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey (+8 more)

### Community 56 - "Generating FFI Bindings using package:ffigen"
Cohesion: 0.09
Nodes (21): 1. `FfiGenerator`, 2. `Headers`, 3. `Functions`, 4. `Output`, AFTER: Generating via FFIgen (The Correct Pattern), BEFORE: Manual FFI Binding (The Anti-Pattern), Concrete Example: Binding a C Library, Constraints (+13 more)

### Community 57 - "_HomeRouterState"
Cohesion: 0.15
Nodes (16): accountApiProvider, _bootstrapContent, _dismissLinkPrompt, HomeRouter, _HomeRouterState, _homeScreen, _openDeleteAccount, ConsumerState (+8 more)

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
Nodes (58): ../app/app_sync_wiring_test.dart, _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, auth (+50 more)

### Community 62 - "sync_push_test.dart"
Cohesion: 0.05
Nodes (43): SyncRepository, api, db, insertLocalLog, insertLocalRun, insertLocalTick, main, remoteTick (+35 more)

### Community 63 - "Feral (Flutter + Supabase app)"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "archetype_radar.dart"
Cohesion: 0.04
Nodes (49): AnimationController, ../../app/balance_summary.dart, _angles, build, _clockOrder, _controller, createState, _currentFractions (+41 more)

### Community 65 - "pack_list_screen.dart"
Cohesion: 0.10
Nodes (19): archetypesByCampaign, build, campaign, _CampaignRow, campaigns, isLast, isUnlocked, onTap (+11 more)

### Community 66 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, AppDelegate, SceneDelegate, RunnerTests, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge (+6 more)

### Community 67 - "pack_list_screen_debug_test.dart"
Cohesion: 0.13
Nodes (14): _beast, _c1, _c2, _c3, _c4, _c5, _c6, _core (+6 more)

### Community 68 - "Implementing Routing and Deep Linking"
Cohesion: 0.11
Nodes (17): 1. Scaffold the Application, 2. Configure the Router, Contents, Core Concepts, Examples, High-Fidelity Shell Widget Implementation, If configuring for Android:, If configuring for iOS: (+9 more)

### Community 69 - "balance_scenario.dart"
Cohesion: 0.07
Nodes (26): ../app/balance_state.dart, actionId, advance, archetypes, BalanceScenario, cleared, clockOffsetDays, copyWith (+18 more)

### Community 70 - "email_code_screen_test.dart"
Cohesion: 0.20
Nodes (9): authenticated, main, nextResult, pump, reachCodeStep, sent, package:feral/src/ui/identity/email_code_screen.dart, TextButton (+1 more)

### Community 71 - "diagnostic_scorer_test.dart"
Cohesion: 0.15
Nodes (12): beast, instrument, killer, main, order, pair, pickAll, psycho (+4 more)

### Community 72 - "String?"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineGroup, groupId, id, relatedArchetypeId, sort, title (+1 more)

### Community 73 - "archetype_tag.dart"
Cohesion: 0.08
Nodes (22): BalanceCalculator, BalanceWeights, compute, fullAxisValue, halfLifeDays, _localDate, pointsPerFullDay, standard (+14 more)

### Community 74 - "sync_banner.dart"
Cohesion: 0.09
Nodes (20): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, kind, message, occurredAt (+12 more)

### Community 75 - "link_flow_test.dart"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "balance_presets.dart"
Cohesion: 0.12
Nodes (15): all, BalancePreset, blurb, cap, capBuster, days, even, fullAxis (+7 more)

### Community 77 - "paid_content_boundary_test.dart"
Cohesion: 0.07
Nodes (27): client, close, configure, content, corePack, db, Device, entitlements (+19 more)

### Community 78 - "first_run_offline_test.dart"
Cohesion: 0.05
Nodes (45): ContentRepository, SilentContentApi, DelayedBodyContentApi, fetchSince, main, RecordingContentApi, actionArchetypeRow, actionRow (+37 more)

### Community 79 - "Implementing Dart and Flutter Test Coverage"
Cohesion: 0.12
Nodes (15): 1. Add Dependencies, 1. Run Tests with VM Service, 2. Collect Coverage and Generate LCOV, 2. Collect Raw Coverage, 3. Feedback Loop: Validate Output, 3. Format to LCOV, Contents, Coverage Directives (+7 more)

### Community 80 - "purchase_gateway.dart"
Cohesion: 0.15
Nodes (12): NoStoreGateway, configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, PurchaseGateway (+4 more)

### Community 81 - "Writing Dart API Documentation"
Cohesion: 0.13
Nodes (14): 1. Banned Tags vs. Prose, 1. Scope and Structure, 2. The Annotation Placement Trap, 2. Tone and Openers, 3. Openers and Tone, 3. Strict Anti-Patterns (Banned), 4. Constructor Linking, 4. Technical Placement & Resolution (+6 more)

### Community 83 - "Building Dart CLI Applications"
Cohesion: 0.14
Nodes (13): Argument Parsing & Command Routing, Building Dart CLI Applications, Compilation & Distribution, Contents, Example: CommandRunner Implementation, Example: Integration Testing with Subprocesses, Examples, Execution & Error Handling (+5 more)

### Community 84 - "entitlement_repository_test.dart"
Cohesion: 0.14
Nodes (13): NoStoreGateway, RevenueCatGateway, EntitlementRepository, core, db, edge, gateway, main (+5 more)

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

### Community 89 - "package:feral/src/domain/run.dart"
Cohesion: 0.17
Nodes (10): earnedFor, main, marks, run, targets, main, run, package:feral/src/domain/run.dart (+2 more)

### Community 90 - "body_purge_test.dart"
Cohesion: 0.12
Nodes (15): api, apiThrows, at, db, fetchSince, Harness, main, packIds (+7 more)

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

### Community 95 - "balance_playground_test.dart"
Cohesion: 0.18
Nodes (10): first, main, open, read, second, tap, package:feral/src/dev/balance_playground.dart, package:feral/src/dev/balance_presets.dart (+2 more)

### Community 96 - "dashboard_screen_test.dart"
Cohesion: 0.06
Nodes (39): archetypes, l10n, main, state, archetypes, figure, l10n, main (+31 more)

### Community 97 - "run_engine.dart"
Cohesion: 0.18
Nodes (10): currentDay, daysNeedingMissed, deriveOutcome, grade, missAllowance, missCount, pointsFor, RunEngine (+2 more)

### Community 98 - "main.dart"
Cohesion: 0.15
Nodes (12): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, src/app/providers.dart (+4 more)

### Community 99 - "day_log.dart"
Cohesion: 0.17
Nodes (11): actionId, committedAt, completedActionIds, dayIndex, DayLog, id, isReported, note (+3 more)

### Community 100 - "package:feral/src/core/clock.dart"
Cohesion: 0.07
Nodes (27): main, deviceZone, info, ProgressRepository, berlin, campaign, day1, dayN (+19 more)

### Community 101 - "Testing and Mocking Dart Applications"
Cohesion: 0.17
Nodes (11): Contents, Examples, Feedback Loop: Test Failures, Generating Mocks, High-Fidelity Mocking and Testing Example, Implementing Unit Tests, Managing Dependencies, Structuring Code for Testability (+3 more)

### Community 104 - "Implementing Flutter Integration Tests"
Cohesion: 0.17
Nodes (11): Contents, Examples, Execution and Profiling, Host Driver Script (`test_driver/integration_test.dart`), Implementing Flutter Integration Tests, Interactive Exploration via MCP, Performance Profiling Driver Script (`test_driver/perf_driver.dart`), Project Setup and Dependencies (+3 more)

### Community 105 - "tokens.dart"
Cohesion: 0.07
Nodes (30): copyWith, EaseOutQuart, hairline, ink, lerp, mutedInk, panel, r0 (+22 more)

### Community 106 - "campaign_detail_screen.dart"
Cohesion: 0.06
Nodes (30): toAction, toCampaign, toDay, archetype, archetypesById, build, campaign, CampaignDetailScreen (+22 more)

### Community 108 - "public.diagnostic_options"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP six-digit code email template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

### Community 112 - "balance_test.dart"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

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

### Community 136 - "account_deletion_test.dart"
Cohesion: 0.18
Nodes (10): api, auth, calls, db, deleteAccount, identity, main, purchases (+2 more)

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

### Community 149 - "static const"
Cohesion: 0.08
Nodes (23): LocalProgressSummary, appName, Brand, accountLabel, build, cancelKey, confirmKey, onCancel (+15 more)

### Community 150 - "link_flow.dart"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 151 - "diagnostic_repository_test.dart"
Cohesion: 0.18
Nodes (10): DiagnosticRepository, db, fetchSince, main, now, repo, seedArchetype, seedCampaign (+2 more)

### Community 152 - "entitlement.dart"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 153 - "account_api.dart"
Cohesion: 0.29
Nodes (7): AccountApi, _client, deleteAccount, message, SupabaseAccountApi, toString, FakeAccountApi

### Community 154 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.25
Nodes (8): OfflineApi, _client, ContentApi, fetchSince, SupabaseContentApi, _SilentContentApi, _NoopApi, package:supabase_flutter/supabase_flutter.dart

### Community 155 - "progress_api.dart"
Cohesion: 0.22
Nodes (9): _client, _conflictTargets, fetchSince, ProgressApi, SupabaseProgressApi, upsert, _SilentProgressApi, FakeProgressApi (+1 more)

### Community 156 - "identity_entitlements_test.dart"
Cohesion: 0.22
Nodes (8): SignedIn, auth, db, main, ownedRow, purchases, repo, identity_repository_test.dart

### Community 157 - "State"
Cohesion: 0.24
Nodes (11): BalancePlayground, _BalancePlaygroundState, _DayPreviewList, _DayPreviewListState, ArchetypeRadar, _ArchetypeRadarState, EmailCodeScreen, _EmailCodeScreenState (+3 more)

### Community 158 - "diagnostic_screen.dart"
Cohesion: 0.25
Nodes (8): build, _choose, createState, DiagnosticScreen, _DiagnosticScreenState, _index, _picks, questions

### Community 159 - "doctrine_screen_test.dart"
Cohesion: 0.25
Nodes (7): entries, groups, l10n, main, package:feral/src/domain/doctrine.dart, package:feral/src/ui/doctrine/doctrine_entry_screen.dart, package:feral/src/ui/doctrine/doctrine_list_screen.dart

### Community 160 - "day_panel.dart"
Cohesion: 0.22
Nodes (9): bodyMd, build, createState, DayPanel, _DayPanelState, _isExpanded, title, _toggle (+1 more)

### Community 161 - "l10n_ext.dart"
Cohesion: 0.29
Nodes (6): l10n, L10nContext, ThemeContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 162 - "backoff.dart"
Cohesion: 0.29
Nodes (6): Backoff, base, delayFor, max, standard, Duration

### Community 163 - "bool get"
Cohesion: 0.33
Nodes (5): fromKey, isMiss, key, Outcome, bool get

### Community 164 - "theme.dart"
Cohesion: 0.25
Nodes (7): appDarkTheme, base, copyWith, scheme, text, tokens, package:google_fonts/google_fonts.dart

### Community 165 - "grade_thresholds.dart"
Cohesion: 0.29
Nodes (6): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, static const GradeThresholds

### Community 166 - "report_sheet.dart"
Cohesion: 0.18
Nodes (11): build, _controller, createState, dispose, outcome, ReportResult, ReportSheet, _ReportSheetState (+3 more)

### Community 167 - "../domain/grade.dart"
Cohesion: 0.40
Nodes (4): gradeName, outcomeLabel, ../domain/grade.dart, ../../domain/outcome.dart

### Community 168 - "unlock_sheet_test.dart"
Cohesion: 0.09
Nodes (20): allText, arm, cancels, deleted, main, pump, serverSucceeds, buys (+12 more)

### Community 169 - "purchase_controller_test.dart"
Cohesion: 0.08
Nodes (23): _, @DriftDatabase, PurchaseController, FeralDatabase, controller, core, db, edge (+15 more)

### Community 170 - "diagnostic_scorer.dart"
Cohesion: 0.25
Nodes (7): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, ../domain/diagnostic.dart

### Community 171 - "ProgressApi"
Cohesion: 0.40
Nodes (5): SilentProgressApi, FakeProgressApi, FakeProgressApi, SilentProgressApi, ProgressApi

### Community 172 - "theme_context.dart"
Cohesion: 0.25
Nodes (10): @immutable, ArchetypePalette, archetypePalette, tokens, AppTokens, AppTokens get, archetype_palette.dart, ArchetypePalette get (+2 more)

### Community 173 - "PackLocked"
Cohesion: 0.50
Nodes (4): AccountDeletionFailed, PackLocked, IdentityAlreadyAttached, Exception

### Community 176 - "campaign_detail_screen_test.dart"
Cohesion: 0.09
Nodes (22): wrap, _archetypesById, _beast, _campaign, _days, _killer, main, _psycho (+14 more)

### Community 177 - "ReminderScheduler"
Cohesion: 0.67
Nodes (3): LocalReminderScheduler, ReminderScheduler, FakeScheduler

### Community 179 - "clock.dart"
Cohesion: 0.38
Nodes (6): Clock, delay, FixedClock, _instant, nowUtc, SystemClock

### Community 180 - "package:flutter/material.dart"
Cohesion: 0.12
Nodes (16): copyWith, forSort, lerp, roles, standard, l10n, main, pair (+8 more)

### Community 183 - "browse_screen_test.dart"
Cohesion: 0.05
Nodes (45): core, edge, free, killer, main, paid, trickster, views (+37 more)

### Community 185 - "_buildHome"
Cohesion: 0.47
Nodes (6): balance, _buildHome, _startRun, clockProvider, progressRepositoryProvider, zoneProvider

### Community 189 - "../../domain/run.dart"
Cohesion: 0.50
Nodes (3): earned, MarkCalculator, ../../domain/run.dart

## Knowledge Gaps
- **2409 isolated node(s):** `PurchaseProblemReason`, `isBusy`, `packId`, `reason`, `storeMessage` (+2404 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2673 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `purchase_controller_test.dart` to `database.dart`, `package:test/test.dart`, `package:feral/src/core/clock.dart`, `identity_repository_test.dart`, `account_deletion_test.dart`, `link_flow_test.dart`, `money_path_test.dart`, `seed_snapshot.dart`, `DateTime`, `entitlement_repository_test.dart`, `sign_in_restore_test.dart`, `diagnostic_repository.dart`, `diagnostic_repository_test.dart`, `sync_push_test.dart`, `identity_entitlements_test.dart`, `entitlement_repository.dart`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `settings_screen_test.dart` to `app_localizations.dart`, `../support/pump.dart`, `package:flutter/material.dart`, `browse_screen_test.dart`, `doctrine_screen_test.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `PurchaseProblemReason`, `isBusy`, `packId` to the rest of the system?**
  _2409 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.012048192771084338 - nodes in this community are weakly interconnected._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.011627906976744186 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.012422360248447204 - nodes in this community are weakly interconnected._
- **Should `sync_scheduler.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._