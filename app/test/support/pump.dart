import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';

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
