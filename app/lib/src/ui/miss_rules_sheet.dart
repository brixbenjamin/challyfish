import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/l10n_ext.dart';
import 'theme/theme_context.dart';

/// What a miss is, what it is not, and the one thing that ends a run early.
///
/// Opened from the info control beside the miss line, on the dashboard and on
/// the campaign detail screen, and at no other moment. It is a reference the
/// user asked for, never a prompt: nothing opens it on their behalf and nothing
/// here is a control except the one that closes it.
///
/// The rules it states live in `RunEngine` and `GradeThresholds`, and this
/// screen computes none of them — [missAllowance] arrives already derived, for
/// the same reason the dashboard takes its numbers from RunState. Copy that
/// recited a rule this widget worked out itself would be a second source of
/// truth for the one thing in the product that must not have one.
///
/// Deliberately not a warning. The line that opens it is "stated plainly, never
/// as a warning and never as a countdown", and a sheet that shouted about the
/// three-day rule would put the countdown back one tap away. Every paragraph
/// here is declarative, including the one that says how a run ends.
class MissRulesSheet extends StatelessWidget {
  const MissRulesSheet({required this.missAllowance, super.key});

  /// This campaign's allowance, already derived by the caller. Stated here
  /// rather than described in general, because it scales with campaign length
  /// (ADR-0012) — a sheet that explained the formula instead of naming the
  /// number would be the help article the product keeps refusing to write.
  final int missAllowance;

  static const closeKey = Key('miss-rules-close'); // niche:allow key

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.sp24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.missRulesHeading,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  key: closeKey,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: l10n.closeTooltip,
                ),
              ],
            ),
            SizedBox(height: tokens.sp8),

            // Order is an argument: what a miss is, then the thing users
            // assume is one and is not, then what this campaign tolerates,
            // then the only way a run ends early. The reassurance sits second
            // so it is read before the consequence rather than after it.
            CustomPaint(
              painter: _Timeline(
                markers: [
                  _DayMarker(day: 1, dayType: _DayType.start),
                  _DayMarker(day: 2, dayType: _DayType.normal),
                  _DayMarker(day: 3, dayType: _DayType.missed),
                  _DayMarker(day: 4, dayType: _DayType.normal),
                  _DayMarker(day: 5, dayType: _DayType.normal),
                  _DayMarker(day: 6, dayType: _DayType.abandoned),
                  _DayMarker(day: 7, dayType: _DayType.checkmark),
                  _DayMarker(day: 8, dayType: _DayType.failed),
                ],
              ),
              size: Size(double.infinity, 50),
            ),
            _Paragraph(l10n.missRulesWhatCounts),
            _Paragraph(l10n.missRulesNotBehind),
            _Paragraph(l10n.missRulesAllowance(missAllowance)),
            _Paragraph(l10n.missRulesAbandon),
          ],
        ),
      ),
    );
  }
}

/// The one way into [MissRulesSheet]: a quiet control beside the miss line, on
/// the dashboard and on the campaign detail screen.
///
/// Both screens open the sheet identically, so the `showModalBottomSheet` call
/// lives here rather than twice. It also keeps the sheet's only entry point in
/// the same file as the sheet, which is what makes "nothing opens this on the
/// user's behalf" checkable by reading one file.
///
/// An outline glyph at label size, in muted ink: the same weight as the line it
/// sits beside. A filled icon, or ink, would make asking look like something
/// the screen wants — and the miss line is the one place in the product where
/// drawing the eye is explicitly wrong.
///
/// The touch target keeps [IconButton]'s default 48, not the glyph's size. The
/// rest of the product holds that floor and a help affordance is not where it
/// gets relaxed.
class MissRulesButton extends StatelessWidget {
  const MissRulesButton({required this.missAllowance, super.key});

  /// Passed straight through to the sheet.
  final int missAllowance;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return IconButton(
      icon: Icon(Icons.info_outline, size: tokens.sp16, color: tokens.mutedInk),
      tooltip: context.l10n.missRulesTooltip,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MissRulesSheet(missAllowance: missAllowance),
      ),
    );
  }
}

/// One rule, at body weight with a step of space under it.
///
/// Plain text, as every other body in this app renders — there is no markdown
/// renderer yet and these are authored strings in the ARB bundle, not content.
class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.sp16),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.ink),
      ),
    );
  }
}

// Illustrates the concepts visually
class _Timeline extends CustomPainter {
  final List<_DayMarker> markers;
  _Timeline({required this.markers});

  final _linePaint = Paint()..color = Colors.white;
  final _padding = 30.0;
  final _circleRadius = 6.0;
  late final _circleDiameter = _circleRadius * 2;
  @override
  void paint(Canvas canvas, Size size) {
    final baseLine = size.height / 2;
    // base line connecting the dots
    canvas.drawLine(
      Offset(0, baseLine),
      Offset(size.width, baseLine),
      _linePaint,
    );

    double circleOffset = _padding + _circleRadius;
    for (final marker in markers) {
      // draw day label
      _paintDayText(canvas, circleOffset, marker.day, marker.color);

      // draw circle
      canvas.drawCircle(
        Offset(circleOffset, baseLine),
        _circleRadius,
        Paint()..color = marker.color,
      );

      // draw icon
      if (marker.icon != null) {
        final offset = Offset(
          circleOffset - _circleRadius,
          baseLine - _circleRadius,
        );
        _drawIcon(canvas, marker.icon!, offset);
      }

      // increase offset
      circleOffset += _padding + _circleRadius;
    }
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset offset) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontSize: _circleDiameter, fontFamily: icon.fontFamily),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  void _paintDayText(Canvas canvas, double x, int day, Color color) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: "Day $day",
      style: TextStyle(fontSize: _circleDiameter, color: color),
    );
    textPainter.layout(maxWidth: _circleDiameter * 3);
    textPainter.paint(canvas, Offset(x - textPainter.maxIntrinsicWidth / 2, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DayMarker {
  final int day;
  final _DayType dayType;
  IconData? get icon => switch (dayType) {
    _DayType.checkmark => Icons.check,
    _DayType.failed => Icons.close,
    _ => null,
  };

  Color get color => _dayTypeColorMap[dayType]!;

  _DayMarker({required this.day, required this.dayType});
}

enum _DayType { start, normal, missed, abandoned, checkmark, failed }

const Map<_DayType, Color> _dayTypeColorMap = {
  _DayType.start: Colors.blueGrey,
  _DayType.abandoned: Colors.redAccent,
  _DayType.missed: Colors.amber,
  _DayType.checkmark: Colors.green,
  _DayType.normal: Colors.white,
  _DayType.failed: Colors.red,
};
