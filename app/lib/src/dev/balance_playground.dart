import 'package:flutter/material.dart';

import '../app/balance_state.dart';
import '../domain/archetype.dart';
import '../engine/balance.dart';
import '../ui/dashboard/archetype_radar.dart';
import 'balance_presets.dart';
import 'balance_scenario.dart';

/// Four stand-in drives, so the playground can draw a radar without naming the
/// real taxonomy (ADR-0021). Colour is ignored — the radar reads its hues from
/// ArchetypePalette by `sort` — so only `sort` and `name` matter here.
const devArchetypes = <Archetype>[
  Archetype(id: 'd-1', key: 'one', name: 'First', blurb: '', color: '', sort: 1),
  Archetype(
    id: 'd-2',
    key: 'two',
    name: 'Second',
    blurb: '',
    color: '',
    sort: 2,
  ),
  Archetype(
    id: 'd-3',
    key: 'three',
    name: 'Third',
    blurb: '',
    color: '',
    sort: 3,
  ),
  Archetype(
    id: 'd-4',
    key: 'four',
    name: 'Fourth',
    blurb: '',
    color: '',
    sort: 4,
  ),
];

/// A debug bench for the archetype balance: tick acts onto days, push the clock
/// forward, and watch what the radar does — without waiting a day for it.
///
/// Everything it shows comes back from [BalanceScenario.resolve], which calls
/// the production [BalanceState.load]. The screen renders numbers; it does not
/// compute them. Dev-only: reachable from lib/dev_main.dart and from nothing
/// the user can launch.
class BalancePlayground extends StatefulWidget {
  const BalancePlayground({super.key});

  @override
  State<BalancePlayground> createState() => _BalancePlaygroundState();
}

class _BalancePlaygroundState extends State<BalancePlayground> {
  BalanceScenario _scenario = BalanceScenario(archetypes: devArchetypes);
  String _selectedArchetypeId = devArchetypes.first.id;
  int _effort = 3;

  void _update(BalanceScenario next) => setState(() => _scenario = next);

  void _applyWeights({double? halfLife, double? perFullDay}) {
    final current = _scenario.weights;
    _update(
      _scenario.withWeights(
        BalanceWeights(
          halfLifeDays: halfLife ?? current.halfLifeDays,
          pointsPerFullDay: perFullDay ?? current.pointsPerFullDay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _scenario.resolve();

    return Scaffold(
      appBar: AppBar(title: const Text('Balance playground')),
      body: SafeArea(
        // The figure and its numbers are pinned; only the controls scroll.
        // A tap at the bottom of the bench changes something at the top, and a
        // debug tool that makes you scroll back to see what you just did is
        // not showing you the thing you came to watch.
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => _PinnedFigure(
                scenario: _scenario,
                state: state,
                // The radar gives up size before the readout does: the numbers
                // are what you are reading, the figure is the shape they make.
                radarSize: (constraints.maxHeight * 0.28).clamp(120.0, 240.0),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _TickControls(
                    archetypes: devArchetypes,
                    selectedArchetypeId: _selectedArchetypeId,
                    effort: _effort,
                    onArchetypeChanged: (id) =>
                        setState(() => _selectedArchetypeId = id),
                    onEffortChanged: (value) => setState(() => _effort = value),
                    onTick: () =>
                        _update(_scenario.tick(_selectedArchetypeId, [_effort])),
                  ),
                  const SizedBox(height: 16),
                  _ClockControls(
                    onAdvance: (days) => _update(_scenario.advance(days)),
                  ),
                  const SizedBox(height: 16),
                  _WeightControls(
                    weights: _scenario.weights,
                    onHalfLife: (value) => _applyWeights(halfLife: value),
                    onPerFullDay: (value) => _applyWeights(perFullDay: value),
                  ),
                  const SizedBox(height: 16),
                  _PresetControls(
                    onPreset: (preset) => _update(
                      preset.build(devArchetypes).withWeights(_scenario.weights),
                    ),
                    onReset: () => _update(_scenario.cleared()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The half of the bench that never moves: the figure and the numbers it is
/// drawn from, side by side when there is width for it.
class _PinnedFigure extends StatelessWidget {
  const _PinnedFigure({
    required this.scenario,
    required this.state,
    required this.radarSize,
  });

  final BalanceScenario scenario;
  final BalanceState state;
  final double radarSize;

  @override
  Widget build(BuildContext context) {
    final radar = ArchetypeRadar(state: state, size: radarSize);
    final readout = _Readout(scenario: scenario, state: state);
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      // Wide enough and they sit beside each other, which buys back the
      // vertical space the pinning costs the controls.
      child: width >= 600
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                radar,
                const SizedBox(width: 24),
                Expanded(child: readout),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: radar),
                const SizedBox(height: 12),
                readout,
              ],
            ),
    );
  }
}

/// The numbers, laid out so a wrong one is obvious: raw balance beside the
/// normalised value the figure actually draws, beside the ceiling it is
/// normalised against.
class _Readout extends StatelessWidget {
  const _Readout({required this.scenario, required this.state});

  final BalanceScenario scenario;
  final BalanceState state;

  @override
  Widget build(BuildContext context) {
    final mono = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontFeatures: const [
      FontFeature.tabularFigures(),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.4),
            2: FlexColumnWidth(1.4),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Text('drive', style: mono),
                Text('balance', style: mono, textAlign: TextAlign.right),
                Text('norm', style: mono, textAlign: TextAlign.right),
                Text('marks', style: mono, textAlign: TextAlign.right),
              ],
            ),
            for (final archetype in state.archetypes)
              TableRow(
                key: ValueKey('row-${archetype.id}'),
                children: [
                  Text(archetype.name, style: mono),
                  Text(
                    state.valueFor(archetype.id).toStringAsFixed(4),
                    key: ValueKey('balance-${archetype.id}'),
                    style: mono,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    state.normalizedFor(archetype.id).toStringAsFixed(4),
                    key: ValueKey('norm-${archetype.id}'),
                    style: mono,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    '${state.marksFor(archetype.id)}',
                    style: mono,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        _Stat(
          label: 'full axis (maxValue)',
          value: state.maxValue.toStringAsFixed(4),
        ),
        _Stat(label: 'all-time points', value: '${state.allTimePoints}'),
        _Stat(
          label: 'today is day',
          value: '${scenario.todayIndex}  (+${scenario.clockOffsetDays}d)',
        ),
        _Stat(
          label: 'logged',
          value: '${scenario.days.length} days, ${scenario.tickCount} ticks',
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, key: ValueKey('stat-$label'), style: style),
        ],
      ),
    );
  }
}

class _TickControls extends StatelessWidget {
  const _TickControls({
    required this.archetypes,
    required this.selectedArchetypeId,
    required this.effort,
    required this.onArchetypeChanged,
    required this.onEffortChanged,
    required this.onTick,
  });

  final List<Archetype> archetypes;
  final String selectedArchetypeId;
  final int effort;
  final ValueChanged<String> onArchetypeChanged;
  final ValueChanged<int> onEffortChanged;
  final VoidCallback onTick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Tick an act onto today'),
        Wrap(
          spacing: 8,
          children: [
            for (final archetype in archetypes)
              ChoiceChip(
                key: ValueKey('pick-${archetype.id}'),
                label: Text(archetype.name),
                selected: archetype.id == selectedArchetypeId,
                onSelected: (_) => onArchetypeChanged(archetype.id),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('effort $effort'),
            const Spacer(),
            IconButton(
              key: const ValueKey('effort-down'),
              onPressed: effort > 1 ? () => onEffortChanged(effort - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            IconButton(
              key: const ValueKey('effort-up'),
              onPressed: effort < 20 ? () => onEffortChanged(effort + 1) : null,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const ValueKey('tick'),
              onPressed: onTick,
              child: const Text('Tick'),
            ),
          ],
        ),
        const Text(
          'Ticking twice without advancing the clock stacks both acts onto the '
          'same day — which is how you make the day cap bite.',
        ),
      ],
    );
  }
}

class _ClockControls extends StatelessWidget {
  const _ClockControls({required this.onAdvance});

  final ValueChanged<int> onAdvance;

  static const _jumps = <int>[1, 7, 30, 60];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Advance the clock (logs untouched — pure decay)'),
        Wrap(
          spacing: 8,
          children: [
            for (final days in _jumps)
              OutlinedButton(
                key: ValueKey('advance-$days'),
                onPressed: () => onAdvance(days),
                child: Text('+${days}d'),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeightControls extends StatelessWidget {
  const _WeightControls({
    required this.weights,
    required this.onHalfLife,
    required this.onPerFullDay,
  });

  final BalanceWeights weights;
  final ValueChanged<double> onHalfLife;
  final ValueChanged<double> onPerFullDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Weights'),
        Text('halfLifeDays  ${weights.halfLifeDays.round()}'),
        Slider(
          key: const ValueKey('half-life'),
          min: 1,
          max: 365,
          value: weights.halfLifeDays.clamp(1, 365),
          onChanged: (value) => onHalfLife(value.roundToDouble()),
        ),
        Text('pointsPerFullDay (also the day cap)  '
            '${weights.pointsPerFullDay.round()}'),
        Slider(
          key: const ValueKey('per-full-day'),
          min: 1,
          max: 20,
          value: weights.pointsPerFullDay.clamp(1, 20),
          onChanged: (value) => onPerFullDay(value.roundToDouble()),
        ),
        const Text(
          'The ceiling is derived from the half-life, not set: move the top '
          'slider and watch full axis move with it.',
        ),
      ],
    );
  }
}

class _PresetControls extends StatelessWidget {
  const _PresetControls({required this.onPreset, required this.onReset});

  final ValueChanged<BalancePreset> onPreset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Presets'),
        for (final preset in BalancePreset.all)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  key: ValueKey('preset-${preset.label}'),
                  onPressed: () => onPreset(preset),
                  child: Text(preset.label),
                ),
                Text(
                  preset.blurb,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        TextButton(
          key: const ValueKey('reset'),
          onPressed: onReset,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
