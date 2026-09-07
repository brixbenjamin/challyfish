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
}
