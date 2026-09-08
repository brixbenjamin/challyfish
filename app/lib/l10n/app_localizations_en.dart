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

  @override
  String get gradeSovereign => 'Sovereign';

  @override
  String get gradePassed => 'Passed';

  @override
  String get gradeBroken => 'Broken';

  @override
  String gradeSummarySovereign(String title) {
    return 'Every day of $title. No misses.';
  }

  @override
  String gradeSummaryPassed(String title, int misses, int allowed) {
    return 'You finished $title. $misses of $allowed misses used.';
  }

  @override
  String gradeSummaryBroken(String title, int misses, int allowed) {
    return 'You finished $title with $misses misses. It allowed $allowed.';
  }

  @override
  String get marksEarnedLead => 'Marks earned:';

  @override
  String get noMarkNote => 'No mark. The days you did still count.';

  @override
  String get linkPromptBody =>
      'This record lives on this phone only. Attach an identity and it survives losing it.';

  @override
  String get linkIdentityButton => 'Attach an identity';

  @override
  String get whatNextButton => 'What next';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get reminderToggle => 'Daily reminder';

  @override
  String get reminderChangeTime => 'Change time';

  @override
  String get reminderOffSubtitle =>
      'One notification a day, at a time you choose.';

  @override
  String reminderOnAt(String time) {
    return 'One notification a day, at $time.';
  }

  @override
  String get linkIdentitySettingsSubtitle =>
      'So your record survives losing this phone.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get notificationsBlockedNotice =>
      'Notifications are turned off for Feral. Turn them on in your system settings if you want the reminder.';

  @override
  String get reminderNotificationTitle => 'Today';

  @override
  String get reminderNotificationBody => 'Your action is waiting.';

  @override
  String get reminderChannelName => 'Daily reminder';

  @override
  String get doctrineIntroTitle => 'The Zoo';

  @override
  String get doctrineIntroBody =>
      'Safety, predictability and a single-file path, traded for the ability to choose your own. Nobody forced it on you. That is what makes it hard to see.';

  @override
  String get doctrineIntroPromise => 'Eight questions. Then one thing a day.';

  @override
  String get continueButton => 'Go on';

  @override
  String get privacyNoticeTitle => 'Before you start';

  @override
  String get privacyNoticeAccount =>
      'Feral made you an account when you opened it. You were not asked for anything, and you do not have to give anything.';

  @override
  String get privacyNoticeStored =>
      'It stores what you report each day, a line of note if you write one, and your answers here as four numbers. Nothing else. No location, no contacts, no health data, no tracking.';

  @override
  String get privacyNoticeLoss =>
      'That account lives on this phone only. If you lose the phone before attaching an identity, the record is gone and nothing can bring it back. You can attach one any time in settings.';

  @override
  String get dismissNoticeButton => 'OK';

  @override
  String get syncOfflineNotice => 'Offline. Your days are being recorded here.';

  @override
  String get syncFailingNotice =>
      'Your progress is saved on this phone but has not reached the server yet. It will keep trying.';

  @override
  String get emailAddressField => 'Email address';

  @override
  String get emailStepTitle => 'Your email';

  @override
  String get codeStepTitle => 'Enter the code';

  @override
  String get codeField => 'Code';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get resendCodeButton => 'Send another code';

  @override
  String get changeEmailButton => 'Use a different address';

  @override
  String codeSentTo(String email) {
    return 'We sent a six-digit code to $email.';
  }

  @override
  String get codeSendFailed =>
      'That did not send. Check the address and try again.';

  @override
  String get linkSheetTitle => 'Keep this record';

  @override
  String get linkSheetBody =>
      'Right now everything you have done lives only on this phone. Attaching an account keeps it, and lets you pick it up on another device.';

  @override
  String get notNowButton => 'Not now';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get replaceHeadline => 'This phone has its own record';

  @override
  String get replaceSummaryUntitled =>
      'There is progress recorded on this phone.';

  @override
  String replaceSummary(String title, int reported, int total) {
    return '\"$title\" — $reported of $total days reported.';
  }

  @override
  String replaceWarning(String account) {
    return 'Signing in as $account replaces it with the record from that account. What is on this phone cannot be recovered afterwards.';
  }

  @override
  String get keepThisRecordButton => 'Keep this record';

  @override
  String get replaceWithAccountButton => 'Replace with my account';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get signedInRow => 'Signed in';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSettingsSubtitle =>
      'Removes every run, day, and note. Immediate.';

  @override
  String get understoodButton => 'Understood';
}
