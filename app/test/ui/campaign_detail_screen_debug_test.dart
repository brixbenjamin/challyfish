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

const _days = [
  DaySpec(
    id: 'd-1',
    campaignId: 'c-1',
    dayIndex: 1,
    title: 'The Opening Move',
    primaryArchetypeId: 'a-killer',
  ),
  DaySpec(
    id: 'd-2',
    campaignId: 'c-1',
    dayIndex: 2,
    title: 'What You Avoid',
    primaryArchetypeId: 'a-beast',
  ),
  DaySpec(
    id: 'd-3',
    campaignId: 'c-1',
    dayIndex: 3,
    title: 'Sit With It',
    kind: DayKind.rest,
  ),
  DaySpec(
    id: 'd-4',
    campaignId: 'c-1',
    dayIndex: 4,
    title: 'The Long Ask',
    primaryArchetypeId: 'a-trickster',
  ),
  DaySpec(
    id: 'd-5',
    campaignId: 'c-1',
    dayIndex: 5,
    title: 'No Explaining It Away',
    primaryArchetypeId: 'a-psycho',
  ),
  DaySpec(
    id: 'd-6',
    campaignId: 'c-1',
    dayIndex: 6,
    title: 'The Second Opening',
    primaryArchetypeId: 'a-killer',
  ),
  DaySpec(
    id: 'd-7',
    campaignId: 'c-1',
    dayIndex: 7,
    title: 'Rest',
    kind: DayKind.rest,
  ),
  DaySpec(
    id: 'd-8',
    campaignId: 'c-1',
    dayIndex: 8,
    title: 'What the Week Actually Cost',
    primaryArchetypeId: 'a-beast',
  ),
  DaySpec(
    id: 'd-9',
    campaignId: 'c-1',
    dayIndex: 9,
    title: 'One More Than You Wanted',
    primaryArchetypeId: 'a-trickster',
  ),
  DaySpec(
    id: 'd-10',
    campaignId: 'c-1',
    dayIndex: 10,
    title: 'The Last Ask',
    primaryArchetypeId: 'a-psycho',
  ),
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
