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
const trickster = Archetype(
  id: 'a-trickster',
  key: 'trickster',
  name: 'Trickster',
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
  primaryArchetypeId: 'a-trickster',
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Widget buildScreen({List<DaySpec> days = const []}) => CampaignDetailScreen(
    campaign: campaign,
    targets: const [killer, trickster],
    missAllowance: 1,
    days: days,
    archetypesById: const {'a-killer': killer, 'a-trickster': trickster},
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

  group('a long campaign fogs its tail (ADR-0037)', () {
    const longCampaign = Campaign(
      id: 'c-2',
      packId: 'p-1',
      key: 'long',
      title: 'Long Haul',
      introMd: 'intro text',
      lengthDays: 12,
    );

    List<DaySpec> longDays({String? day6ArchetypeId, String? day10ArchetypeId}) => [
      for (var i = 1; i <= 12; i++)
        DaySpec(
          id: 'd-$i',
          campaignId: 'c-2',
          dayIndex: i,
          title: 'Day title $i',
          primaryArchetypeId: switch (i) {
            6 => day6ArchetypeId,
            10 => day10ArchetypeId,
            _ => null,
          },
        ),
    ];

    Widget buildLongScreen(List<DaySpec> days, Map<String, Archetype> archetypesById) =>
        CampaignDetailScreen(
          campaign: longCampaign,
          targets: const [],
          missAllowance: 1,
          days: days,
          archetypesById: archetypesById,
          isUnlocked: true,
          hasActiveRun: false,
          onStart: () {},
          onUnlock: () {},
        );

    testWidgets(
      'only the first 5 days render up front; the rest collapse behind a count',
      (tester) async {
        await tester.pumpWidget(wrap(buildLongScreen(longDays(), const {})));

        for (var i = 1; i <= 5; i++) {
          expect(find.text(l10n.dayPreviewNumber(i)), findsOneWidget);
        }
        for (var i = 6; i <= 12; i++) {
          expect(find.text(l10n.dayPreviewNumber(i)), findsNothing);
        }
        expect(find.text(l10n.campaignDaysRemainingCta(7)), findsOneWidget);
      },
    );

    testWidgets(
      'expanding reveals the tail: non-landmark days blur and drop their tag, '
      'every-5th-day landmarks stay sharp',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            buildLongScreen(
              longDays(day6ArchetypeId: 'a-killer', day10ArchetypeId: 'a-trickster'),
              const {'a-killer': killer, 'a-trickster': trickster},
            ),
          ),
        );

        await tester.tap(find.text(l10n.campaignDaysRemainingCta(7)));
        await tester.pump();

        // Day 6: fogged. Number stays plain; title is present in the tree
        // but blurred, and its drive tag is withheld despite having one.
        expect(find.text(l10n.dayPreviewNumber(6)), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text('Day title 6'),
            matching: find.byType(ImageFiltered),
          ),
          findsOneWidget,
        );

        // Day 10: an every-5th-day landmark past the window, so it stays
        // sharp — title unblurred, drive tag shown.
        expect(
          find.ancestor(
            of: find.text('Day title 10'),
            matching: find.byType(ImageFiltered),
          ),
          findsNothing,
        );

        // targets is empty, so the only ArchetypeTag possible is day 10's —
        // day 6's archetype never reaches one while fogged.
        expect(find.byType(ArchetypeTag), findsOneWidget);
      },
    );

    testWidgets(
      "a fogged day's semantics name it without leaking its title",
      (tester) async {
        await tester.pumpWidget(wrap(buildLongScreen(longDays(), const {})));

        await tester.tap(find.text(l10n.campaignDaysRemainingCta(7)));
        await tester.pump();

        expect(
          find.bySemanticsLabel(l10n.dayNotYetRevealedLabel(6)),
          findsOneWidget,
        );
      },
    );
  });
}
