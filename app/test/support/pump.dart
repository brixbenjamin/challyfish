import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget under test with everything a screen assumes above it.
/// Every widget test uses this rather than a bare MaterialApp (ADR-0022).
///
/// The real theme, not a Material default: a widget test that renders on
/// different tokens than the app is testing a screen that does not ship.
Widget wrap(Widget child) => MaterialApp(
  theme: appDarkTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

/// Pumps until [done], or gives up.
///
/// Two things make this less obvious than it looks. `pumpAndSettle` cannot be
/// used at all: the loading screen holds a spinner that never stops scheduling
/// frames, so it would wait forever. And pumping alone is not enough either —
/// boot reads the bundled snapshot off disk and opens sqlite, which is real I/O
/// that a widget test's fake clock does not drive. `runAsync` is what lets that
/// work actually happen; the pump that follows it is what lets the widget tree
/// react. Without the pair, boot never finishes and the test reports the app as
/// never syncing, which is a lie about a bug rather than the truth about one.
Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var frame = 0; frame < 100 && !done(); frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
}
