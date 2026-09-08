import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/balance_state.dart';
import '../../core/l10n_ext.dart';

/// The app's one real visualisation: four fixed axes showing how much the user
/// has acted in each archetype recently.
///
/// No design brief exists for this yet — this is a correct, legible default
/// that a later design pass replaces without touching BalanceState.
///
/// The mark counts beside each label are deliberate. The balance decays
/// (ADR-0010); the marks do not. Showing them together is what keeps a falling
/// radar from reading as erasure, and is why nothing here frames the decay as a
/// loss.
class ArchetypeRadar extends StatelessWidget {
  const ArchetypeRadar({required this.state, this.size = 240, super.key});

  final BalanceState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadarPainter(
              values: [
                for (final archetype in state.archetypes)
                  state.normalizedFor(archetype.id),
              ],
              gridColor: theme.dividerColor,
              fillColor: theme.colorScheme.primary.withValues(alpha: 0.25),
              strokeColor: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Labels live outside the painter so they are reachable by screen
        // readers and by widget tests.
        for (final archetype in state.archetypes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(archetype.name),
                if (state.marksFor(archetype.id) > 0)
                  Text(context.l10n.markCount(state.marksFor(archetype.id))),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.gridColor,
    required this.fillColor,
    required this.strokeColor,
  });

  /// One per axis, each 0 to 1.
  final List<double> values;
  final Color gridColor;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final step = 2 * math.pi / values.length;

    Offset pointAt(int index, double fraction) {
      final angle = -math.pi / 2 + step * index;
      return centre +
          Offset(math.cos(angle), math.sin(angle)) * (radius * fraction);
    }

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    for (final ring in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final point = pointAt(i, ring);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path..close(), grid);
    }

    for (var i = 0; i < values.length; i++) {
      canvas.drawLine(centre, pointAt(i, 1), grid);
    }

    final shape = Path();
    for (var i = 0; i < values.length; i++) {
      // A floor so an axis with a little activity is still visible: a shape
      // pinned to the centre reads as "nothing", which is not the same as
      // "a little, a while ago".
      final fraction = values[i] <= 0 ? 0.0 : math.max(values[i], 0.04);
      final point = pointAt(i, fraction);
      if (i == 0) {
        shape.moveTo(point.dx, point.dy);
      } else {
        shape.lineTo(point.dx, point.dy);
      }
    }
    shape.close();

    canvas.drawPath(shape, Paint()..color = fillColor);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = strokeColor,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      !identical(old.values, values) ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor;
}
