import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'archetype_palette.dart';
import 'tokens.dart';

/// The one theme. Dark is the design; there is no light theme in v1
/// (ADR-0026). A fork re-skins the app by editing this directory.
///
/// The ColorScheme and TextTheme below read AppTokens only. No archetype hue
/// reaches the chrome: the palette travels with the theme as a separate
/// extension so the surfaces that name a drive can find it, and nothing else
/// can reach for it by accident.
///
/// The rem to dp conversion, so a reviewer can re-derive it: DESIGN.md
/// section 3 gives 3rem / 1.5rem / 1.125rem / 1rem / 0.875rem at a 16px root,
/// which is 48 / 24 / 18 / 16 / 14 logical pixels. Display tracking of
/// -0.02em at 48px is -0.96.
ThemeData appDarkTheme() {
  const tokens = AppTokens.standard;

  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

  final scheme = ColorScheme.dark(
    surface: tokens.panel,
    onSurface: tokens.ink,
    surfaceContainerLowest: tokens.panel,
    surfaceContainerLow: tokens.surface1,
    surfaceContainer: tokens.surface2,
    surfaceContainerHigh: tokens.surface3,
    outline: tokens.hairline,
    outlineVariant: tokens.hairline,
    primary: tokens.ink,
    onPrimary: tokens.panel,
    secondary: tokens.mutedInk,
    onSecondary: tokens.panel,
  );

  final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.96,
      color: tokens.ink,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: tokens.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: tokens.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: tokens.ink,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: tokens.ink,
      // The record stays aligned as its numbers change (DESIGN.md section 3).
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    ),
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.panel,
    dividerColor: tokens.hairline,
    // interTextTheme is applied again over the remapped styles so the five
    // overrides above inherit Inter rather than the platform fallback.
    textTheme: GoogleFonts.interTextTheme(text),
    extensions: const <ThemeExtension<dynamic>>[
      AppTokens.standard,
      ArchetypePalette.standard,
    ],
  );
}
