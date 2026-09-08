import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/balance_state.dart';
import '../app/providers.dart';
import '../app/run_state.dart';
import '../app/sync_state.dart';
import '../data/repositories/diagnostic_repository.dart';
import '../domain/archetype.dart';
import '../domain/campaign.dart';
import '../domain/diagnostic.dart';
import '../domain/doctrine.dart';
import '../domain/grade.dart';
import '../domain/outcome.dart';
import '../domain/sync_status.dart';
import 'browse/campaign_detail_screen.dart';
import 'browse/pack_list_screen.dart';
import 'completion/completion_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'doctrine/doctrine_entry_screen.dart';
import 'doctrine/doctrine_list_screen.dart';
import 'onboarding/diagnostic_result_screen.dart';
import 'onboarding/diagnostic_screen.dart';
import 'onboarding/doctrine_intro_screen.dart';
import 'onboarding/privacy_notice_screen.dart';
import 'settings/delete_account_screen.dart';
import 'settings/settings_screen.dart';
import 'sync/sync_banner.dart';

/// Where the app is. Onboarding runs once; after that the user is either in a
/// run, looking at a finished one, or browsing for the next.
enum _Step { loading, intro, privacy, diagnostic, result, home }

/// Loads content, routes the first run through onboarding, and then shows the
/// dashboard, the completion screen, or browse.
///
/// **Every network await here is wrapped and non-fatal.** A first launch with
/// no signal must still reach a started campaign, so the bundled snapshot is
/// applied before any pull is attempted and a failed pull changes nothing.
class HomeRouter extends ConsumerStatefulWidget {
  const HomeRouter({super.key});

  @override
  ConsumerState<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends ConsumerState<HomeRouter>
    with WidgetsBindingObserver {
  _Step _step = _Step.loading;

  List<DiagnosticQuestion> _questions = const [];
  StoredDiagnostic? _diagnostic;
  Archetype? _weakest;
  Campaign? _recommended;

  _Home? _home;

  /// Computed when a completion is reached, never in build: it reads a
  /// preference, and ADR-0013 allows exactly one asking.
  bool _showLinkPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// RunState is derived once per load, against the clock as it was at that
  /// moment. A phone backgrounded overnight and reopened the next morning would
  /// otherwise still be showing yesterday's day and yesterday's action — which
  /// is precisely the daily loop, not an edge case. Re-deriving on resume also
  /// runs rollover, so the missed day is written when the user comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed && _step == _Step.home) {
      _reloadHome();
    }
  }

  // --------------------------------------------------------------- bootstrap

  Future<void> _bootstrapContent() async {
    // Bundled content first: a first launch with no signal must still reach a
    // started campaign.
    await ref.read(seedSnapshotLoaderProvider).loadIfEmpty();

    // Then reconcile, if we can. A failed pull is never fatal — whatever is
    // cached still works.
    try {
      await ref.read(contentRepositoryProvider).pull();
    } catch (_) {}
  }

  Future<void> _boot() async {
    await _bootstrapContent();

    final diagnostic = ref.read(diagnosticRepositoryProvider);
    final userId = ref.read(userIdProvider);

    if (await diagnostic.hasCompleted(userId)) {
      await _loadHome();
      return;
    }

    final questions = await diagnostic.questions();
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _step = _Step.intro;
    });
  }

  // -------------------------------------------------------------- diagnostic

  Future<void> _submitDiagnostic(List<DiagnosticPick> picks) async {
    final content = ref.read(contentRepositoryProvider);
    final stored = await ref
        .read(diagnosticRepositoryProvider)
        .submit(userId: ref.read(userIdProvider), picks: picks);

    final archetypes = await content.archetypesById();
    final recommended = await content.campaignById(
      stored.recommendedCampaignId,
    );
    if (!mounted) return;

    setState(() {
      _diagnostic = stored;
      _weakest = archetypes[stored.weakestArchetypeId];
      _recommended = recommended;
      _step = _Step.result;
    });
  }

  // -------------------------------------------------------------------- runs

  Future<void> _startRun(String campaignId) async {
    final progress = ref.read(progressRepositoryProvider);
    final userId = ref.read(userIdProvider);

    // Exactly one run may be active. Replacing one is the only destructive
    // action in the product, and the detail screen has already said so.
    final active = await progress.activeRun(userId);
    if (active != null) await progress.abandonRun(active.id);

    await progress.startRun(userId: userId, campaignId: campaignId);
    await _loadHome();
  }

  Future<BalanceState> _balance() async {
    final content = ref.read(contentRepositoryProvider);
    final progress = ref.read(progressRepositoryProvider);
    final userId = ref.read(userIdProvider);

    final runs = await progress.allRuns(userId);
    final logs = await progress.allDayLogs(userId);

    final actionsById = <String, ActionSpec>{};
    final archetypeIdsByCampaign = <String, List<String>>{};
    for (final campaignId in runs.map((r) => r.campaignId).toSet()) {
      for (final action in await content.actionsFor(campaignId)) {
        actionsById[action.id] = action;
      }
      archetypeIdsByCampaign[campaignId] = await content.archetypeIdsFor(
        campaignId,
      );
    }

    final archetypes = (await content.archetypesById()).values.toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    return BalanceState.load(
      runs: runs,
      logs: logs,
      actionsById: actionsById,
      archetypes: archetypes,
      archetypeIdsByCampaign: archetypeIdsByCampaign,
      zone: ref.read(zoneProvider),
      now: ref.read(clockProvider).nowUtc(),
    );
  }

  Future<List<Archetype>> _archetypesFor(String campaignId) async {
    final content = ref.read(contentRepositoryProvider);
    final byId = await content.archetypesById();
    return [
      for (final id in await content.archetypeIdsFor(campaignId))
        if (byId[id] != null) byId[id]!,
    ];
  }

  Future<List<PackView>> _browse() async {
    final content = ref.read(contentRepositoryProvider);
    return [
      for (final pack in await content.packs())
        PackView(
          pack: pack,
          campaigns: await content.campaignsFor(pack.id),
          // Entitlements are plan 4. Until then only the core pack is usable,
          // and everything else renders as a teaser that cannot be started.
          isUnlocked: pack.isCore,
        ),
    ];
  }

  Future<_Home> _buildHome() async {
    final content = ref.read(contentRepositoryProvider);
    final progress = ref.read(progressRepositoryProvider);
    final engine = progress.engine;

    final run = await progress.activeRun(ref.read(userIdProvider));
    final campaign = run == null
        ? null
        : await content.campaignById(run.campaignId);

    // No run, or content lagging a run after a partial sync. Browse is a
    // recoverable place to be; the run is untouched and reappears when the
    // content arrives.
    if (run == null || campaign == null) {
      return _Home(browse: await _browse(), balance: await _balance());
    }

    final actions = await content.actionsFor(campaign.id);
    if (actions.isNotEmpty) {
      await progress.applyRollover(
        run: run,
        lengthDays: campaign.lengthDays,
        actionIdForDay: (day) => actions
            .firstWhere((a) => a.dayIndex == day, orElse: () => actions.first)
            .id,
      );
    }

    // Rollover may have resolved the final day, so completion is attempted
    // after it and before the run state is shown.
    final grade = await progress.completeRunIfFinished(
      run: run,
      campaign: campaign,
    );
    if (grade != null) {
      final logs = await progress.logsFor(run.id);
      _showLinkPrompt = await ref
          .read(linkPromptStateProvider)
          .shouldPrompt(
            isLinked: ref.read(identityRepositoryProvider).isLinked,
          );
      return _Home(
        completed: _Completed(
          grade: grade,
          campaign: campaign,
          missCount: engine.missCount(logs),
          missAllowance: engine.missAllowance(campaign.lengthDays),
          marksEarned: grade.earnsMark
              ? await _archetypesFor(campaign.id)
              : const [],
        ),
        browse: await _browse(),
        balance: await _balance(),
      );
    }

    final logs = await progress.logsFor(run.id);
    final zone = ref.read(zoneProvider);
    final now = ref.read(clockProvider).nowUtc();
    final day = RunState.derive(
      run: run,
      campaign: campaign,
      logs: logs,
      zone: zone,
      now: now,
    ).currentDay;

    return _Home(
      run: RunState.derive(
        run: run,
        campaign: campaign,
        logs: logs,
        todayAction: await content.actionFor(campaign.id, day),
        zone: zone,
        now: now,
      ),
      browse: await _browse(),
      balance: await _balance(),
    );
  }

  Future<void> _loadHome() async {
    final home = await _buildHome();
    if (!mounted) return;
    setState(() {
      _home = home;
      _step = _Step.home;
    });
  }

  Future<void> _openDeleteAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => DeleteAccountScreen(
          isLinked: ref.read(identityRepositoryProvider).isLinked,
          onConfirmDelete: () async {
            try {
              await ref.read(accountApiProvider).deleteAccount();
              return true;
            } catch (_) {
              // The screen says nothing was deleted, and nothing was.
              return false;
            }
          },
          onCancel: () => Navigator.of(routeContext).pop(),
          onDeleted: () async {
            await ref.read(identityRepositoryProvider).resetToFreshAnonymous();
            await ref.read(linkPromptStateProvider).reset();
            if (!mounted) return;
            // Land on first-run, never on a broken signed-out screen.
            Navigator.of(context).popUntil((r) => r.isFirst);
            await _boot();
          },
        ),
      ),
    );
  }

  Future<void> _dismissLinkPrompt() async {
    await ref.read(linkPromptStateProvider).markDismissed();
    if (!mounted) return;
    setState(() => _showLinkPrompt = false);
  }

  Future<void> _reloadHome() async {
    final home = await _buildHome();
    if (!mounted) return;
    setState(() => _home = home);
  }

  // -------------------------------------------------------------- navigation

  Future<void> _openDoctrine() async {
    final content = ref.read(contentRepositoryProvider);
    final groups = await content.doctrineGroups();
    final entries = <String, List<DoctrineEntry>>{};
    for (final group in groups) {
      entries[group.id] = await content.doctrineEntriesFor(group.id);
    }
    if (!mounted) return;

    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => DoctrineListScreen(
          groups: groups,
          entriesByGroup: entries,
          onOpen: (entry) => navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => DoctrineEntryScreen(entry: entry),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          scheduler: ref.read(reminderSchedulerProvider),
          linkedIdentity: ref.read(identityRepositoryProvider).linkedIdentity,
          onLink: () {},
          onDeleteAccount: _openDeleteAccount,
          onRestorePurchases: () {},
        ),
      ),
    );
  }

  Future<void> _openCampaign(
    Campaign campaign, {
    required bool isUnlocked,
  }) async {
    final progress = ref.read(progressRepositoryProvider);
    final targets = await _archetypesFor(campaign.id);
    final hasActiveRun =
        await progress.activeRun(ref.read(userIdProvider)) != null;
    if (!mounted) return;

    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CampaignDetailScreen(
          campaign: campaign,
          targets: targets,
          missAllowance: progress.engine.missAllowance(campaign.lengthDays),
          isUnlocked: isUnlocked,
          hasActiveRun: hasActiveRun,
          onStart: () async {
            navigator.pop();
            await _startRun(campaign.id);
          },
          // Purchases are plan 4. Nothing but the core pack exists yet, so a
          // locked pack cannot in practice be reached.
          onUnlock: () {},
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _Step.intro => DoctrineIntroScreen(
        onContinue: () => setState(() => _step = _Step.privacy),
      ),
      _Step.privacy => PrivacyNoticeScreen(
        onAccept: () => setState(() => _step = _Step.diagnostic),
      ),
      _Step.diagnostic => DiagnosticScreen(
        questions: _questions,
        onComplete: _submitDiagnostic,
      ),
      _Step.result => _result(),
      _Step.home => _homeScreen(),
    };
  }

  Widget _result() {
    final diagnostic = _diagnostic;
    final weakest = _weakest;
    final recommended = _recommended;

    // The recommendation cannot be shown without all three. Browse is the
    // recoverable fallback rather than an error screen — the user still starts
    // a campaign, which is the only thing this screen exists to achieve.
    if (diagnostic == null || weakest == null || recommended == null) {
      _loadHome();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DiagnosticResultScreen(
      result: diagnostic,
      weakest: weakest,
      recommended: recommended,
      onStart: () => _startRun(recommended.id),
      onBrowse: _loadHome,
    );
  }

  Widget _homeScreen() {
    final home = _home;
    if (home == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final completed = home.completed;
    if (completed != null) {
      return CompletionScreen(
        grade: completed.grade,
        campaign: completed.campaign,
        missCount: completed.missCount,
        missAllowance: completed.missAllowance,
        marksEarned: completed.marksEarned,
        showLinkPrompt: _showLinkPrompt,
        onLink: () {},
        onDismissLinkPrompt: _dismissLinkPrompt,
        onBrowse: _reloadHome,
      );
    }

    final run = home.run;
    final balance = home.balance;
    if (run == null || balance == null) {
      return PackListScreen(
        packs: home.browse,
        onOpen: (campaign) => _openCampaign(
          campaign,
          isUnlocked: home.browse
              .firstWhere((v) => v.pack.id == campaign.packId)
              .isUnlocked,
        ),
      );
    }

    return DashboardScreen(
      state: run,
      balance: balance,
      banner: SyncBanner(
        status: ref.watch(syncStatusProvider).value ?? SyncStatus.idle,
        notices: ref.watch(syncNoticeProvider),
        onDismissNotice: ref.read(syncNoticeProvider.notifier).dismiss,
      ),
      onOpenDoctrine: _openDoctrine,
      onOpenSettings: _openSettings,
      onCommit: () async {
        final action = run.todayAction;
        if (action == null) return;
        await ref
            .read(progressRepositoryProvider)
            .commitToday(
              run: run.run,
              dayIndex: run.currentDay,
              actionId: action.id,
            );
        await _reloadHome();
      },
      onReport: (Outcome outcome, String? note) async {
        final action = run.todayAction;
        if (action == null) return;
        await ref
            .read(progressRepositoryProvider)
            .report(
              run: run.run,
              dayIndex: run.currentDay,
              actionId: action.id,
              outcome: outcome,
              note: note,
            );
        await _reloadHome();
      },
    );
  }
}

/// What the home step needs in one load. The run state and the balance have
/// different lifetimes — the balance spans every run the user has — so they are
/// assembled together here rather than merged into one view model.
class _Home {
  const _Home({
    required this.browse,
    required this.balance,
    this.run,
    this.completed,
  });

  final RunState? run;
  final BalanceState? balance;
  final _Completed? completed;
  final List<PackView> browse;
}

class _Completed {
  const _Completed({
    required this.grade,
    required this.campaign,
    required this.missCount,
    required this.missAllowance,
    required this.marksEarned,
  });

  final Grade grade;
  final Campaign campaign;
  final int missCount;
  final int missAllowance;
  final List<Archetype> marksEarned;
}
