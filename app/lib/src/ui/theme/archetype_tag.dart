import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/archetype.dart';
import 'archetype_palette.dart';
import 'theme_context.dart';

/// The one place a campaign or day's archetype identity is drawn as a small
/// dot-and-label mark: a coloured dot (split when more than one drive is
/// named) beside the drive's own name, text, never hue alone (the
/// Named-Drive Rule, DESIGN.md section 2).
class ArchetypeTag extends StatelessWidget {
  const ArchetypeTag({required this.archetypes, super.key});

  final List<Archetype> archetypes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final palette = context.archetypePalette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(tokens.sp8),
          painter: _ArchetypeDots(archetypes: archetypes, palette: palette),
        ),
        SizedBox(width: tokens.sp4),
        Text(
          archetypes.map((a) => a.name).join(context.l10n.archetypeListSeparator),
          style: theme.textTheme.labelMedium?.copyWith(color: tokens.mutedInk),
        ),
      ],
    );
  }
}

class _ArchetypeDots extends CustomPainter {
  final List<Archetype> archetypes;
  final ArchetypePalette palette;
  _ArchetypeDots({required this.archetypes, required this.palette});
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width != size.height) {
      // Developer-facing invariant crash, never rendered to a user.
      throw Exception("Width and height have to be the same."); // niche:allow
    }

    final colors = archetypes.map((a) => palette.forSort(a.sort)).toList();
    final center = Offset(size.width / 2, size.width / 2);
    final radius = size.width / 2;

    final parts = colors.length;
    var startAngle = pi / 2;
    final sweepAngle = 2 * pi / parts;
    for (var i = 0; i < parts; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()..color = colors[i],
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
