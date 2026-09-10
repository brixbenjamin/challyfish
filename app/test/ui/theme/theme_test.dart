import 'package:feral/src/ui/theme/archetype_palette.dart';
import 'package:feral/src/ui/theme/theme.dart';
import 'package:feral/src/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // appDarkTheme() asks google_fonts for Inter, which reads the asset bundle.
  // Without the binding these are plain unit tests and google_fonts logs a
  // loud failure it then swallows; with it, the bundled face actually loads.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the theme carries both extensions', () {
    final theme = appDarkTheme();

    expect(theme.extension<AppTokens>(), isNotNull);
    expect(theme.extension<ArchetypePalette>(), isNotNull);
  });

  test('the chrome never picks up an archetype hue', () {
    final theme = appDarkTheme();
    final palette = theme.extension<ArchetypePalette>()!;

    final chrome = <Color>[
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.surface,
      theme.colorScheme.onSurface,
      theme.colorScheme.outline,
      theme.scaffoldBackgroundColor,
      theme.dividerColor,
    ];

    for (final role in palette.roles) {
      expect(
        chrome,
        isNot(contains(role)),
        reason: 'an archetype colour may only appear where a drive is named',
      );
    }
  });

  test('the scaffold sits on Panel', () {
    final theme = appDarkTheme();
    expect(theme.scaffoldBackgroundColor, AppTokens.standard.panel);
    expect(theme.dividerColor, AppTokens.standard.hairline);
  });

  test('forSort maps the four sorts to four distinct role colours', () {
    const palette = ArchetypePalette.standard;
    final seen = <Color>{
      for (var sort = 1; sort <= 4; sort++) palette.forSort(sort),
    };

    expect(seen, hasLength(4));
    expect(palette.forSort(1), const Color(0xFFC877EA));
    expect(palette.forSort(4), const Color(0xFFDE4D52));
  });

  test('both extensions lerp to a valid instance at 0, 0.5 and 1', () {
    const a = AppTokens.standard;
    final b = a.copyWith(ink: const Color(0xFFFFFFFF), sp8: 10);

    for (final t in <double>[0, 0.5, 1]) {
      final mixed = a.lerp(b, t);
      expect(mixed.sp8, inInclusiveRange(8, 10));
      expect(mixed.radarMorph, const Duration(milliseconds: 200));
    }

    const p = ArchetypePalette.standard;
    final q = p.copyWith(
      roles: const <Color>[
        Color(0xFF000000),
        Color(0xFF000000),
        Color(0xFF000000),
        Color(0xFF000000),
      ],
    );
    for (final t in <double>[0, 0.5, 1]) {
      expect(p.lerp(q, t).roles, hasLength(4));
    }
  });

  test('the radar curve is exact ease-out-quart', () {
    const curve = EaseOutQuart();

    expect(curve.transform(0), closeTo(0, 1e-9));
    expect(curve.transform(1), closeTo(1, 1e-9));
    expect(curve.transform(0.5), closeTo(1 - 0.5 * 0.5 * 0.5 * 0.5, 1e-9));
  });
}
