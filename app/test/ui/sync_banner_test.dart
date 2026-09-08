import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/ui/sync/sync_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    SyncStatus status, {
    List<SyncNotice> notices = const [],
  }) {
    return tester.pumpWidget(
      wrap(
        Scaffold(
          body: Column(
            children: [
              SyncBanner(
                status: status,
                notices: notices,
                onDismissNotice: (_) {},
              ),
              const Text('todays action'),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('idle shows nothing', (tester) async {
    await pump(tester, SyncStatus.idle);
    expect(find.byKey(SyncBanner.messageKey), findsNothing);
  });

  testWidgets('syncing shows nothing — it is not news either', (tester) async {
    await pump(tester, SyncStatus.syncing);
    expect(find.byKey(SyncBanner.messageKey), findsNothing);
  });

  testWidgets('retrying shows nothing — a blip is not news', (tester) async {
    await pump(tester, SyncStatus.retrying);
    expect(find.byKey(SyncBanner.messageKey), findsNothing);
  });

  testWidgets('offline shows a quiet indicator, not a warning', (tester) async {
    await pump(tester, SyncStatus.offline);

    final text = tester.widget<Text>(find.byKey(SyncBanner.messageKey));
    expect(text.data, contains('Offline'));
    expect(text.data, isNot(contains('!')));
    expect(find.byIcon(Icons.error), findsNothing);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('failing states the situation without alarming', (tester) async {
    await pump(tester, SyncStatus.failing);

    final text = tester.widget<Text>(find.byKey(SyncBanner.messageKey));
    expect(text.data, contains('saved on this phone'));
    expect(text.data!.toLowerCase(), isNot(contains('lost')));
    expect(text.data!.toLowerCase(), isNot(contains('failed')));
  });

  testWidgets('it is never a dialog and never blocks the screen', (tester) async {
    await pump(tester, SyncStatus.failing);

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    // Every MaterialApp route inserts a transparent ModalBarrier of its own,
    // so its absence cannot be the assertion. What must be absent is a scrim:
    // a barrier painted over the screen is what makes something modal.
    for (final barrier in tester.widgetList<ModalBarrier>(
      find.byType(ModalBarrier),
    )) {
      expect(barrier.color, isNull);
    }
    // The content below the banner is still on screen and still laid out.
    expect(find.text('todays action'), findsOneWidget);
    expect(tester.getSize(find.text('todays action')).height, greaterThan(0));
  });

  testWidgets('a reconciliation notice is shown and can be dismissed', (tester) async {
    final dismissed = <SyncNoticeKind>[];
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: SyncBanner(
            status: SyncStatus.idle,
            notices: [
              SyncNotice(
                kind: SyncNoticeKind.runReconciled,
                message: 'A campaign was already running on another device.',
                occurredAt: DateTime.utc(2026, 6, 10),
              ),
            ],
            onDismissNotice: dismissed.add,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('already running on another device'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(SyncBanner.dismissKey));
    await tester.pump();

    expect(dismissed, [SyncNoticeKind.runReconciled]);
  });

  testWidgets('no copy anywhere implies the user did something wrong', (tester) async {
    for (final status in SyncStatus.values) {
      await pump(tester, status);
      final finder = find.byKey(SyncBanner.messageKey);
      if (finder.evaluate().isEmpty) continue;
      final text = tester.widget<Text>(finder).data!.toLowerCase();
      for (final banned in ['error', 'invalid', 'you must', 'try again later']) {
        expect(text, isNot(contains(banned)), reason: 'status $status');
      }
    }
  });
}
