// Not a `flutter test` widget test — a `flutter run` entrypoint for looking
// at CampaignDetailScreen in isolation. See pack_list_screen_debug_test.dart
// for the pattern and why this lives under test/.
//
// Run it with:
//   flutter run -d chrome -t test/ui/campaign_detail_screen_debug_test.dart
import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day.dart';
import 'package:feral/src/ui/browse/campaign_detail_screen.dart';
import 'package:feral/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';

const _psycho = Archetype(
  id: 'a-psycho',
  key: 'psycho',
  name: 'Psycho',
  blurb: 'b',
  color: '#000',
  sort: 1,
);
const _killer = Archetype(
  id: 'a-killer',
  key: 'killer',
  name: 'Killer',
  blurb: 'b',
  color: '#000',
  sort: 2,
);
const _trickster = Archetype(
  id: 'a-trickster',
  key: 'trickster',
  name: 'Trickster',
  blurb: 'b',
  color: '#000',
  sort: 3,
);
const _beast = Archetype(
  id: 'a-beast',
  key: 'beast',
  name: 'Beast',
  blurb: 'b',
  color: '#000',
  sort: 4,
);
const _archetypesById = {
  'a-psycho': _psycho,
  'a-killer': _killer,
  'a-trickster': _trickster,
  'a-beast': _beast,
};

const _campaign = Campaign(
  id: 'c-1',
  packId: 'p-1',
  key: 'thirty',
  title: 'Thirty Days of No',
  subtitle: 'Thirty days of saying the thing out loud.',
  introMd:
      'This campaign asks one plain thing every day: do not soften it. The '
      'first week is the hardest — after that, the body stops arguing with '
      'you about it.',
  lengthDays: 10,
);

/// A day's drives are folded from its actions (ADR-0041), so the harness
/// builds days out of actions -- including two that pull on more than one
/// drive, which is the case this screen could not render before.
DaySpec _day(
  int index,
  String title, {
  DayKind kind = DayKind.standard,
  Map<String, double> mandatory = const {},
  Map<String, double> optional = const {},
}) => DaySpec(
  id: 'd-$index',
  campaignId: 'c-1',
  dayIndex: index,
  title: title,
  kind: kind,
  actions: [
    if (mandatory.isNotEmpty)
      ActionSpec(
        id: 'a-$index-m',
        dayId: 'd-$index',
        title: 'The day\'s act',
        archetypeWeights: mandatory,
        effort: 3,
      ),
    if (optional.isNotEmpty)
      ActionSpec(
        id: 'a-$index-o',
        dayId: 'd-$index',
        title: 'If you have the appetite',
        archetypeWeights: optional,
        isOptional: true,
      ),
  ],
);

final _days = [
  _day(1, 'The Opening Move', mandatory: const {'a-killer': 1}),
  _day(
    2,
    'What You Avoid',
    mandatory: const {'a-beast': 1},
    optional: const {'a-psycho': 1},
  ),
  _day(3, 'Sit With It', kind: DayKind.rest, mandatory: const {'a-psycho': 1}),
  _day(4, 'The Long Ask', mandatory: const {'a-trickster': 1}),
  _day(
    5,
    'No Explaining It Away',
    mandatory: const {'a-psycho': 0.6, 'a-killer': 0.4},
  ),
  _day(6, 'The Second Opening', mandatory: const {'a-killer': 1}),
  _day(7, 'Rest', kind: DayKind.rest, mandatory: const {'a-beast': 1}),
  _day(8, 'What the Week Actually Cost', mandatory: const {'a-beast': 1}),
  _day(
    9,
    'One More Than You Wanted',
    mandatory: const {'a-trickster': 1},
    optional: const {'a-killer': 1},
  ),
  _day(10, 'The Last Ask', mandatory: const {'a-psycho': 1}),
];

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CampaignDetailScreen(
        campaign: _campaign,
        targets: const [_psycho, _killer, _trickster, _beast],
        missAllowance: 3,
        days: _days,
        archetypesById: _archetypesById,
        isUnlocked: true,
        hasActiveRun: false,
        onStart: () => debugPrint('start'),
        onUnlock: () => debugPrint('unlock'),
      ),
    ),
  );
}
