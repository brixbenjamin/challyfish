import 'package:flutter/material.dart';

import 'archetype_palette.dart';
import 'tokens.dart';

/// Same shape as context.l10n: non-nullable, so a call site never writes `!`
/// and a theme missing its extensions fails at wiring time rather than
/// quietly rendering in the wrong colours.
extension ThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;

  ArchetypePalette get archetypePalette =>
      Theme.of(this).extension<ArchetypePalette>()!;
}
