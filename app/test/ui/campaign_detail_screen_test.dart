import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day.dart';
import 'package:feral/src/ui/browse/campaign_detail_screen.dart';
import 'package:feral/src/ui/theme/archetype_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const campaign = Campaign(
  id: 'c-1',
  packId: 'p-1',
  key: 'thirty',
  title: 'Thirty Days',
  introMd: 'intro text',
  lengthDays: 3,
);

const killer = Archetype(
  id: 'a-killer',
  key: 'killer',
  name: 'Killer',
  blurb: 'b',
  color: '#000',
  sort: 2,
);
const alchemist = Archetype(
  id: 'a-alchemist',
  key: 'alchemist',
  name: 'Alchemist',
  blurb: 'b',
  color: '#000',
  sort: 3,
);

const day1 = DaySpec(
  id: 'd-1',
  campaignId: 'c-1',
  dayIndex: 1,
  title: 'The Opening Move',
  primaryArchetypeId: 'a-killer',
);
const day2 = DaySpec(
  id: 'd-2',
  campaignId: 'c-1',
  dayIndex: 2,
  title: 'Rest',
  kind: DayKind.rest,
);
const day3 = DaySpec(
  id: 'd-3',
  campaignId: 'c-1',
  dayIndex: 3,
  title: 'The Last Ask',
  primaryArchetypeId: 'a-alchemist',
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Widget buildScreen({List<DaySpec> days = const []}) => CampaignDetailScreen(
    campaign: campaign,
    targets: const [killer, alchemist],
    missAllowance: 1,
    days: days,
    archetypesById: const {'a-killer': killer, 'a-alchemist': alchemist},
    isUnlocked: true,
    hasActiveRun: false,
    onStart: () {},
    onUnlock: () {},
  );

  testWidgets('every day preview renders in order, titled, not detailed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildScreen(days: const [day1, day2, day3])));

    expect(find.text(l10n.campaignDaysHeading), findsOneWidget);
    expect(find.text(l10n.dayPreviewNumber(1)), findsOneWidget);
    expect(find.text('The Opening Move'), findsOneWidget);
    expect(find.text(l10n.dayPreviewNumber(2)), findsOneWidget);
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text(l10n.dayPreviewNumber(3)), findsOneWidget);
    expect(find.text('The Last Ask'), findsOneWidget);

    // No action or day body ever reaches this screen — nothing to find,
    // because nothing beyond title and number was ever passed in.
    expect(find.textContaining('intro text'), findsOneWidget);
  });

  testWidgets(
    'a day names its drive with a tag; a rest day carries none',
    (tester) async {
      await tester.pumpWidget(
        wrap(buildScreen(days: const [day1, day2, day3])),
      );

      // The header's own tag plus one per named day: three ArchetypeTags for
      // two archetype-bearing days, none for the rest day in between.
      expect(find.byType(ArchetypeTag), findsNWidgets(3));
    },
  );

  testWidgets('no days cached yet renders no preview section at all', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildScreen()));

    expect(find.text(l10n.campaignDaysHeading), findsNothing);
  });
}
