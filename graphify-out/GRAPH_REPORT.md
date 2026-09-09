# Graph Report - feral-build  (2026-09-09)

## Corpus Check
- 179 files · ~95,670 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2265 nodes · 3214 edges · 131 communities (109 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.78)
- Token cost: 44,000 input · 4,888 output

## Community Hubs (Navigation)
- Drift Database Schema & Rows
- Localization Strings (delegate)
- English Localization Strings
- Sync Status & Backoff
- Home Router & App Shell
- Riverpod Providers Wiring
- Email Code Screen
- Sync Repository (pull/push)
- Content Table Definitions
- Pack Views & Entitlement Tests
- Drift Row & Companion Classes
- User Table Definitions
- Money Path Integration Test
- Time Zone & Run State Tests
- Settings Screen
- Content Repository
- Purchase State Machine
- Identity Domain Model
- Archetype & Doctrine Screens
- Sync Entitlements & Push Tests
- Progress Repository
- Clock & Sync Pull Tests
- Content Repo Offline Tests
- Diagnostic Repository
- Fake Purchase Gateway
- Balance State & Doctrine List
- Home Screen Builders
- Seed Snapshot Loader
- Database & Progress Repo Tests
- Balance & Marks Tests
- Entitlement Repository & Resolver
- Dashboard & Radar Widget Tests
- Completion & Link Sheet Tests
- Two-Device Integration Test
- Identity Repository
- Database Migration Tests
- Run Engine Grade Tests
- Settings Screen Tests
- Reminder Scheduler (notifications)
- Identity Repository Tests
- Widget Test Harness (pump)
- Campaign Domain Model
- Sync Scheduler
- Delete Account Screen
- Account Screen Tests
- Run State Derivation
- DayLog & Outcome Domain
- Link Sheet (Apple/Google sign-in)
- Unlock Sheet & Problem Text
- RevenueCat Webhook Mapping
- Drift Table Data Classes
- RevenueCat Gateway
- Settings Account & Restore Tests
- Purchase Outcome Types
- Pack List Screen
- Completion Screen
- Report Sheet & Info Screens
- App Providers & Bootstrap
- Dashboard Screen
- Mappers & Campaign Detail Screen
- Auth Gateway
- Replace Confirm Screen
- Brand Theme & Sync Banner
- CI & Fork Configuration
- Archetype Radar Painter
- Entitlement Repository Tests
- Sync State Providers
- Diagnostic Domain Model
- App Entry Point (main.dart)
- Run & Grade Domain
- Marks & Run Reconciler
- Diagnostic Scorer Tests
- Account API
- Balance Calculator (engine)
- Grade Thresholds & Labels
- Link Flow Tests
- Link Prompt & Doctrine Tests
- Account Deletion Tests
- Balance Engine Tests
- Email Link Integration Test
- Purchase Gateway Interface
- Supabase Bootstrap
- Diagnostic Repository Tests
- Purchase Domain (StoreProduct)
- Unlock Sheet Tests
- User Schema Migration
- Progress API (offline/supabase)
- Link Flow & Identity Repository
- Doctrine Domain Model
- Pack Domain Model
- Screen State Classes
- Content Schema Migration
- CI Jobs & Integration Tests
- Link Prompt State (prefs)
- Sync State Table
- Entitlement Domain Model
- Identity Entitlements Tests
- Run Engine (engine)
- Completion Flow Tests
- Diagnostic Scorer (engine)
- Clock Core (FixedClock)
- Diagnostic Screen
- Completion Archetype Tests
- Localization Context Extension
- Content API Variants
- Supabase Content API
- Grade Enum
- Delete Account Edge Function
- Diagnostic Schema Migration
- Delete Account Function Config
- RevenueCat Webhook Config
- OTP Email Template
- Localizations Delegate
- Entitlements Table (SQL)

## God Nodes (most connected - your core abstractions)
1. `FeralDatabase` - 33 edges
2. `_HomeRouterState` - 18 edges
3. `AppLocalizations` - 17 edges
4. `DataClass` - 16 edges
5. `contentRepositoryProvider` - 14 edges
6. `userIdProvider` - 12 edges
7. `Clock` - 9 edges
8. `FakePurchaseGateway` - 9 edges
9. `ContentApi` - 8 edges
10. `PurchaseGateway` - 8 edges

## Surprising Connections (you probably didn't know these)
- `Feral CI Workflow` --implements--> `Supabase URL/anon key via --dart-define, never committed`  [INFERRED]
  .github/workflows/ci.yml → README.md
- `CI app job (format, analyze, test)` --implements--> `Strict Dart static analysis config`  [INFERRED]
  .github/workflows/ci.yml → app/analysis_options.yaml
- `CI app job (format, analyze, test)` --references--> `architecture_test.dart layering enforcement`  [INFERRED]
  .github/workflows/ci.yml → README.md
- `Supabase URL/anon key via --dart-define, never committed` --rationale_for--> `Two-device integration test`  [INFERRED]
  README.md → .github/workflows/ci.yml
- `Money path integration test` --shares_data_with--> `purchases_flutter (RevenueCat) integration`  [INFERRED]
  .github/workflows/ci.yml → app/pubspec.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **CI pipeline: app, database, and functions jobs** — _github_workflows_ci_app_job, _github_workflows_ci_database_job, _github_workflows_ci_functions_job [EXTRACTED 1.00]
- **RevenueCat money path verification** — _github_workflows_ci_money_path_integration_test, _github_workflows_ci_webhook_mapping_test, app_pubspec_revenuecat_purchases [INFERRED 0.80]
- **Fork surface: vocabulary, brand, and seed content** — app_lib_src_niche_readme_fork_checklist, app_lib_src_niche_readme_niche_arb_keys, app_lib_src_niche_readme_brand_dart, app_lib_src_niche_readme_supabase_seed [EXTRACTED 1.00]

## Communities (131 total, 5 thin omitted)

### Community 0 - "Drift Database Schema & Rows"
Cohesion: 0.01
Nodes (149): migration, schemaVersion, setWatermark, watermarkFor, class CampaignArchetypeRow extends, class DiagnosticOptionRow extends, class DiagnosticQuestionRow extends, class DiagnosticResultRow extends (+141 more)

### Community 1 - "Localization Strings (delegate)"
Cohesion: 0.02
Nodes (128): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+120 more)

### Community 2 - "English Localization Strings"
Cohesion: 0.02
Nodes (117): abandonActiveRunWarning, abandonAndStartButton, alreadyBoughtButton, appleAccountName, backButton, browseInsteadButton, campaignsTitle, changeEmailButton (+109 more)

### Community 3 - "Sync Status & Backoff"
Cohesion: 0.04
Nodes (46): kind, message, occurredAt, SyncNotice, SyncNoticeKind, SyncStatus, Backoff, base (+38 more)

### Community 4 - "Home Router & App Shell"
Cohesion: 0.04
Nodes (46): build, campaign, _Completed, _confirmReplacement, createState, _diagnostic, didChangeAppLifecycleState, dispose (+38 more)

### Community 5 - "Riverpod Providers Wiring"
Cohesion: 0.05
Nodes (41): androidKey, authGatewayProvider, campaignsByPack, connectivityGateProvider, content, databaseProvider, db, entitlementRepositoryProvider (+33 more)

### Community 6 - "Email Code Screen"
Cohesion: 0.05
Nodes (39): build, _busy, _canResend, changeEmailKey, _code, CodeAccepted, codeFieldKey, codeLength (+31 more)

### Community 7 - "Sync Repository (pull/push)"
Cohesion: 0.05
Nodes (38): _advanceWatermark, api, _clearDirty, clock, consumeNotices, db, DirtyRow, _dirtyRows (+30 more)

### Community 8 - "Content Table Definitions"
Cohesion: 0.06
Nodes (33): archetypeId, blurb, bodyMd, campaignId, color, coverPath, dayIndex, description (+25 more)

### Community 9 - "Pack Views & Entitlement Tests"
Cohesion: 0.07
Nodes (30): core, edge, free, main, paid, views, core, edge (+22 more)

### Community 10 - "Drift Row & Companion Classes"
Cohesion: 0.11
Nodes (33): Insertable, UpdateCompanion, ActionRow, ActionsCompanion, ArchetypeRow, ArchetypesCompanion, CampaignArchetypeRow, CampaignArchetypesCompanion (+25 more)

### Community 11 - "User Table Definitions"
Cohesion: 0.06
Nodes (30): acquiredAt, actionId, campaignId, committedAt, completedAt, dayIndex, dirty, displayName (+22 more)

### Community 12 - "Money Path Integration Test"
Cohesion: 0.07
Nodes (29): actionIdFor, client, close, configure, content, db, Device, entitlements (+21 more)

### Community 13 - "Time Zone & Run State Tests"
Cohesion: 0.07
Nodes (26): deviceZone, info, action, berlin, campaign, log, main, run (+18 more)

### Community 14 - "Settings Screen"
Cohesion: 0.07
Nodes (28): _askForTime, _at, build, _changeTime, createState, deleteRowKey, _enabled, _formattedTime (+20 more)

### Community 15 - "Content Repository"
Cohesion: 0.07
Nodes (27): actionFor, actionsFor, _advanceWatermark, api, applyRows, archetypeIdsFor, archetypesById, _at (+19 more)

### Community 16 - "Purchase State Machine"
Cohesion: 0.10
Nodes (24): buy, entitlements, gateway, packId, PurchaseComplete, PurchaseController, PurchaseIdle, PurchaseInProgress (+16 more)

### Community 17 - "Identity Domain Model"
Cohesion: 0.09
Nodes (25): accessToken, AppleGoogleToken, AttachOutcome, AuthProvider, campaignTitle, Cancelled, CodeSent, error (+17 more)

### Community 18 - "Archetype & Doctrine Screens"
Cohesion: 0.08
Nodes (22): StoredDiagnostic, Archetype, blurb, color, id, key, name, sort (+14 more)

### Community 19 - "Sync Entitlements & Push Tests"
Cohesion: 0.08
Nodes (23): db, entitlementRow, fetched, fetchSince, main, repoWith, rows, upsert (+15 more)

### Community 20 - "Progress Repository"
Cohesion: 0.08
Nodes (23): abandonRun, activeRun, allDayLogs, allRuns, applyRollover, _asUtc, campaignId, clock (+15 more)

### Community 21 - "Clock & Sync Pull Tests"
Cohesion: 0.10
Nodes (21): SyncRepository, SyncRunner, main, api, db, insertLocalRun, main, remoteLog (+13 more)

### Community 22 - "Content Repo Offline Tests"
Cohesion: 0.09
Nodes (21): _, @DriftDatabase, FeralDatabase, actionRow, archetypeRow, db, fetchSince, main (+13 more)

### Community 23 - "Diagnostic Repository"
Cohesion: 0.09
Nodes (22): campaignId, _Candidate, clock, content, db, difficulty, hasCompleted, latestFor (+14 more)

### Community 24 - "Fake Purchase Gateway"
Cohesion: 0.09
Nodes (22): catalogue, _changes, configure, configureCalls, currentUserId, dispose, failSwitchUser, forgetUser (+14 more)

### Community 25 - "Balance State & Doctrine List"
Cohesion: 0.10
Nodes (20): archetypes, balance, BalanceState, load, marks, marksFor, maxValue, normalizedFor (+12 more)

### Community 26 - "Home Screen Builders"
Cohesion: 0.14
Nodes (22): clockProvider, contentRepositoryProvider, progressRepositoryProvider, purchaseGatewayProvider, reminderSchedulerProvider, userIdProvider, zoneProvider, _archetypesFor (+14 more)

### Community 27 - "Seed Snapshot Loader"
Cohesion: 0.10
Nodes (19): content, db, loadIfEmpty, SeedSnapshotLoader, ContentRepository, main, content, db (+11 more)

### Community 28 - "Database & Progress Repo Tests"
Cohesion: 0.11
Nodes (18): ProgressRepository, db, main, db, main, db, main, repo (+10 more)

### Community 29 - "Balance & Marks Tests"
Cohesion: 0.10
Nodes (19): actions, archetypes, berlin, build, log, main, run, start (+11 more)

### Community 30 - "Entitlement Repository & Resolver"
Cohesion: 0.10
Nodes (19): clock, db, error, gateway, isUnlocked, recordLocalGrant, resolver, restore (+11 more)

### Community 31 - "Dashboard & Radar Widget Tests"
Cohesion: 0.10
Nodes (19): archetypes, l10n, main, pump, state, action, archetypes, balance (+11 more)

### Community 32 - "Completion & Link Sheet Tests"
Cohesion: 0.11
Nodes (18): dismissals, links, main, pump, cancels, chosen, main, pump (+10 more)

### Community 33 - "Two-Device Integration Test"
Cohesion: 0.10
Nodes (19): a, actionIdFor, api, b, backdate, campaignId, client, close (+11 more)

### Community 34 - "Identity Repository"
Cohesion: 0.10
Nodes (19): attach, auth, completeSignIn, confirmEmailReplacement, db, entitlements, isLinked, linkedIdentity (+11 more)

### Community 35 - "Database Migration Tests"
Cohesion: 0.11
Nodes (18): db, ddl, main, probe, raw, _schemaStatementsFor, _v1Tables, _v3Tables (+10 more)

### Community 36 - "Run Engine Grade Tests"
Cohesion: 0.12
Nodes (16): main, b, main, engine, log, main, misses, engine (+8 more)

### Community 37 - "Settings Screen Tests"
Cohesion: 0.10
Nodes (19): disable, enable, enabled, isEnabled, l10n, main, offeredTime, permissionGranted (+11 more)

### Community 38 - "Reminder Scheduler (notifications)"
Cohesion: 0.11
Nodes (18): disable, enable, _enabledKey, _hourKey, isEnabled, LocalReminderScheduler, _minuteKey, _notificationId (+10 more)

### Community 39 - "Identity Repository Tests"
Cohesion: 0.11
Nodes (18): addressTaken, auth, calls, codeIsWrong, currentUserId, db, identity, identityTaken (+10 more)

### Community 40 - "Widget Test Harness (pump)"
Cohesion: 0.14
Nodes (15): AppLocalizations, AppLocalizationsEn, of, wrap, l10n, main, pair, questions (+7 more)

### Community 41 - "Campaign Domain Model"
Cohesion: 0.11
Nodes (17): ActionSpec, archetypeId, bodyMd, campaignId, dayIndex, difficulty, effort, id (+9 more)

### Community 42 - "Sync Scheduler"
Cohesion: 0.11
Nodes (17): SyncScheduler, calls, consumeNotices, _controller, dispose, gate, goOffline, goOnline (+9 more)

### Community 43 - "Delete Account Screen"
Cohesion: 0.11
Nodes (17): _armed, build, _busy, cancelKey, confirmKey, confirmWord, createState, _delete (+9 more)

### Community 44 - "Account Screen Tests"
Cohesion: 0.11
Nodes (16): allText, arm, cancels, deleted, main, pump, serverSucceeds, allText (+8 more)

### Community 45 - "Run State Derivation"
Cohesion: 0.12
Nodes (16): campaign, currentDay, derive, grade, isCommittedToday, isFinalDay, isFinished, isReportedToday (+8 more)

### Community 46 - "DayLog & Outcome Domain"
Cohesion: 0.12
Nodes (15): actionId, committedAt, dayIndex, DayLog, id, isReported, note, outcome (+7 more)

### Community 47 - "Link Sheet (Apple/Google sign-in)"
Cohesion: 0.12
Nodes (16): AppleCredentials, build, cancelKey, explanationKey, GoogleCredentials, _initialized, keyFor, labelFor (+8 more)

### Community 48 - "Unlock Sheet & Problem Text"
Cohesion: 0.12
Nodes (16): build, _busy, buyKey, campaigns, closeKey, onBuy, onClose, onRestore (+8 more)

### Community 49 - "RevenueCat Webhook Mapping"
Cohesion: 0.16
Nodes (11): RFC-4122, ADR-0017, ADR-0019, asProductId(), asUserId(), asUserIds(), planWrites(), ADR-0017 (+3 more)

### Community 50 - "Drift Table Data Classes"
Cohesion: 0.23
Nodes (16): @DataClassName, Actions, Archetypes, CampaignArchetypes, Campaigns, DiagnosticOptions, DiagnosticQuestions, DoctrineEntries (+8 more)

### Community 51 - "RevenueCat Gateway"
Cohesion: 0.12
Nodes (15): apiKey, _changes, configure, _configured, forgetUser, outcomeForErrorCode, _ownedFrom, ownedProductChanges (+7 more)

### Community 52 - "Settings Account & Restore Tests"
Cohesion: 0.14
Nodes (14): RestoreSummary, deletes, links, main, pump, l10n, main, pump (+6 more)

### Community 53 - "Purchase Outcome Types"
Cohesion: 0.17
Nodes (14): PurchaseAlreadyOwned, PurchaseCancelled, PurchaseFailed, PurchaseOutcome, PurchasePending, PurchaseSucceeded, main, owned (+6 more)

### Community 54 - "Pack List Screen"
Cohesion: 0.12
Nodes (15): build, campaigns, isUnlocked, pack, PackListScreen, packs, PackView, CompletionScreen (+7 more)

### Community 55 - "Completion Screen"
Cohesion: 0.12
Nodes (15): build, campaign, grade, gradeKey, linkDismissKey, linkPromptKey, linkPromptTextKey, marksEarned (+7 more)

### Community 56 - "Report Sheet & Info Screens"
Cohesion: 0.13
Nodes (13): build, _controller, createState, dispose, outcome, build, DoctrineIntroScreen, onContinue (+5 more)

### Community 57 - "App Providers & Bootstrap"
Cohesion: 0.15
Nodes (15): accountApiProvider, diagnosticRepositoryProvider, identityRepositoryProvider, linkPromptStateProvider, seedSnapshotLoaderProvider, _boot, _bootstrapContent, _dismissLinkPrompt (+7 more)

### Community 58 - "Dashboard Screen"
Cohesion: 0.13
Nodes (14): RunState, balance, banner, build, onCommit, onOpenDoctrine, onOpenSettings, _report (+6 more)

### Community 59 - "Mappers & Campaign Detail Screen"
Cohesion: 0.13
Nodes (13): toAction, toCampaign, build, campaign, CampaignDetailScreen, hasActiveRun, isUnlocked, missAllowance (+5 more)

### Community 60 - "Auth Gateway"
Cohesion: 0.14
Nodes (14): AuthGateway, _client, currentUserId, linkedIdentity, linkIdentity, _oauth, sendEmailCode, signIn (+6 more)

### Community 61 - "Replace Confirm Screen"
Cohesion: 0.13
Nodes (13): LocalProgressSummary, accountLabel, build, cancelKey, confirmKey, onCancel, onConfirm, ReplaceConfirmScreen (+5 more)

### Community 62 - "Brand Theme & Sync Banner"
Cohesion: 0.14
Nodes (13): appName, Brand, colorSeed, theme, build, dismissKey, _message, messageKey (+5 more)

### Community 63 - "CI & Fork Configuration"
Cohesion: 0.16
Nodes (14): CI app job (format, analyze, test), Strict Dart static analysis config, visibleForTesting misuse promoted to error, Non-nullable localization getters (fail loudly at wiring), brand.dart (app name, color seed, theme), Fork checklist, [niche] ARB keys (product vocabulary and worldview), supabase/seed content (+6 more)

### Community 64 - "Archetype Radar Painter"
Cohesion: 0.14
Nodes (13): ../app/balance_state.dart, build, fillColor, gridColor, paint, _RadarPainter, shouldRepaint, size (+5 more)

### Community 65 - "Entitlement Repository Tests"
Cohesion: 0.14
Nodes (13): NoStoreGateway, PurchaseGateway, RevenueCatGateway, EntitlementRepository, core, db, edge, gateway (+5 more)

### Community 66 - "Sync State Providers"
Cohesion: 0.15
Nodes (12): build, dismiss, syncNoticeProvider, syncStatusProvider, watch, _homeScreen, main, ../data/identity_repository_test.dart (+4 more)

### Community 67 - "Diagnostic Domain Model"
Cohesion: 0.14
Nodes (13): archetypeId, archetypeIds, DiagnosticOption, DiagnosticPick, DiagnosticQuestion, id, label, optionId (+5 more)

### Community 68 - "App Entry Point (main.dart)"
Cohesion: 0.15
Nodes (12): build, ensureAnonymousSession, FeralApp, initializeSupabase, main, prefs, zone, src/app/providers.dart (+4 more)

### Community 69 - "Run & Grade Domain"
Cohesion: 0.15
Nodes (12): campaignId, completedAt, fromKey, grade, id, isHardened, key, RunStatus (+4 more)

### Community 70 - "Marks & Run Reconciler"
Cohesion: 0.15
Nodes (11): CampaignRun, earned, MarkCalculator, abandon, isConflict, keep, localSurvived, Reconciliation (+3 more)

### Community 71 - "Diagnostic Scorer Tests"
Cohesion: 0.15
Nodes (12): alchemist, creature, instrument, killer, main, order, pair, pickAll (+4 more)

### Community 72 - "Account API"
Cohesion: 0.18
Nodes (11): AccountApi, AccountDeletionFailed, _client, deleteAccount, message, SupabaseAccountApi, toString, PackLocked (+3 more)

### Community 73 - "Balance Calculator (engine)"
Cohesion: 0.17
Nodes (11): BalanceCalculator, BalanceWeights, baseFor, compute, done, halfLifeDays, _localDate, partial (+3 more)

### Community 74 - "Grade Thresholds & Labels"
Cohesion: 0.17
Nodes (10): allowanceFor, daysPerAllowedMiss, gradeFor, GradeThresholds, standard, gradeName, outcomeLabel, ../domain/grade.dart (+2 more)

### Community 75 - "Link Flow Tests"
Cohesion: 0.17
Nodes (11): auth, confirmAnswer, confirmations, db, flow, identity, labelShown, main (+3 more)

### Community 76 - "Link Prompt & Doctrine Tests"
Cohesion: 0.17
Nodes (10): main, entries, groups, l10n, main, package:feral/src/app/link_prompt_state.dart, package:feral/src/domain/doctrine.dart, package:feral/src/ui/doctrine/doctrine_entry_screen.dart (+2 more)

### Community 77 - "Account Deletion Tests"
Cohesion: 0.17
Nodes (11): api, auth, calls, db, deleteAccount, identity, main, purchases (+3 more)

### Community 78 - "Balance Engine Tests"
Cohesion: 0.17
Nodes (11): action, actions, balanceAt, berlin, calculator, log, main, nowPlus (+3 more)

### Community 79 - "Email Link Integration Test"
Cohesion: 0.18
Nodes (10): client, codeSentTo, freshAddress, gateway, mailpit, mailpitJson, main, messagesTo (+2 more)

### Community 80 - "Purchase Gateway Interface"
Cohesion: 0.18
Nodes (10): configure, forgetUser, ownedProductChanges, ownedProductIds, products, purchase, restore, switchUser (+2 more)

### Community 81 - "Supabase Bootstrap"
Cohesion: 0.18
Nodes (10): attempt, auth, ensureAnonymousSession, existing, initialize, initializeSupabase, _retryDelay, seconds (+2 more)

### Community 82 - "Diagnostic Repository Tests"
Cohesion: 0.18
Nodes (10): DiagnosticRepository, db, fetchSince, main, now, repo, seedArchetype, seedCampaign (+2 more)

### Community 83 - "Purchase Domain (StoreProduct)"
Cohesion: 0.18
Nodes (10): error, id, message, ownedProductIds, priceString, RestoreResult, StoreProduct, succeeded (+2 more)

### Community 84 - "Unlock Sheet Tests"
Cohesion: 0.18
Nodes (10): buys, campaigns, closes, edge, l10n, main, pump, restores (+2 more)

### Community 85 - "User Schema Migration"
Cohesion: 0.29
Nodes (10): auth.users, public.actions, public.campaigns, public.packs, public.campaign_runs, public.day_logs, public.diagnostic_results, public.entitlements (+2 more)

### Community 86 - "Progress API (offline/supabase)"
Cohesion: 0.22
Nodes (9): OfflineApi, _client, _conflictTargets, fetchSince, ProgressApi, SupabaseProgressApi, upsert, FakeProgressApi (+1 more)

### Community 87 - "Link Flow & Identity Repository"
Cohesion: 0.20
Nodes (9): attach, identity, _link, LinkFlow, sendEmailCode, verifyEmailCode, IdentityRepository, ../data/repositories/identity_repository.dart (+1 more)

### Community 88 - "Doctrine Domain Model"
Cohesion: 0.20
Nodes (9): blurb, bodyMd, DoctrineGroup, groupId, id, relatedArchetypeId, sort, title (+1 more)

### Community 89 - "Pack Domain Model"
Cohesion: 0.20
Nodes (9): coverPath, description, id, isCore, key, Pack, sort, storeProductId (+1 more)

### Community 90 - "Screen State Classes"
Cohesion: 0.27
Nodes (10): ReportSheet, _ReportSheetState, DiagnosticScreen, _DiagnosticScreenState, DeleteAccountScreen, _DeleteAccountScreenState, SettingsScreen, _SettingsScreenState (+2 more)

### Community 91 - "Content Schema Migration"
Cohesion: 0.38
Nodes (8): public, public.actions, public.archetypes, public.campaign_archetypes, public.campaigns, public.doctrine_entries, public.doctrine_groups, public.packs

### Community 92 - "CI Jobs & Integration Tests"
Cohesion: 0.25
Nodes (9): Feral CI Workflow, CI database job (supabase test db, pgTAP), CI functions job (Edge Function type-check and test), Headless Linux runner has no device target, Money path integration test, Two-device integration test, RevenueCat webhook mapping test, purchases_flutter (RevenueCat) integration (+1 more)

### Community 93 - "Link Prompt State (prefs)"
Cohesion: 0.22
Nodes (8): _key, LinkPromptState, markDismissed, _prefs, reset, shouldPrompt, package:shared_preferences/shared_preferences.dart, SharedPreferences

### Community 94 - "Sync State Table"
Cohesion: 0.22
Nodes (8): lastPulledAt, primaryKey, SyncState, syncTable, watermark, DateTimeColumn get, Set, TextColumn get

### Community 95 - "Entitlement Domain Model"
Cohesion: 0.22
Nodes (8): acquiredAt, Entitlement, EntitlementSource, fromKey, key, packId, source, userId

### Community 96 - "Identity Entitlements Tests"
Cohesion: 0.22
Nodes (8): Linked, auth, db, main, ownedRow, purchases, repo, package:feral/src/data/repositories/identity_repository.dart

### Community 97 - "Run Engine (engine)"
Cohesion: 0.22
Nodes (8): currentDay, daysNeedingMissed, grade, missAllowance, missCount, RunEngine, ../domain/day_log.dart, grade_thresholds.dart

### Community 98 - "Completion Flow Tests"
Cohesion: 0.22
Nodes (8): berlin, campaign, day1, dayN, db, main, repoAt, runAllDays

### Community 99 - "Diagnostic Scorer (engine)"
Cohesion: 0.25
Nodes (7): DiagnosticOutcome, DiagnosticScorer, score, scores, _weakest, weakestArchetypeId, ../../domain/diagnostic.dart

### Community 100 - "Clock Core (FixedClock)"
Cohesion: 0.38
Nodes (6): Clock, FixedClock, _instant, nowUtc, SystemClock, DateTime

### Community 101 - "Diagnostic Screen"
Cohesion: 0.29
Nodes (6): build, _choose, createState, _index, _picks, questions

### Community 102 - "Completion Archetype Tests"
Cohesion: 0.29
Nodes (6): campaign, killer, l10n, main, pump, package:feral/src/domain/archetype.dart

### Community 103 - "Localization Context Extension"
Cohesion: 0.33
Nodes (5): l10n, L10nContext, AppLocalizations get, BuildContext, package:flutter/widgets.dart

### Community 104 - "Content API Variants"
Cohesion: 0.33
Nodes (6): ContentApi, SupabaseContentApi, FakeContentApi, _NoopApi, OfflineContentApi, _NoopApi

### Community 105 - "Supabase Content API"
Cohesion: 0.40
Nodes (4): _client, fetchSince, package:supabase_flutter/supabase_flutter.dart, SupabaseClient

### Community 106 - "Grade Enum"
Cohesion: 0.40
Nodes (4): earnsMark, fromKey, Grade, key

### Community 108 - "Diagnostic Schema Migration"
Cohesion: 0.67
Nodes (3): public.diagnostic_options, public.diagnostic_questions, public.archetypes

### Community 111 - "OTP Email Template"
Cohesion: 0.67
Nodes (3): ADR-0016 (code-only email, no link to tap), Brand-free email wording (name unsettled in Q1), OTP six-digit code email template

## Knowledge Gaps
- **1555 isolated node(s):** `mailpit`, `client`, `gateway`, `main`, `freshAddress` (+1550 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1731 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeralDatabase` connect `Content Repo Offline Tests` to `Drift Database Schema & Rows`, `Riverpod Providers Wiring`, `Sync Repository (pull/push)`, `Money Path Integration Test`, `Content Repository`, `Purchase State Machine`, `Sync Entitlements & Push Tests`, `Progress Repository`, `Clock & Sync Pull Tests`, `Diagnostic Repository`, `Seed Snapshot Loader`, `Database & Progress Repo Tests`, `Entitlement Repository & Resolver`, `Two-Device Integration Test`, `Identity Repository`, `Database Migration Tests`, `Identity Repository Tests`, `Entitlement Repository Tests`, `Link Flow Tests`, `Account Deletion Tests`, `Diagnostic Repository Tests`, `Identity Entitlements Tests`, `Completion Flow Tests`?**
  _High betweenness centrality (0.111) - this node is a cross-community bridge._
- **Why does `AppLocalizations` connect `Widget Test Harness (pump)` to `Localization Strings (delegate)`, `Settings Screen Tests`, `Completion Archetype Tests`, `Pack Views & Entitlement Tests`, `Link Prompt & Doctrine Tests`, `Localizations Delegate`, `Settings Account & Restore Tests`, `Unlock Sheet Tests`, `Dashboard & Radar Widget Tests`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `Clock` connect `Clock Core (FixedClock)` to `Sync Status & Backoff`, `Riverpod Providers Wiring`, `Sync Repository (pull/push)`, `Progress Repository`, `Diagnostic Repository`, `Entitlement Repository & Resolver`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `mailpit`, `client`, `gateway` to the rest of the system?**
  _1555 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Drift Database Schema & Rows` be split into smaller, more focused modules?**
  _Cohesion score 0.013333333333333334 - nodes in this community are weakly interconnected._
- **Should `Localization Strings (delegate)` be split into smaller, more focused modules?**
  _Cohesion score 0.015503875968992248 - nodes in this community are weakly interconnected._
- **Should `English Localization Strings` be split into smaller, more focused modules?**
  _Cohesion score 0.01694915254237288 - nodes in this community are weakly interconnected._