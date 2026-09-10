import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Exact ease-out-quart: 1 - (1 - t)^4.
///
/// Curves.easeOutQuart is a cubic approximation of this shape. The radar morph
/// is the one load-bearing animation in the product, and the HTML mockup that
/// validated it uses the true quartic, so the port uses the true quartic too.
class EaseOutQuart extends Curve {
  const EaseOutQuart();

  @override
  double transformInternal(double t) {
    final inverse = 1.0 - t;
    return 1.0 - inverse * inverse * inverse * inverse;
  }
}

/// Every visual token that is not an archetype colour, in one bag.
///
/// A ThemeExtension rather than a pile of constants so a fork can override the
/// whole sheet per-theme and every widget reads it through Theme.of(context).
/// The archetype role palette is deliberately NOT here: see
/// archetype_palette.dart for why it is a separate extension.
///
/// Source values are DESIGN.md sections 2, 3 and 7. Colours are authored in
/// OKLCH, which Flutter cannot express, so each sRGB value below carries its
/// OKLCH source in a comment and the conversion happened once, here, at
/// authoring time rather than at runtime.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.panel,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.hairline,
    required this.ink,
    required this.mutedInk,
    required this.sp2,
    required this.sp4,
    required this.sp8,
    required this.sp12,
    required this.sp16,
    required this.sp24,
    required this.sp32,
    required this.sp48,
    required this.sp64,
    required this.r0,
    required this.r2,
    required this.r4,
    required this.stateChange,
    required this.stateCurve,
    required this.radarMorph,
    required this.radarCurve,
  });

  /// The sheet as DESIGN.md specifies it. A fork edits this and nothing else.
  static const standard = AppTokens(
    panel: Color(0xFF0D1012), // oklch(0.17 0.006 250)
    surface1: Color(0xFF16191B), // oklch(0.21 0.006 250)
    surface2: Color(0xFF1F2225), // oklch(0.25 0.007 250)
    surface3: Color(0xFF282C2F), // oklch(0.29 0.008 250)
    hairline: Color(0xFF35383C), // oklch(0.34 0.008 250)
    ink: Color(0xFFECEFF1), // oklch(0.95 0.004 250)
    mutedInk: Color(0xFFB5B8BA), // oklch(0.78 0.005 250)
    sp2: 2,
    sp4: 4,
    sp8: 8,
    sp12: 12,
    sp16: 16,
    sp24: 24,
    sp32: 32,
    sp48: 48,
    sp64: 64,
    r0: 0,
    r2: 2,
    r4: 4,
    stateChange: Duration(milliseconds: 200),
    stateCurve: Curves.easeOut,
    radarMorph: Duration(milliseconds: 200),
    radarCurve: EaseOutQuart(),
  );

  // Neutral ramp (DESIGN.md section 2).
  final Color panel;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color hairline;
  final Color ink;
  final Color mutedInk;

  // Spacing, 4px base scale (DESIGN.md section 7).
  final double sp2;
  final double sp4;
  final double sp8;
  final double sp12;
  final double sp16;
  final double sp24;
  final double sp32;
  final double sp48;
  final double sp64;

  // Radii (DESIGN.md section 7). No pills, no fully-rounded controls.
  final double r0;
  final double r2;
  final double r4;

  // Motion (DESIGN.md section 7). Responsive only, 150-250 ms, ease-out.
  final Duration stateChange;
  final Curve stateCurve;
  final Duration radarMorph;
  final Curve radarCurve;

  @override
  AppTokens copyWith({
    Color? panel,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? hairline,
    Color? ink,
    Color? mutedInk,
    double? sp2,
    double? sp4,
    double? sp8,
    double? sp12,
    double? sp16,
    double? sp24,
    double? sp32,
    double? sp48,
    double? sp64,
    double? r0,
    double? r2,
    double? r4,
    Duration? stateChange,
    Curve? stateCurve,
    Duration? radarMorph,
    Curve? radarCurve,
  }) => AppTokens(
    panel: panel ?? this.panel,
    surface1: surface1 ?? this.surface1,
    surface2: surface2 ?? this.surface2,
    surface3: surface3 ?? this.surface3,
    hairline: hairline ?? this.hairline,
    ink: ink ?? this.ink,
    mutedInk: mutedInk ?? this.mutedInk,
    sp2: sp2 ?? this.sp2,
    sp4: sp4 ?? this.sp4,
    sp8: sp8 ?? this.sp8,
    sp12: sp12 ?? this.sp12,
    sp16: sp16 ?? this.sp16,
    sp24: sp24 ?? this.sp24,
    sp32: sp32 ?? this.sp32,
    sp48: sp48 ?? this.sp48,
    sp64: sp64 ?? this.sp64,
    r0: r0 ?? this.r0,
    r2: r2 ?? this.r2,
    r4: r4 ?? this.r4,
    stateChange: stateChange ?? this.stateChange,
    stateCurve: stateCurve ?? this.stateCurve,
    radarMorph: radarMorph ?? this.radarMorph,
    radarCurve: radarCurve ?? this.radarCurve,
  );

  /// Durations and curves snap at the midpoint: interpolating them means
  /// nothing, and a half-lerped curve is not a curve anyone designed.
  @override
  AppTokens lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      panel: Color.lerp(panel, other.panel, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t)!,
      sp2: lerpDouble(sp2, other.sp2, t)!,
      sp4: lerpDouble(sp4, other.sp4, t)!,
      sp8: lerpDouble(sp8, other.sp8, t)!,
      sp12: lerpDouble(sp12, other.sp12, t)!,
      sp16: lerpDouble(sp16, other.sp16, t)!,
      sp24: lerpDouble(sp24, other.sp24, t)!,
      sp32: lerpDouble(sp32, other.sp32, t)!,
      sp48: lerpDouble(sp48, other.sp48, t)!,
      sp64: lerpDouble(sp64, other.sp64, t)!,
      r0: lerpDouble(r0, other.r0, t)!,
      r2: lerpDouble(r2, other.r2, t)!,
      r4: lerpDouble(r4, other.r4, t)!,
      stateChange: t < 0.5 ? stateChange : other.stateChange,
      stateCurve: t < 0.5 ? stateCurve : other.stateCurve,
      radarMorph: t < 0.5 ? radarMorph : other.radarMorph,
      radarCurve: t < 0.5 ? radarCurve : other.radarCurve,
    );
  }
}
