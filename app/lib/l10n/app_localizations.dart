import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// [niche] Button that acknowledges today's action before doing it. The commit/report verbs are the product's vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get commitButton;

  /// [niche] App bar title of the campaign list.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaignsTitle;

  /// Shown on the dashboard when today's action has not synced. Must reassure, never alarm.
  ///
  /// In en, this message translates to:
  /// **'Content unavailable. Your run is safe — pull again when you have signal.'**
  String get contentUnavailable;

  /// Progress through the current run, on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {length}'**
  String dayOfLength(int day, int length);

  /// Stated plainly on the dashboard. Never a warning and never a countdown (ADR-0010).
  ///
  /// In en, this message translates to:
  /// **'{used} of {allowed} misses used'**
  String missesUsed(int used, int allowed);

  /// Shown once today has been reported.
  ///
  /// In en, this message translates to:
  /// **'Reported: {outcome}'**
  String reportedOutcome(String outcome);

  /// A campaign's length, in lists and on detail screens.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String lengthInDays(int days);

  /// Report option.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get outcomeDone;

  /// Report option.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get outcomePartial;

  /// Report option. Must read exactly as easy as Done — if skipping feels like a confession, users stop reporting instead of skipping and the record stops being honest (R6).
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get outcomeSkipped;

  /// Written by rollover, never chosen by the user.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get outcomeMissed;

  /// Returns to the previous diagnostic question.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// Starts the recommended campaign.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// [niche] Declines the recommendation and opens browse.
  ///
  /// In en, this message translates to:
  /// **'Look at the others'**
  String get browseInsteadButton;

  /// [niche] Introduces the weakest drive. Must read as relative, never as a low score (ADR-0009).
  ///
  /// In en, this message translates to:
  /// **'When you had to choose, you chose this one least:'**
  String get diagnosticWeakestLead;

  /// Introduces the recommended campaign.
  ///
  /// In en, this message translates to:
  /// **'Start here:'**
  String get diagnosticRecommendationLead;

  /// Position within the eight diagnostic questions.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String questionProgress(int n, int total);

  /// [niche] Name of the reading section.
  ///
  /// In en, this message translates to:
  /// **'Doctrine'**
  String get doctrineTitle;

  /// Empty state for the reading section before first sync.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Check back after a sync.'**
  String get doctrineEmpty;

  /// Marks a campaign in a pack the user has not bought.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedBadge;

  /// Opens the purchase sheet for a locked pack.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// The campaign's miss allowance, stated on its detail screen. It scales with campaign length (ADR-0012) and so differs per campaign, which is why it is stated rather than left to a help article.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 miss allowed} other{{count} misses allowed}}'**
  String missesAllowed(int count);

  /// [niche] One of exactly three destructive confirmations. Says effort is not erased, which is the product's position (ADR-0003).
  ///
  /// In en, this message translates to:
  /// **'Starting this will abandon your current run. The days you already logged still count, but the run cannot be resumed.'**
  String get abandonActiveRunWarning;

  /// [niche] Starts this campaign in place of the active run. Names the cost in the label itself, not only in the warning above it.
  ///
  /// In en, this message translates to:
  /// **'Abandon and start'**
  String get abandonAndStartButton;

  /// [niche] How many marks an archetype has earned, beside its radar label. 'Mark' is the product's vocabulary. Marks never decay, and this count sitting next to the decaying balance is what keeps a falling radar from reading as erasure (ADR-0010).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mark} other{{count} marks}}'**
  String markCount(int count);

  /// [niche] Submits the day's report. The commit/report verbs are the product's vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordButton;

  /// [niche] Hint on the optional note field. The optionality is the point.
  ///
  /// In en, this message translates to:
  /// **'One line, if you want'**
  String get notePlaceholder;

  /// [niche] Tooltip on the dashboard's link to the reading section.
  ///
  /// In en, this message translates to:
  /// **'Doctrine'**
  String get openDoctrine;

  /// Tooltip on the dashboard's link to settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// [niche] Grade for a run finished with no misses. Stored as `sovereign`; only this word changes.
  ///
  /// In en, this message translates to:
  /// **'Sovereign'**
  String get gradeSovereign;

  /// [niche] Grade for a run finished within its miss allowance.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get gradePassed;

  /// [niche] Grade for a run finished over its allowance. Never 'failed' — nothing is failed out of (ADR-0003).
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get gradeBroken;

  /// [niche] States the Sovereign result. No congratulation.
  ///
  /// In en, this message translates to:
  /// **'Every day of {title}. No misses.'**
  String gradeSummarySovereign(String title);

  /// [niche] States the Passed result.
  ///
  /// In en, this message translates to:
  /// **'You finished {title}. {misses} of {allowed} misses used.'**
  String gradeSummaryPassed(String title, int misses, int allowed);

  /// [niche] States the Broken result. No consolation, no retry offer — the honest record is the product.
  ///
  /// In en, this message translates to:
  /// **'You finished {title} with {misses} misses. It allowed {allowed}.'**
  String gradeSummaryBroken(String title, int misses, int allowed);

  /// [niche] Introduces the archetype marks a run awarded. 'Mark' is the product's vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Marks earned:'**
  String get marksEarnedLead;

  /// [niche] Shown when a Broken run earns no mark. The second sentence is load-bearing.
  ///
  /// In en, this message translates to:
  /// **'No mark. The days you did still count.'**
  String get noMarkNote;

  /// [niche] Shown on the completion screen to a user with no identity attached. Finishing a campaign is the moment they have the most to lose (ADR-0007).
  ///
  /// In en, this message translates to:
  /// **'This record lives on this phone only. Attach an identity and it survives losing it.'**
  String get linkPromptBody;

  /// [niche] Opens the link sheet. 'Attach an identity', never 'sign up' — there has been an account since first launch.
  ///
  /// In en, this message translates to:
  /// **'Attach an identity'**
  String get linkIdentityButton;

  /// [niche] Leaves the completion screen for browse.
  ///
  /// In en, this message translates to:
  /// **'What next'**
  String get whatNextButton;

  /// App bar title of settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label of the single reminder switch (ADR-0011).
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderToggle;

  /// Opens the time picker for the reminder.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get reminderChangeTime;

  /// Subtitle when the reminder is off. States the whole extent of it.
  ///
  /// In en, this message translates to:
  /// **'One notification a day, at a time you choose.'**
  String get reminderOffSubtitle;

  /// Subtitle when the reminder is on.
  ///
  /// In en, this message translates to:
  /// **'One notification a day, at {time}.'**
  String reminderOnAt(String time);

  /// [niche] Why to attach an identity. 'Record' is the product's vocabulary.
  ///
  /// In en, this message translates to:
  /// **'So your record survives losing this phone.'**
  String get linkIdentitySettingsSubtitle;

  /// Settings row that re-queries the store.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// [niche] Contains the product name. Shown when OS permission was denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Feral. Turn them on in your system settings if you want the reminder.'**
  String get notificationsBlockedNotice;

  /// [niche] Title of the daily reminder notification.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reminderNotificationTitle;

  /// [niche] Body of the daily reminder. Never a miss, never a streak, never the balance (ADR-0011).
  ///
  /// In en, this message translates to:
  /// **'Your action is waiting.'**
  String get reminderNotificationBody;

  /// Android notification channel name, shown in system settings.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderChannelName;

  /// [niche] The enclosure's name, on the first onboarding screen. This is the product's central metaphor and every fork replaces it.
  ///
  /// In en, this message translates to:
  /// **'The Zoo'**
  String get doctrineIntroTitle;

  /// [niche] Names the adversary. A fork without a compelling adversary has a weaker product and this string is where that shows.
  ///
  /// In en, this message translates to:
  /// **'Safety, predictability and a single-file path, traded for the ability to choose your own. Nobody forced it on you. That is what makes it hard to see.'**
  String get doctrineIntroBody;

  /// [niche] What the user is about to do. Eight and one-a-day are structural, but the phrasing is the product's.
  ///
  /// In en, this message translates to:
  /// **'Eight questions. Then one thing a day.'**
  String get doctrineIntroPromise;

  /// [niche] Advances onboarding. Plain 'Continue' in most forks; this wording is a voice choice.
  ///
  /// In en, this message translates to:
  /// **'Go on'**
  String get continueButton;

  /// Heading of the privacy notice, shown before the diagnostic.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get privacyNoticeTitle;

  /// [niche] Contains the product name. Explains the silent anonymous account (ADR-0007).
  ///
  /// In en, this message translates to:
  /// **'Feral made you an account when you opened it. You were not asked for anything, and you do not have to give anything.'**
  String get privacyNoticeAccount;

  /// Exhaustive list of what is stored. If this stops being exhaustive it is a defect, not a copy edit.
  ///
  /// In en, this message translates to:
  /// **'It stores what you report each day, a line of note if you write one, and your answers here as four numbers. Nothing else. No location, no contacts, no health data, no tracking.'**
  String get privacyNoticeStored;

  /// States the accepted cost of anonymous-first auth plainly (ADR-0013).
  ///
  /// In en, this message translates to:
  /// **'That account lives on this phone only. If you lose the phone before attaching an identity, the record is gone and nothing can bring it back. You can attach one any time in settings.'**
  String get privacyNoticeLoss;

  /// Dismisses the non-modal sync notice.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dismissNoticeButton;

  /// [niche] Quiet offline indicator on the dashboard. States a fact about the record, never a warning (US28).
  ///
  /// In en, this message translates to:
  /// **'Offline. Your days are being recorded here.'**
  String get syncOfflineNotice;

  /// Shown only after repeated failures. The first clause is the important one: nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved on this phone but has not reached the server yet. It will keep trying.'**
  String get syncFailingNotice;

  /// Label of the email field when linking by one-time code.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressField;

  /// App bar title of the address step.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get emailStepTitle;

  /// App bar title of the six-digit code step.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get codeStepTitle;

  /// Label of the six-digit code field.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeField;

  /// Requests a one-time code by email (ADR-0016).
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// Requests a replacement code.
  ///
  /// In en, this message translates to:
  /// **'Send another code'**
  String get resendCodeButton;

  /// Returns to the email step.
  ///
  /// In en, this message translates to:
  /// **'Use a different address'**
  String get changeEmailButton;

  /// Confirms where the code went. Six-digit is structural — there is no magic link (ADR-0016).
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit code to {email}.'**
  String codeSentTo(String email);

  /// Shown when requesting a code fails. Names the likely cause and the next step, never blames.
  ///
  /// In en, this message translates to:
  /// **'That did not send. Check the address and try again.'**
  String get codeSendFailed;

  /// Acknowledges the privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understoodButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
