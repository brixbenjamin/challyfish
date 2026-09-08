import '../../l10n/app_localizations.dart';
import '../domain/grade.dart';
import '../domain/outcome.dart';

/// Exhaustive by construction: adding a fifth outcome will not compile until
/// this switch names it. The wording itself lives in app_en.arb, where the
/// reason for it is recorded next to the string — reporting `skipped` must read
/// exactly as easy as reporting `done`, or users stop reporting instead of
/// skipping and the record stops being honest (R6).
String outcomeLabel(AppLocalizations l10n, Outcome outcome) =>
    switch (outcome) {
      Outcome.done => l10n.outcomeDone,
      Outcome.partial => l10n.outcomePartial,
      Outcome.skipped => l10n.outcomeSkipped,
      Outcome.missed => l10n.outcomeMissed,
    };

/// The same shape, for grades. The enum's keys are wire values stored in two
/// databases; these are the words a user reads, and they may be reworded
/// freely (ADR-0021, ADR-0022).
String gradeName(AppLocalizations l10n, Grade grade) => switch (grade) {
  Grade.sovereign => l10n.gradeSovereign,
  Grade.passed => l10n.gradePassed,
  Grade.broken => l10n.gradeBroken,
};
