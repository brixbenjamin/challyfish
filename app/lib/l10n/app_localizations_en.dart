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
  String get commitUnavailable =>
      'Commit. Unavailable until today\'s content arrives. Your run is safe.';

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
  String get campaignDaysHeading => 'Days';

  @override
  String get archetypeListSeparator => ', ';

  @override
  String dayPreviewNumber(int index) {
    return 'Day $index';
  }

  @override
  String campaignDaysRemainingCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count days ahead',
      one: '+1 day ahead',
    );
    return '$_temp0';
  }

  @override
  String dayNotYetRevealedLabel(int index) {
    return 'Day $index: not yet revealed';
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
  String get includedLabel => 'Included';

  @override
  String get ownedLabel => 'Owned';

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
  String get haveAccountButton => 'I already have an account';

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
  String get codeRejected =>
      'That code is not right, or it has expired. Ask for a new one.';

  @override
  String get linkFailed =>
      'That did not work, and nothing on this phone changed.';

  @override
  String get appleAccountName => 'your Apple ID';

  @override
  String get googleAccountName => 'your Google account';

  @override
  String get linkSheetTitle => 'Keep this record';

  @override
  String get linkSheetBody =>
      'Right now everything you have done lives only on this phone. Attaching an account keeps it, and lets you pick it up on another device.';

  @override
  String get signInSheetTitle => 'Pick it up here';

  @override
  String get signInSheetBody =>
      'Your record lives on the account, not on this phone. Sign in and it comes back — campaigns, history, and the questions you have already answered.';

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
  String get deleteHeadline => 'This removes everything';

  @override
  String get deleteScopeNotice =>
      'Every run, every day you reported, every note you wrote, and your diagnostic result. It happens immediately and cannot be undone.';

  @override
  String get deletePurchasesNotice =>
      'Purchases are held by the App Store or Google Play and are not part of this. Deleting your account does not refund a purchase.';

  @override
  String get deleteAnonymousNotice =>
      'This account has no identity attached, so deleting the app from this phone achieves the same thing.';

  @override
  String get keepMyAccountButton => 'Keep my account';

  @override
  String get deleteEverythingButton => 'Delete everything';

  @override
  String get deleteFailedNotice =>
      'That did not go through. Nothing has been deleted. Check your connection and try again.';

  @override
  String deleteConfirmInstruction(String word) {
    return 'Type $word to confirm.';
  }

  @override
  String get understoodButton => 'Understood';

  @override
  String get closeTooltip => 'Close';

  @override
  String get packContentsLead => 'Inside';

  @override
  String get workingButton => 'Working...';

  @override
  String get alreadyBoughtButton => 'Already bought it';

  @override
  String get restorePurchasesSubtitle =>
      'For a new phone, or after reinstalling';

  @override
  String get oneTimePurchaseNote => 'One-time purchase. Yours after that.';

  @override
  String get deliveringPackTitle => 'Setting up your pack';

  @override
  String get deliveringPackBody =>
      'Your purchase went through. We\'re fetching the pack now — this usually takes a few seconds.';

  @override
  String get deliveryTimedOut =>
      'Your purchase went through, but the pack hasn\'t arrived yet. It\'ll finish next time you open the app, or you can try again now.';

  @override
  String get purchasePendingNote =>
      'The store is still waiting on this purchase. It unlocks by itself once it goes through — you do not need to buy it again.';

  @override
  String get purchaseErrorFreePack => 'This pack is free.';

  @override
  String get purchaseErrorUnavailable =>
      'This pack is not available from the store right now.';

  @override
  String get purchaseErrorRestoreOwned =>
      'You already own this. Restoring it did not work — try again.';

  @override
  String get restoreNothingFound => 'There was nothing to restore.';

  @override
  String get restoreUnreachable => 'The store could not be reached. Try again.';

  @override
  String restoredPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count packs.',
      one: 'Restored 1 pack.',
    );
    return '$_temp0';
  }

  @override
  String get restoringRecordTitle => 'Getting your record';

  @override
  String get restoringRecordBody =>
      'Signed in. Bringing this account\'s campaigns and history onto this phone.';

  @override
  String get restoringRecordFailed =>
      'Your record is safe, but it could not be reached just now. Check your connection and try again.';

  @override
  String get tryAgainButton => 'Try again';

  @override
  String radarSummary(String distribution, String marks) {
    return 'Recent activity — $distribution. $marks';
  }

  @override
  String get radarSummaryEmpty =>
      'Recent-activity radar. Nothing recorded yet.';

  @override
  String radarAxisBand(String name, String band) {
    return '$name $band';
  }

  @override
  String get radarListSeparator => ', ';

  @override
  String get radarBandNone => 'none';

  @override
  String get radarBandLow => 'low';

  @override
  String get radarBandMedium => 'medium';

  @override
  String get radarBandHigh => 'high';

  @override
  String radarMarkEntry(String name, int count) {
    return '$name $count';
  }

  @override
  String radarMarks(int count, String details) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marks: $details.',
      zero: 'No marks yet.',
    );
    return '$_temp0';
  }

  @override
  String get reportButton => 'Report';

  @override
  String actionPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get dayPointsTotal => 'Today';

  @override
  String get runPointsTotal => 'This campaign';

  @override
  String get allTimePointsTotal => 'All time';

  @override
  String get optionalAction => 'Optional';

  @override
  String get dayFraming => 'Today\'s framing';

  @override
  String dayFramingSemantic(String title, String state) {
    return '$title. Today\'s framing. $state';
  }

  @override
  String get dayFramingStateShown => 'Shown.';

  @override
  String get dayFramingStateHidden => 'Hidden.';

  @override
  String willRecord(String outcome) {
    return 'This records: $outcome';
  }

  @override
  String actionSemanticMandatory(String title, String points, String state) {
    return '$title. Required. Worth $points. $state';
  }

  @override
  String actionSemanticOptional(String title, String points, String state) {
    return '$title. Optional. Worth $points. $state';
  }

  @override
  String get actionStateDone => 'Done.';

  @override
  String get actionStateNotDone => 'Not done.';
}
