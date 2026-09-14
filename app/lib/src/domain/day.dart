import 'campaign.dart';

/// What a day is, beyond its position. Authoring and presentation metadata,
/// never structure: a rest day still carries a mandatory action — a reflective
/// one — so nothing about outcome derivation, the miss allowance or the grade
/// changes with it (ADR-0034).
///
/// A check-constrained text column in Postgres rather than a boolean, because
/// the taxonomy has a second member lurking (the bridge day, Q19) and parallel
/// flags would permit a day that is both.
enum DayKind {
  standard,
  rest;

  /// Reads the server's string. An unrecognised value is `standard` rather than
  /// an exception: content authored against a newer app than this one costs the
  /// surface a presentation nuance, and must not cost the user the day.
  static DayKind fromKey(String key) => DayKind.values.firstWhere(
    (kind) => kind.name == key,
    orElse: () => DayKind.standard,
  );
}

/// One day of a campaign, and the owner of its actions (ADR-0034).
///
/// Assembled by `ContentRepository.dayFor`, never by a widget: a day is a rule
/// about which actions belong together and in what order, and PRODUCT.md
/// principle 7 keeps rules out of the UI.
class DaySpec {
  const DaySpec({
    required this.id,
    required this.campaignId,
    required this.dayIndex,
    required this.title,
    this.kind = DayKind.standard,
    this.primaryArchetypeId,
    this.bodyMd,
    this.actions = const [],
  });

  final String id;
  final String campaignId;

  /// 1-based. Contiguous from 1 to the campaign's lengthDays — a pgTAP
  /// assertion over rows that exist, since ADR-0034.
  final int dayIndex;
  final String title;
  final DayKind kind;

  /// The one drive the day's surface wears, under the One Drive Per Loop Rule.
  /// Null means the surface falls back to the mandatory action's dominant
  /// drive, which is what it did before a day could say anything for itself.
  final String? primaryArchetypeId;

  /// The framing copy, read before the commit. Null when it is not available:
  /// a locked pack, or an owned pack whose bodies have not been pulled yet
  /// (ADR-0025). A real state, not a failure — callers degrade to the existing
  /// "content unavailable" path.
  final String? bodyMd;

  /// The day's actions, mandatory first and then by `sort`. Empty is a real
  /// state: a day cached ahead of its actions after a partial sync.
  final List<ActionSpec> actions;

  /// The day's one mandatory action — the one the grade depends on — or null
  /// when it has not been cached. Null is the partial-sync state the caller
  /// degrades on, not one this getter papers over by picking an optional.
  ActionSpec? get mandatory {
    for (final action in actions) {
      if (!action.isOptional) return action;
    }
    return null;
  }

  List<ActionSpec> get optionals => [
    for (final action in actions)
      if (action.isOptional) action,
  ];
}
