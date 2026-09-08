// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commitButton => 'Commit';

  @override
  String get campaignsTitle => 'Campaigns';

  @override
  String get contentUnavailable =>
      'Content unavailable. Your run is safe — pull again when you have signal.';

  @override
  String dayOfLength(int day, int length) {
    return 'Day $day of $length';
  }

  @override
  String missesUsed(int used, int allowed) {
    return '$used of $allowed misses used';
  }

  @override
  String reportedOutcome(String outcome) {
    return 'Reported: $outcome';
  }

  @override
  String lengthInDays(int days) {
    return '$days days';
  }

  @override
  String get outcomeDone => 'Done';

  @override
  String get outcomePartial => 'Partial';

  @override
  String get outcomeSkipped => 'Skipped';

  @override
  String get outcomeMissed => 'Missed';

  @override
  String get backButton => 'Back';

  @override
  String get startButton => 'Start';

  @override
  String get browseInsteadButton => 'Look at the others';

  @override
  String get diagnosticWeakestLead =>
      'When you had to choose, you chose this one least:';

  @override
  String get diagnosticRecommendationLead => 'Start here:';

  @override
  String questionProgress(int n, int total) {
    return '$n of $total';
  }

  @override
  String get doctrineTitle => 'Doctrine';

  @override
  String get doctrineEmpty => 'Nothing here yet. Check back after a sync.';

  @override
  String get lockedBadge => 'Locked';

  @override
  String get unlockButton => 'Unlock';

  @override
  String missesAllowed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count misses allowed',
      one: '1 miss allowed',
    );
    return '$_temp0';
  }

  @override
  String get abandonActiveRunWarning =>
      'Starting this will abandon your current run. The days you already logged still count, but the run cannot be resumed.';

  @override
  String get abandonAndStartButton => 'Abandon and start';

  @override
  String markCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks',
      one: '1 mark',
    );
    return '$_temp0';
  }

  @override
  String get recordButton => 'Record';

  @override
  String get notePlaceholder => 'One line, if you want';

  @override
  String get openDoctrine => 'Doctrine';

  @override
  String get openSettings => 'Settings';
}
