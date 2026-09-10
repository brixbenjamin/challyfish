import 'package:flutter/material.dart';

/// The four archetype role colours, and nothing else.
///
/// A second, independent ThemeExtension on purpose. appDarkTheme()'s
/// ColorScheme and TextTheme never read it: the neutral chrome is complete
/// without an archetype colour anywhere in it, which is the Named-Drive Rule
/// (DESIGN.md section 2) expressed as a dependency rather than as a promise.
///
/// The mapping is positional, by Archetype.sort, never by key. sort is fixed
/// 1 to 4 forever (ADR-0004), so position is a stable identity and no code
/// outside the seed ever names an archetype (ADR-0021).
///
/// Values are the CVD-validated ADR-0026 hues, authored in OKLCH and converted
/// to sRGB once, here. Each clears 4.5:1 on Panel.
@immutable
class ArchetypePalette extends ThemeExtension<ArchetypePalette> {
  const ArchetypePalette({required this.roles});

  static const standard = ArchetypePalette(
    roles: <Color>[
      Color(0xFFC877EA), // sort 1, oklch(0.70 0.18 315) blue-violet
      Color(0xFF2DB0E3), // sort 2, oklch(0.71 0.13 230) steel-cyan
      Color(0xFFCFA100), // sort 3, oklch(0.73 0.15 88) amber-gold
      Color(0xFFDE4D52), // sort 4, oklch(0.62 0.18 22) crimson
    ],
  );

  /// Length four, in sort order.
  final List<Color> roles;

  /// The only archetype-identity to colour mapping in the app.
  Color forSort(int sort) => roles[sort - 1];

  @override
  ArchetypePalette copyWith({List<Color>? roles}) =>
      ArchetypePalette(roles: roles ?? this.roles);

  @override
  ArchetypePalette lerp(
    covariant ThemeExtension<ArchetypePalette>? other,
    double t,
  ) {
    if (other is! ArchetypePalette) return this;
    return ArchetypePalette(
      roles: <Color>[
        for (var i = 0; i < roles.length; i++)
          Color.lerp(roles[i], other.roles[i], t)!,
      ],
    );
  }
}
