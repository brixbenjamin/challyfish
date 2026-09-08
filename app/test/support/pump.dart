import 'package:feral/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Wraps a widget under test with everything a screen assumes above it.
/// Every widget test uses this rather than a bare MaterialApp (ADR-0022).
Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
