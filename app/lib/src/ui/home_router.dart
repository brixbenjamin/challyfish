import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/balance_state.dart';
import '../app/link_flow.dart';
import '../app/providers.dart';
import '../app/purchase_state.dart';
import '../app/run_state.dart';
import '../app/sync_state.dart';
import '../core/l10n_ext.dart';
import '../data/repositories/diagnostic_repository.dart';
import '../domain/archetype.dart';
import '../domain/campaign.dart';
import '../domain/pack.dart';
import '../domain/diagnostic.dart';
import '../domain/doctrine.dart';
import '../domain/grade.dart';
import '../domain/identity.dart';
import '../domain/outcome.dart';
import '../domain/sync_status.dart';
import 'browse/campaign_detail_screen.dart';
import 'browse/pack_list_screen.dart';
import 'purchase/unlock_sheet.dart';
import 'completion/completion_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'doctrine/doctrine_entry_screen.dart';
import 'doctrine/doctrine_list_screen.dart';
import 'identity/email_code_screen.dart';
import 'identity/link_sheet.dart';
import 'identity/replace_confirm_screen.dart';
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
    debugPrint('[BOOTPROBE] boot: start');
    await _bootstrapContent();
    debugPrint('[BOOTPROBE] boot: content bootstrapped');

    final diagnostic = ref.read(diagnosticRepositoryProvider);
    final userId = ref.read(userIdProvider);
    debugPrint('[BOOTPROBE] boot: userId resolved');

    await _configurePurchases(userId);
    debugPrint('[BOOTPROBE] boot: purchases configured');
    // Deliberately not awaited: a slow store must not delay the first frame.
    unawaited(_restoreOnLaunch(userId));
    debugPrint('[BOOTPROBE] boot: restore dispatched');

    if (await diagnostic.hasCompleted(userId)) {
      debugPrint('[BOOTPROBE] boot: diagnostic complete -> loadHome');
      await _loadHome();
      debugPrint('[BOOTPROBE] boot: loadHome returned');
      return;
    }
    debugPrint('[BOOTPROBE] boot: diagnostic not complete');

    final questions = await diagnostic.questions();
    debugPrint('[BOOTPROBE] boot: questions loaded (\${questions.length})');
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _step = _Step.intro;
    });
  }

  /// Hands the store the Supabase user id as its app user id (ADR-0017), which
  /// is what makes a pack bought anonymously survive identity linking.
  ///
  /// A store that cannot be configured must never block the app. Everything
  /// already owned still works from the pulled rows, and the daily loop does
  /// not involve the store at all.
  Future<void> _configurePurchases(String userId) async {
    try {
      debugPrint('[BOOTPROBE] configure: calling gateway');
      await ref.read(purchaseGatewayProvider).configure(userId);
      debugPrint('[BOOTPROBE] configure: returned');
    } catch (e) {
      debugPrint('[BOOTPROBE] configure: threw \$e');
    }
  }

  /// Once per launch, so a reinstall recovers without anyone having to find a
  /// settings row (US26).
  ///
  /// Fire and forget: it never blocks the router and a failure is invisible —
  /// the settings row is the visible path, and it reports honestly.
  Future<void> _restoreOnLaunch(String userId) async {
    try {
      final packs = await ref.read(contentRepositoryProvider).packs();
      await ref
          .read(entitlementRepositoryProvider)
          .restore(userId: userId, packs: packs);
      ref.invalidate(unlockedPackIdsProvider);
    } catch (_) {}
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

    // The second gate, and the one that counts. The UI hides the button, but
    // row-level security cannot cover this: teasers are public by design
    // (ADR-0008), so from the server's side reading a locked campaign and
    // starting it look the same. Computed here rather than passed in, so no
    // call site can decide the answer for itself.
    final unlocked = await _isCampaignUnlocked(campaignId);

    // Exactly one run may be active. Replacing one is the only destructive
    // action in the product, and the detail screen has already said so. It
    // happens only after the lock check, so a refused start never abandons the
    // run the user is in the middle of.
    final active = await progress.activeRun(userId);
    if (active != null) await progress.abandonRun(active.id);

    await progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: unlocked,
    );
    ref.invalidate(unlockedPackIdsProvider);
    await _loadHome();
  }

  /// Whether the pack holding [campaignId] is owned. Fails closed: a campaign
  /// or pack this device cannot resolve is not a reason to hand out content.
  Future<bool> _isCampaignUnlocked(String campaignId) async {
    final content = ref.read(contentRepositoryProvider);
    final campaign = await content.campaignById(campaignId);
    if (campaign == null) return false;

    final packs = await content.packs();
    final pack = packs.where((p) => p.id == campaign.packId).firstOrNull;
    if (pack == null) return false;

    return ref
        .read(entitlementRepositoryProvider)
        .isUnlocked(userId: ref.read(userIdProvider), pack: pack);
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
    debugPrint('[BOOTPROBE] browse: start');
    final content = ref.read(contentRepositoryProvider);
    final packs = await content.packs();
    debugPrint('[BOOTPROBE] browse: packs loaded');

    final campaignsByPack = <String, List<Campaign>>{};
    for (final pack in packs) {
      campaignsByPack[pack.id] = await content.campaignsFor(pack.id);
    }

    // Locked packs still list their campaigns — the teaser is the shop window
    // (ADR-0008). What changed in plan 4 is that `isUnlocked` is now an answer
    // from the entitlement repository rather than an assumption about is_core.
    final unlocked = await ref
        .read(entitlementRepositoryProvider)
        .unlockedPackIds(userId: ref.read(userIdProvider), packs: packs);
    debugPrint('[BOOTPROBE] browse: entitlements resolved');

    return packViewsFrom(
      packs: packs,
      campaignsByPack: campaignsByPack,
      unlockedPackIds: unlocked,
    );
  }

  Future<_Home> _buildHome() async {
    debugPrint('[BOOTPROBE] buildHome: start');
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
    debugPrint('[BOOTPROBE] loadHome: start');
    final home = await _buildHome();
    debugPrint('[BOOTPROBE] loadHome: built');
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
            // A different anonymous user than the one that launched the app.
            ref.invalidate(userIdProvider);
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

  // ---------------------------------------------------------------- identity

  /// The linking flow, from the sheet down to whichever screens the chosen
  /// provider needs. Returns true when the identity question was answered.
  ///
  /// The sequence lives in [LinkFlow]; this only knows how to ask on screen.
  Future<bool> _openLinkFlow() async {
    final l10n = context.l10n;
    final flow = LinkFlow(
      identity: ref.read(identityRepositoryProvider),
      confirmReplacement: _confirmReplacement,
    );

    final chosen = await showModalBottomSheet<AuthProvider>(
      context: context,
      builder: (sheetContext) => LinkSheet(
        providers: const [
          AuthProvider.apple,
          AuthProvider.google,
          AuthProvider.email,
        ],
        onChoose: (provider) => Navigator.of(sheetContext).pop(provider),
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
    if (chosen == null || !mounted) return false;

    return switch (chosen) {
      AuthProvider.email => _linkWithEmail(flow),
      AuthProvider.apple => _linkWithProvider(
        flow,
        chosen,
        l10n.appleAccountName,
      ),
      AuthProvider.google => _linkWithProvider(
        flow,
        chosen,
        l10n.googleAccountName,
      ),
    };
  }

  /// Apple and Google: the credential is collected by the platform first, and
  /// a user who backs out of that sheet has answered nothing.
  Future<bool> _linkWithProvider(
    LinkFlow flow,
    AuthProvider provider,
    String accountLabel,
  ) async {
    final AppleGoogleToken? credential;
    try {
      credential = provider == AuthProvider.apple
          ? await AppleCredentials.request()
          : await GoogleCredentials.request();
    } catch (error) {
      // A provider that is not configured on this build fails here, and it must
      // fail as plainly as a wrong code does.
      return _settle(Failed(error));
    }

    return _settle(
      await flow.attach(
        provider: provider,
        credential: credential,
        accountLabel: accountLabel,
      ),
    );
  }

  /// Email: two steps on one screen, and no deep link anywhere (ADR-0016).
  Future<bool> _linkWithEmail(LinkFlow flow) async {
    final l10n = context.l10n;
    AttachOutcome? answered;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => EmailCodeScreen(
          onSendCode: (email) async {
            final outcome = await flow.sendEmailCode(email);
            switch (outcome) {
              case Cancelled():
                // They declined the replacement. Leaving is the answer, so the
                // screen closes rather than showing them an error they caused
                // on purpose.
                if (routeContext.mounted) Navigator.of(routeContext).pop();
              case Failed(:final error):
                throw error;
              default:
                break;
            }
          },
          onVerify: (email, code) async {
            final outcome = await flow.verifyEmailCode(
              email: email,
              code: code,
            );
            switch (outcome) {
              case Linked():
                answered = outcome;
                return CodeAccepted(ref.read(userIdProvider));
              case SignedIn(:final userId):
                answered = outcome;
                return CodeAccepted(userId);
              default:
                // Wrong, expired, already used, or no signal: one sentence for
                // all of them, because the server does not say which.
                return CodeRejected(l10n.codeRejected);
            }
          },
          onAuthenticated: (_) => Navigator.of(routeContext).pop(),
          onCancel: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );

    final outcome = answered;
    return outcome == null ? false : _settle(outcome);
  }

  /// The one screen standing between a user and losing a record.
  Future<bool> _confirmReplacement(
    LocalProgressSummary summary,
    String accountLabel,
  ) async {
    if (!mounted) return false;
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) => ReplaceConfirmScreen(
          summary: summary,
          accountLabel: accountLabel,
          onConfirm: () => Navigator.of(routeContext).pop(true),
          onCancel: () => Navigator.of(routeContext).pop(false),
        ),
      ),
    );
    return confirmed ?? false;
  }

  /// Where the app lands once the identity question has an answer.
  Future<bool> _settle(AttachOutcome outcome) async {
    switch (outcome) {
      case Linked():
        // The record never moved; it just has an owner now. Reloading is what
        // retires the completion prompt, which stops applying the moment the
        // account is linked (ADR-0013).
        if (mounted) await _reloadHome();
        return true;
      case SignedIn():
        // The local rows are gone and this account's record has to be pulled.
        // Invalidating the id is what repoints every repository at the account
        // that just signed in.
        ref.invalidate(userIdProvider);
        if (!mounted) return true;
        Navigator.of(context).popUntil((route) => route.isFirst);
        await _boot();
        return true;
      case Failed():
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.linkFailed)));
        }
        return false;
      case Cancelled():
      case NeedsReplaceConfirmation():
      case CodeSent():
        return false;
    }
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
        // Rebuilt after the link flow so the account row shows what just
        // happened rather than what was true when settings opened.
        builder: (_) => StatefulBuilder(
          builder: (settingsContext, refreshSettings) => SettingsScreen(
            scheduler: ref.read(reminderSchedulerProvider),
            linkedIdentity: ref.read(identityRepositoryProvider).linkedIdentity,
            onLink: () async {
              await _openLinkFlow();
              // A sign-in pops this route on its way to a fresh boot, so there
              // may be nothing left to refresh.
              if (settingsContext.mounted) refreshSettings(() {});
            },
            onDeleteAccount: _openDeleteAccount,
            onRestorePurchases: () async {
              final userId = ref.read(userIdProvider);
              final packs = await ref.read(contentRepositoryProvider).packs();
              final summary = await ref
                  .read(purchaseControllerProvider)
                  .restore(userId: userId, packs: packs);
              ref.invalidate(unlockedPackIdsProvider);
              return summary;
            },
          ),
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
          onUnlock: () => _openUnlockSheetFor(campaign),
        ),
      ),
    );
  }

  /// Opens the unlock sheet for the pack holding [campaign].
  ///
  /// Reached only by tapping Unlock. Nothing in this product opens a paywall on
  /// its own (design principle 5).
  Future<void> _openUnlockSheetFor(Campaign campaign) async {
    final content = ref.read(contentRepositoryProvider);
    final packs = await content.packs();
    final pack = packs.where((p) => p.id == campaign.packId).firstOrNull;
    if (pack == null || !mounted) return;

    await _openUnlockSheet(context, pack);
  }

  Future<void> _openUnlockSheet(BuildContext context, Pack pack) async {
    final campaigns = await ref
        .read(contentRepositoryProvider)
        .campaignsFor(pack.id);
    final productId = pack.storeProductId;

    // A store that cannot be reached costs the price label, not the sheet.
    String? price;
    if (productId != null && productId.isNotEmpty) {
      try {
        final products = await ref.read(purchaseGatewayProvider).products([
          productId,
        ]);
        price = products.isEmpty ? null : products.first.priceString;
      } catch (_) {
        price = null;
      }
    }

    if (!context.mounted) return;

    // Declared as PurchaseUiState, not var: inferred as PurchaseIdle it could
    // not later hold a PurchaseProblem, and the failure would be a type error
    // at the least convenient moment — after a purchase.
    PurchaseUiState state = const PurchaseIdle();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => UnlockSheet(
          pack: pack,
          campaigns: campaigns,
          priceLabel: price,
          state: state,
          onBuy: () async {
            setSheetState(() => state = const PurchaseInProgress());
            final userId = ref.read(userIdProvider);
            final result = await ref
                .read(purchaseControllerProvider)
                .buy(userId: userId, pack: pack);
            ref.invalidate(unlockedPackIdsProvider);
            if (result is PurchaseComplete && sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              await _loadHome();
              return;
            }
            if (sheetContext.mounted) {
              setSheetState(() => state = result);
            }
          },
          onRestore: () async {
            setSheetState(() => state = const PurchaseInProgress());
            final userId = ref.read(userIdProvider);
            final allPacks = await ref.read(contentRepositoryProvider).packs();
            final summary = await ref
                .read(purchaseControllerProvider)
                .restore(userId: userId, packs: allPacks);
            ref.invalidate(unlockedPackIdsProvider);
            if (!sheetContext.mounted) return;
            if (summary.succeeded && summary.unlockedPacks > 0) {
              Navigator.of(sheetContext).pop();
              await _loadHome();
              return;
            }
            setSheetState(
              () => state = summary.succeeded
                  ? const PurchaseProblem(
                      PurchaseProblemReason.nothingToRestore,
                    )
                  : const PurchaseProblem(
                      PurchaseProblemReason.storeUnreachable,
                    ),
            );
          },
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    debugPrint('[BOOTPROBE] build(): step=\$_step');
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
      debugPrint('[BOOTPROBE] result(): fallback spinner, calling loadHome');
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
        onLink: _openLinkFlow,
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
