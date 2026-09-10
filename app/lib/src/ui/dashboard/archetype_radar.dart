import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../app/balance_state.dart';
import '../../app/balance_summary.dart';
import '../../core/l10n_ext.dart';
import '../theme/theme_context.dart';

/// The app's one real visualisation: four fixed axes showing how much the user
/// has acted in each archetype recently.
///
/// Built to docs/design/briefs/archetype-radar.md. Two rules carry the whole
/// component. Archetype colour appears only at an axis vertex and on that
/// axis's name, because a distribution is not four coloured claims and the
/// Named-Drive Rule (DESIGN.md section 2) does not bend for a chart. And the
/// mark counts sit beside the names because the balance decays (ADR-0010) and
/// the marks do not: showing them together is what keeps a falling radar from
/// reading as erasure.
///
/// Axis identity is Archetype.sort and fixed screen position. No key literal
/// appears here, and none may (ADR-0021).
class ArchetypeRadar extends StatefulWidget {
  const ArchetypeRadar({required this.state, this.size = 240, super.key});

  final BalanceState state;
  final double size;

  @override
  State<ArchetypeRadar> createState() => _ArchetypeRadarState();
}

/// Which of the four label blocks a slot holds, and the figure itself.
///
/// An enum rather than a string id because lib/src/ui carries no string
/// literals at all, and because a mistyped id would fail at runtime while a
/// mistyped enum value fails at compile time.
enum _Slot { figure, top, right, bottom, left }

/// Indices into the sort-ordered archetype list, in clock order:
/// top, right, bottom, left.
///
/// sort 1 goes to 12 and sort 4 to 6 so the two red-side hues ADR-0026 holds
/// about 0.08 apart in lightness sit opposite each other, never adjacent. The
/// eye is never asked to separate them side by side. Label and semantics order
/// stays sort order, independent of this.
const _clockOrder = <int>[0, 1, 3, 2];

const _slotOrder = <_Slot>[_Slot.top, _Slot.right, _Slot.bottom, _Slot.left];

/// Angles matching _slotOrder, in radians.
const _angles = <double>[-math.pi / 2, 0, math.pi / 2, math.pi];

class _ArchetypeRadarState extends State<ArchetypeRadar> {
  /// Normalised values in clock order, so index i is the axis at _angles[i].
  ///
  /// An axis whose archetype is not loaded zero-fills rather than throwing:
  /// the component is total over its inputs, and a partial content sync draws
  /// fewer contributions rather than an error (brief section 5).
  List<double> _fractionsOf(BalanceState state) => <double>[
    for (final i in _clockOrder)
      if (i < state.archetypes.length)
        state.normalizedFor(state.archetypes[i].id)
      else
        0,
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.archetypePalette;
    final theme = Theme.of(context);
    final archetypes = widget.state.archetypes;

    // A colour per clock position. The placeholder never reaches the canvas:
    // a zero-filled axis draws no dot.
    final dotColours = <Color>[
      for (final i in _clockOrder)
        if (i < archetypes.length)
          palette.forSort(archetypes[i].sort)
        else
          tokens.mutedInk,
    ];

    return CustomMultiChildLayout(
      delegate: _RadarLayout(
        size: widget.size,
        gap: tokens.sp8,
        textScaler: MediaQuery.textScalerOf(context),
      ),
      children: <Widget>[
        LayoutId(
          id: _Slot.figure,
          // One graphic, one sentence, and it is read first. The label is the
          // formatter's, never anything this widget worked out for itself.
          child: Semantics(
            image: true,
            label: balanceSummary(widget.state, context.l10n),
            sortKey: const OrdinalSortKey(0),
            child: CustomPaint(
              painter: _RadarPainter(
                fractions: _fractionsOf(widget.state),
                dotColours: dotColours,
                gridColour: tokens.hairline,
                fillColour: tokens.ink.withValues(alpha: 0.10),
                strokeColour: tokens.ink.withValues(alpha: 0.52),
                nubColour: tokens.mutedInk,
                panelColour: tokens.panel,
              ),
            ),
          ),
        ),
        for (var i = 0; i < _clockOrder.length; i++)
          if (_clockOrder[i] < archetypes.length)
            LayoutId(
              id: _slotOrder[i],
              child: _VertexLabel(
                name: archetypes[_clockOrder[i]].name,
                nameColour: dotColours[i],
                marks: widget.state.marksFor(archetypes[_clockOrder[i]].id),
                mutedInk: tokens.mutedInk,
                labelStyle: theme.textTheme.labelLarge,
                slot: _slotOrder[i],
                // Heard in sort order, whatever clock position they occupy:
                // the reading order of the record is not the geometry of the
                // figure (brief section 4.2).
                readingOrder: archetypes[_clockOrder[i]].sort,
              ),
            ),
      ],
    );
  }
}

/// The archetype name, and beneath it the permanent mark count.
///
/// Real widgets outside the painter: reachable by a screen reader, findable by
/// a test, and legible on their own if the figure is ignored entirely.
class _VertexLabel extends StatelessWidget {
  const _VertexLabel({
    required this.name,
    required this.nameColour,
    required this.marks,
    required this.mutedInk,
    required this.labelStyle,
    required this.slot,
    required this.readingOrder,
  });

  final String name;
  final Color nameColour;
  final int marks;
  final Color mutedInk;
  final TextStyle? labelStyle;
  final _Slot slot;

  /// The archetype's sort, 1 to 4. Screen-reader order, not screen position.
  final int readingOrder;

  @override
  Widget build(BuildContext context) {
    // Top and bottom blocks centre over their vertex; the side blocks anchor
    // away from the figure so each block grows outward and never crosses it.
    // start and end rather than left and right, so RTL swaps them for free.
    final align = switch (slot) {
      _Slot.left => TextAlign.end,
      _Slot.right => TextAlign.start,
      _ => TextAlign.center,
    };
    final cross = switch (slot) {
      _Slot.left => CrossAxisAlignment.end,
      _Slot.right => CrossAxisAlignment.start,
      _ => CrossAxisAlignment.center,
    };

    return Semantics(
      sortKey: OrdinalSortKey(readingOrder.toDouble()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: cross,
        children: <Widget>[
          Text(
            name,
            textAlign: align,
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: labelStyle?.copyWith(color: nameColour),
          ),
          // Shown only when it is more than nothing. A zero would be a score.
          if (marks > 0)
            Text(
              context.l10n.markCount(marks),
              textAlign: align,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: labelStyle?.copyWith(color: mutedInk),
            ),
        ],
      ),
    );
  }
}

/// Places the figure and the four label blocks, and decides how much radius
/// the figure is allowed to keep.
///
/// When the two compete, the rings and the labels win and the figure yields
/// radius (brief section 4). The labels are the accessible record; a clipped
/// name is a worse failure than a smaller shape.
class _RadarLayout extends MultiChildLayoutDelegate {
  _RadarLayout({
    required this.size,
    required this.gap,
    required this.textScaler,
  });

  /// The requested figure edge. The overall box is wider and taller, to give
  /// the vertex blocks somewhere to go.
  final double size;
  final double gap;
  final TextScaler textScaler;

  @override
  Size getSize(BoxConstraints constraints) =>
      constraints.constrain(Size(size * 1.5, size * 4 / 3));

  @override
  void performLayout(Size overall) {
    final centre = Offset(overall.width / 2, overall.height / 2);

    // 0.85 of the half-edge is the outer ring, kept from the painter this
    // replaces. Everything below only ever takes radius away from it.
    final base = size / 2 * 0.85;
    final floor = math.min(base, size * 0.21);

    // Measure first. Side blocks are capped narrow so a long name wraps into
    // the block rather than pushing the figure off centre, and every block is
    // capped in height so it can never demand more room than the box has.
    final vertical = BoxConstraints.loose(
      Size(
        math.min(size * 0.62, overall.width),
        math.max(0, overall.height / 2 - floor - gap),
      ),
    );
    final horizontal = BoxConstraints.loose(
      Size(
        math.min(size * 0.30, math.max(0, overall.width / 2 - floor - gap)),
        overall.height,
      ),
    );

    // A slot with no child is an axis whose archetype is not loaded. It takes
    // no room, and the figure keeps the radius it would have yielded.
    Size measure(_Slot slot, BoxConstraints limits) =>
        hasChild(slot) ? layoutChild(slot, limits) : Size.zero;

    final blocks = <_Slot, Size>{
      _Slot.top: measure(_Slot.top, vertical),
      _Slot.bottom: measure(_Slot.bottom, vertical),
      _Slot.left: measure(_Slot.left, horizontal),
      _Slot.right: measure(_Slot.right, horizontal),
    };

    final radius = math.max(
      floor,
      <double>[
        base,
        centre.dy - blocks[_Slot.top]!.height - gap,
        overall.height - centre.dy - blocks[_Slot.bottom]!.height - gap,
        centre.dx - blocks[_Slot.left]!.width - gap,
        overall.width - centre.dx - blocks[_Slot.right]!.width - gap,
      ].reduce(math.min),
    );

    layoutChild(_Slot.figure, BoxConstraints.tight(Size.square(radius * 2)));
    positionChild(_Slot.figure, centre - Offset(radius, radius));

    void place(_Slot slot, Offset origin) {
      if (hasChild(slot)) positionChild(slot, origin);
    }

    place(
      _Slot.top,
      Offset(
        centre.dx - blocks[_Slot.top]!.width / 2,
        math.max(0, centre.dy - radius - gap - blocks[_Slot.top]!.height),
      ),
    );
    place(
      _Slot.bottom,
      Offset(
        centre.dx - blocks[_Slot.bottom]!.width / 2,
        centre.dy + radius + gap,
      ),
    );
    place(
      _Slot.left,
      Offset(
        math.max(0, centre.dx - radius - gap - blocks[_Slot.left]!.width),
        centre.dy - blocks[_Slot.left]!.height / 2,
      ),
    );
    place(
      _Slot.right,
      Offset(
        centre.dx + radius + gap,
        centre.dy - blocks[_Slot.right]!.height / 2,
      ),
    );
  }

  @override
  bool shouldRelayout(_RadarLayout old) =>
      old.size != size || old.gap != gap || old.textScaler != textScaler;
}

/// Neutral geometry, archetype colour only at the vertices.
///
/// Colours arrive as plain Colors rather than through a BuildContext so the
/// painter stays theme-agnostic and cheap to assert on.
class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.fractions,
    required this.dotColours,
    required this.gridColour,
    required this.fillColour,
    required this.strokeColour,
    required this.nubColour,
    required this.panelColour,
  });

  /// One per axis, 0 to 1, in clock order.
  final List<double> fractions;

  /// One per axis, in the same clock order as [fractions].
  final List<Color> dotColours;

  final Color gridColour;
  final Color fillColour;
  final Color strokeColour;
  final Color nubColour;
  final Color panelColour;

  @override
  void paint(Canvas canvas, Size size) {
    if (fractions.isEmpty) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    Offset pointAt(int index, double fraction) =>
        centre +
        Offset(math.cos(_angles[index]), math.sin(_angles[index])) *
            (radius * fraction);

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColour;

    for (final ring in const <double>[0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (var i = 0; i < fractions.length; i++) {
        final point = pointAt(i, ring);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path..close(), grid);
    }

    for (var i = 0; i < fractions.length; i++) {
      canvas.drawLine(centre, pointAt(i, 1), grid);
    }

    // A floor so an axis with a little activity is still visible: a shape
    // pinned to the centre reads as nothing, which is not the same as a
    // little, a while ago.
    final drawn = <double>[
      for (final value in fractions)
        if (value <= 0) 0.0 else math.max(value, 0.04),
    ];

    if (drawn.every((value) => value == 0)) {
      // Never acted. One quiet nub, not an empty frame and not an error.
      canvas.drawCircle(centre, 2, Paint()..color = nubColour);
      return;
    }

    final shape = Path();
    for (var i = 0; i < drawn.length; i++) {
      final point = pointAt(i, drawn[i]);
      if (i == 0) {
        shape.moveTo(point.dx, point.dy);
      } else {
        shape.lineTo(point.dx, point.dy);
      }
    }
    shape.close();

    canvas.drawPath(shape, Paint()..color = fillColour);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColour,
    );

    // The vertices, and only the vertices, carry the drive's colour. The Panel
    // ring keeps the dot legible where it sits on the polygon fill.
    for (var i = 0; i < drawn.length; i++) {
      if (drawn[i] <= 0) continue;
      final point = pointAt(i, drawn[i]);
      canvas.drawCircle(point, 4, Paint()..color = dotColours[i]);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = panelColour,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      !_sameDoubles(old.fractions, fractions) ||
      !_sameColours(old.dotColours, dotColours) ||
      old.gridColour != gridColour ||
      old.fillColour != fillColour ||
      old.strokeColour != strokeColour ||
      old.nubColour != nubColour ||
      old.panelColour != panelColour;
}

bool _sameDoubles(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _sameColours(List<Color> a, List<Color> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
