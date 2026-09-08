import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/doctrine.dart';
import 'package:feral/src/ui/doctrine/doctrine_entry_screen.dart';
import 'package:feral/src/ui/doctrine/doctrine_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const groups = [
  DoctrineGroup(id: 'g-1', title: 'The Zoo', sort: 1),
  DoctrineGroup(id: 'g-2', title: 'Thumos', sort: 2),
];

const entries = {
  'g-1': [
    DoctrineEntry(
      id: 'e-1',
      groupId: 'g-1',
      title: 'The Domesticated State',
      bodyMd: 'body one',
      sort: 1,
    ),
    DoctrineEntry(
      id: 'e-2',
      groupId: 'g-1',
      title: 'Thought Corruption',
      bodyMd: 'body two',
      sort: 2,
    ),
  ],
  'g-2': [
    DoctrineEntry(
      id: 'e-3',
      groupId: 'g-2',
      title: 'Thumos',
      bodyMd: 'body three',
      sort: 1,
    ),
  ],
};

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('lists every group with its entries', (tester) async {
    await tester.pumpWidget(
      wrap(
        DoctrineListScreen(
          groups: groups,
          entriesByGroup: entries,
          onOpen: (_) {},
        ),
      ),
    );

    expect(find.text('The Zoo'), findsOneWidget);
    expect(find.text('Thumos'), findsNWidgets(2)); // the group and the entry
    expect(find.text('The Domesticated State'), findsOneWidget);
  });

  testWidgets('tapping an entry opens it', (tester) async {
    DoctrineEntry? opened;
    await tester.pumpWidget(
      wrap(
        DoctrineListScreen(
          groups: groups,
          entriesByGroup: entries,
          onOpen: (e) => opened = e,
        ),
      ),
    );

    await tester.tap(find.text('Thought Corruption'));
    expect(opened?.id, 'e-2');
  });

  testWidgets('has no search, bookmarks, or reading progress', (tester) async {
    // Every one of those serves the Collector anti-persona and competes with
    // the daily action. See docs/product/personas.md.
    await tester.pumpWidget(
      wrap(
        DoctrineListScreen(
          groups: groups,
          entriesByGroup: entries,
          onOpen: (_) {},
        ),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.bookmark), findsNothing);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);
    expect(find.textContaining('Continue reading'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('an entry renders its title and body', (tester) async {
    await tester.pumpWidget(
      wrap(
        const DoctrineEntryScreen(
          entry: DoctrineEntry(
            id: 'e-1',
            groupId: 'g-1',
            title: 'The Domesticated State',
            bodyMd: 'body one',
            sort: 1,
          ),
        ),
      ),
    );

    expect(find.text('The Domesticated State'), findsWidgets);
    expect(find.text('body one'), findsOneWidget);
  });

  testWidgets('an empty doctrine section says so rather than showing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DoctrineListScreen(
          groups: const [],
          entriesByGroup: const {},
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.text(l10n.doctrineEmpty), findsOneWidget);
  });
}
