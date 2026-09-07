import 'package:flutter/material.dart';

/// The brand tokens. A leaf: imports nothing from lib/src/.
///
/// The words are not here. They are in lib/l10n/app_en.arb (ADR-0022). What is
/// here is what a fork changes that a string bundle cannot express.
///
/// What is NOT here either, because it lives outside Dart: the bundle id (set by
/// `flutter create --org`), the iOS Info.plist display name, and the Android
/// manifest label. niche/README.md lists them.
abstract final class Brand {
  static const appName = 'Feral';
  static const colorSeed = Color(0xFF1A1A1A);

  static ThemeData theme() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorSeed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
