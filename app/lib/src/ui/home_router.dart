import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/run_state.dart';
import '../domain/outcome.dart';
import 'campaign_list_screen.dart';
import 'dashboard_screen.dart';

/// Loads content, applies rollover, and shows either the campaign list or the
/// dashboard. Plan 2 replaces this with the designed navigation; it exists here
/// only so the loop can be exercised on a device.
class HomeRouter extends ConsumerStatefulWidget {
  const HomeRouter({super.key});

  @override
  ConsumerState<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends ConsumerState<HomeRouter> {
  Future<RunState?>? _pending;

  @override
  void initState() {
    super.initState();
    _pending = _load();
  }

  Future<RunState?> _load() async {
    final content = ref.read(contentRepositoryProvider);
    final progress = ref.read(progressRepositoryProvider);
    final userId = ref.read(userIdProvider);

    // A failed pull is not fatal: whatever is already cached still works.
    try {
      await content.pull();
    } catch (_) {}

    final run = await progress.activeRun(userId);
    if (run == null) return null;

    final campaigns = await content.campaigns();
    final campaign = campaigns.firstWhere((c) => c.id == run.campaignId);
    final actions = await content.actionsFor(campaign.id);

    await progress.applyRollover(
      run: run,
      lengthDays: campaign.lengthDays,
      actionIdForDay: (day) => actions
          .firstWhere((a) => a.dayIndex == day, orElse: () => actions.first)
          .id,
    );

    final logs = await progress.logsFor(run.id);
    final state = RunState.derive(
      run: run,
      campaign: campaign,
      logs: logs,
      zone: ref.read(zoneProvider),
      now: ref.read(clockProvider).nowUtc(),
    );

    final todayAction = await content.actionFor(campaign.id, state.currentDay);
    return RunState.derive(
      run: run,
      campaign: campaign,
      logs: logs,
      todayAction: todayAction,
      zone: ref.read(zoneProvider),
      now: ref.read(clockProvider).nowUtc(),
    );
  }

  void _reload() => setState(() => _pending = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RunState?>(
      future: _pending,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = snapshot.data;
        if (state == null) return _campaignList();

        return DashboardScreen(
          state: state,
          onCommit: () async {
            final action = state.todayAction;
            if (action == null) return;
            await ref
                .read(progressRepositoryProvider)
                .commitToday(
                  run: state.run,
                  dayIndex: state.currentDay,
                  actionId: action.id,
                );
            _reload();
          },
          onReport: (Outcome outcome, String? note) async {
            final action = state.todayAction;
            if (action == null) return;
            await ref
                .read(progressRepositoryProvider)
                .report(
                  run: state.run,
                  dayIndex: state.currentDay,
                  actionId: action.id,
                  outcome: outcome,
                  note: note,
                );
            _reload();
          },
        );
      },
    );
  }

  Widget _campaignList() {
    return FutureBuilder(
      future: ref.read(contentRepositoryProvider).campaigns(),
      builder: (context, snapshot) {
        final campaigns = snapshot.data;
        if (campaigns == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return CampaignListScreen(
          campaigns: campaigns,
          onStart: (campaign) async {
            await ref
                .read(progressRepositoryProvider)
                .startRun(
                  userId: ref.read(userIdProvider),
                  campaignId: campaign.id,
                );
            _reload();
          },
        );
      },
    );
  }
}
