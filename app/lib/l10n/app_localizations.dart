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

  /// [niche] Screen-reader label for the Commit control when the day has no mandatory action to accept. With the actions hidden before the commit, a disabled button with no reason is a dead end — this carries the reason and the reassurance together, in contentUnavailable's register. German compounds are the length stress case (ADR-0022).
  ///
  /// In en, this message translates to:
  /// **'Commit. Unavailable until today\'s content arrives. Your run is safe.'**
  String get commitUnavailable;

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

  /// Status reading on the core (free) pack in the browse list — it costs nothing and never did.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get includedLabel;

  /// Status reading on a paid pack the user has already unlocked, in the browse list. Same size and weight as the price it replaces (design principle 10) — no celebration colour, just the fact.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get ownedLabel;

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

  /// Opens the sign-in sheet from the first onboarding screen, so a returning user is not made to answer the diagnostic a second time. Secondary to the continue button: an offer, never a gate (ADR-0007).
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccountButton;

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

  /// Shown on the code step when six digits are refused. Covers wrong, expired, and used-up in one sentence, because the server does not say which and guessing would be worse than not saying.
  ///
  /// In en, this message translates to:
  /// **'That code is not right, or it has expired. Ask for a new one.'**
  String get codeRejected;

  /// Shown when attaching an identity fails for any reason other than the address being taken. The second clause is the part that matters: a failed link is not a lost record.
  ///
  /// In en, this message translates to:
  /// **'That did not work, and nothing on this phone changed.'**
  String get linkFailed;

  /// Names the account in the replace confirmation when signing in with Apple, where no address is known to show instead.
  ///
  /// In en, this message translates to:
  /// **'your Apple ID'**
  String get appleAccountName;

  /// Names the account in the replace confirmation when signing in with Google, where no address is known to show instead.
  ///
  /// In en, this message translates to:
  /// **'your Google account'**
  String get googleAccountName;

  /// [niche] Title of the identity-link sheet. 'Record' is the product's vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Keep this record'**
  String get linkSheetTitle;

  /// [niche] Says what is at stake, once, and never again (ADR-0013).
  ///
  /// In en, this message translates to:
  /// **'Right now everything you have done lives only on this phone. Attaching an account keeps it, and lets you pick it up on another device.'**
  String get linkSheetBody;

  /// [niche] Title of the same sheet when it is opened by a returning user from the start screen, where there is no local record to keep.
  ///
  /// In en, this message translates to:
  /// **'Pick it up here'**
  String get signInSheetTitle;

  /// [niche] The sign-in counterpart of linkSheetBody. Must say the diagnostic does not have to be answered again: that is the whole reason this entry point exists (ADR-0024).
  ///
  /// In en, this message translates to:
  /// **'Your record lives on the account, not on this phone. Sign in and it comes back — campaigns, history, and the questions you have already answered.'**
  String get signInSheetBody;

  /// Dismisses the link prompt. Dismissal is remembered and never asked again.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowButton;

  /// Starts the Sign in with Apple flow. Required alongside any social login (App Store guideline 4.8).
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Starts the Google sign-in flow.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Starts the six-digit code flow.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// App bar title of the replace-confirmation screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// [niche] LOAD-BEARING. Heading of the replace confirmation — the only screen standing between linking and signing in (ADR-0014). Must name what is on THIS phone.
  ///
  /// In en, this message translates to:
  /// **'This phone has its own record'**
  String get replaceHeadline;

  /// [niche] Fallback when the local run has no campaign title.
  ///
  /// In en, this message translates to:
  /// **'There is progress recorded on this phone.'**
  String get replaceSummaryUntitled;

  /// [niche] Names concretely what signing in would replace.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" — {reported} of {total} days reported.'**
  String replaceSummary(String title, int reported, int total);

  /// [niche] LOAD-BEARING. Every word matters: it must say plainly that this does not come back. Reword only with that in view.
  ///
  /// In en, this message translates to:
  /// **'Signing in as {account} replaces it with the record from that account. What is on this phone cannot be recovered afterwards.'**
  String replaceWarning(String account);

  /// [niche] Cancels the replace. Cancel is the default in all three destructive flows.
  ///
  /// In en, this message translates to:
  /// **'Keep this record'**
  String get keepThisRecordButton;

  /// [niche] Confirms the destructive replace.
  ///
  /// In en, this message translates to:
  /// **'Replace with my account'**
  String get replaceWithAccountButton;

  /// Settings section heading, above the identity and restore rows.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// Settings section heading, above account deletion.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySection;

  /// Settings row title once an identity is attached.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedInRow;

  /// Settings row and screen title.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// [niche] Names the product's nouns; states that it is not deferred.
  ///
  /// In en, this message translates to:
  /// **'Removes every run, day, and note. Immediate.'**
  String get deleteAccountSettingsSubtitle;

  /// Heading of the delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'This removes everything'**
  String get deleteHeadline;

  /// [niche] LOAD-BEARING. Exhaustive scope of the deletion (ADR-0015). If it stops being exhaustive that is a defect, not a copy edit.
  ///
  /// In en, this message translates to:
  /// **'Every run, every day you reported, every note you wrote, and your diagnostic result. It happens immediately and cannot be undone.'**
  String get deleteScopeNotice;

  /// Must not imply purchases are deleted or refunded.
  ///
  /// In en, this message translates to:
  /// **'Purchases are held by the App Store or Google Play and are not part of this. Deleting your account does not refund a purchase.'**
  String get deletePurchasesNotice;

  /// Shown only for unlinked accounts.
  ///
  /// In en, this message translates to:
  /// **'This account has no identity attached, so deleting the app from this phone achieves the same thing.'**
  String get deleteAnonymousNotice;

  /// Cancels the deletion. The default.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get keepMyAccountButton;

  /// Confirms the deletion, after the typed word.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverythingButton;

  /// Shown when the delete call fails. The second sentence is the important one — nothing was wiped locally.
  ///
  /// In en, this message translates to:
  /// **'That did not go through. Nothing has been deleted. Check your connection and try again.'**
  String get deleteFailedNotice;

  /// Instruction above the typed-confirmation field.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm.'**
  String deleteConfirmInstruction(String word);

  /// Acknowledges the privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understoodButton;

  /// Tooltip on the unlock sheet's close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// Introduces the list of campaigns in a pack.
  ///
  /// In en, this message translates to:
  /// **'Inside'**
  String get packContentsLead;

  /// Buy button while the store is working. A second tap would be a second charge.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get workingButton;

  /// Restore, offered in the sheet. 'I already bought this' is a thought people have in front of a buy button, not in settings (US26).
  ///
  /// In en, this message translates to:
  /// **'Already bought it'**
  String get alreadyBoughtButton;

  /// Settings subtitle for restore purchases.
  ///
  /// In en, this message translates to:
  /// **'For a new phone, or after reinstalling'**
  String get restorePurchasesSubtitle;

  /// ADR-0008's promise, made where the money is asked for. Note what is absent and must stay absent: no urgency, no discount, no 'most popular'.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. Yours after that.'**
  String get oneTimePurchaseNote;

  /// Shown after a purchase succeeds while the pack's content is being fetched.
  ///
  /// In en, this message translates to:
  /// **'Setting up your pack'**
  String get deliveringPackTitle;

  /// Body text under deliveringPackTitle. Must not suggest the payment failed.
  ///
  /// In en, this message translates to:
  /// **'Your purchase went through. We\'re fetching the pack now — this usually takes a few seconds.'**
  String get deliveringPackBody;

  /// Shown when delivery does not complete. Must reassure that the purchase itself succeeded.
  ///
  /// In en, this message translates to:
  /// **'Your purchase went through, but the pack hasn\'t arrived yet. It\'ll finish next time you open the app, or you can try again now.'**
  String get deliveryTimedOut;

  /// A real purchase awaiting parental or bank approval. Must prevent a second attempt.
  ///
  /// In en, this message translates to:
  /// **'The store is still waiting on this purchase. It unlocks by itself once it goes through — you do not need to buy it again.'**
  String get purchasePendingNote;

  /// Not reachable from the UI; refused in the controller anyway.
  ///
  /// In en, this message translates to:
  /// **'This pack is free.'**
  String get purchaseErrorFreePack;

  /// No store product id, or the store does not know it.
  ///
  /// In en, this message translates to:
  /// **'This pack is not available from the store right now.'**
  String get purchaseErrorUnavailable;

  /// Shown to someone who has paid. Must never read as a refusal of what they own.
  ///
  /// In en, this message translates to:
  /// **'You already own this. Restoring it did not work — try again.'**
  String get purchaseErrorRestoreOwned;

  /// A restore that succeeded and found no purchases.
  ///
  /// In en, this message translates to:
  /// **'There was nothing to restore.'**
  String get restoreNothingFound;

  /// A restore that failed to reach the store at all.
  ///
  /// In en, this message translates to:
  /// **'The store could not be reached. Try again.'**
  String get restoreUnreachable;

  /// Result of a restore that unlocked something. A real plural, not one string with a number in it — the same rule missesAllowed follows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 pack.} other{Restored {count} packs.}}'**
  String restoredPacks(int count);

  /// Heading of the state shown between a successful sign-in and that account's record arriving. Names what is being waited for, because the user is waiting for something of theirs — never a bare spinner.
  ///
  /// In en, this message translates to:
  /// **'Getting your record'**
  String get restoringRecordTitle;

  /// Body of the restoring state. Says the sign-in worked, so the wait does not read as a failure.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Bringing this account\'s campaigns and history onto this phone.'**
  String get restoringRecordBody;

  /// Shown when the pull after signing in fails. It must say the record still exists: this is the moment a user most fears having lost it.
  ///
  /// In en, this message translates to:
  /// **'Your record is safe, but it could not be reached just now. Check your connection and try again.'**
  String get restoringRecordFailed;

  /// Retries the pull on the restoring state.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainButton;

  /// [niche] The screen-reader description of the archetype radar. Names the distribution in coarse bands and then the permanent marks. The figure itself carries no text, so this sentence is the whole reading.
  ///
  /// In en, this message translates to:
  /// **'Recent activity — {distribution}. {marks}'**
  String radarSummary(String distribution, String marks);

  /// [niche] The screen-reader description of the radar before the user has acted at all. Calm, not an error: the four axes are always there, and nothing has been recorded on them yet.
  ///
  /// In en, this message translates to:
  /// **'Recent-activity radar. Nothing recorded yet.'**
  String get radarSummaryEmpty;

  /// One axis inside the radar's screen-reader description: an archetype name followed by its coarse band word. Separated from the next by radarListSeparator.
  ///
  /// In en, this message translates to:
  /// **'{name} {band}'**
  String radarAxisBand(String name, String band);

  /// Joins the per-axis phrases inside the radar's screen-reader description. A locale that does not separate list items with a comma and a space changes it here.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get radarListSeparator;

  /// [niche] Coarse band for a radar axis the user has not acted in recently. Deliberately 'none' and not 'zero' or 'empty': it describes the reading, it does not score it.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get radarBandNone;

  /// [niche] Coarse band for a radar axis below one third of the highest. A plain instrument reading, never a warning.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get radarBandLow;

  /// [niche] Coarse band for a radar axis between one third and two thirds of the highest.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get radarBandMedium;

  /// [niche] Coarse band for a radar axis at or above two thirds of the highest. Not praise: the radar answers which drive is low, and 'high' is the other end of the same scale.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get radarBandHigh;

  /// One archetype's permanent mark count inside the radar's screen-reader description, for example 'Psycho 2'.
  ///
  /// In en, this message translates to:
  /// **'{name} {count}'**
  String radarMarkEntry(String name, int count);

  /// [niche] The marks clause of the radar's screen-reader description. Marks never decay (ADR-0010), and stating them beside a falling distribution is what keeps the reading from sounding like erasure.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No marks yet.} other{Marks: {details}.}}'**
  String radarMarks(int count, String details);

  /// [niche] The single control that resolves the day. The outcome is derived from what was ticked, never chosen, so skipped has no button of its own (principle 10).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportButton;

  /// What an action is worth. A reading, never a score with a target beside it (ADR-0029). Pluralised so screen readers announce it as a count rather than a bare numeral.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{1 point} other{{points} points}}'**
  String actionPoints(int points);

  /// Label for the day's earned points, shown beside the action list as a panel reading. Deliberately not 'Progress' or 'Score': it names a span of time, not an achievement.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayPointsTotal;

  /// Label for points earned so far in the current run. Never compared to a target or a previous run.
  ///
  /// In en, this message translates to:
  /// **'This campaign'**
  String get runPointsTotal;

  /// [niche] Label for every point ever earned, shown beside the permanent archetype marks. Undecayed by design — it is the record that does not fall when the radar does (ADR-0010, ADR-0029).
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTimePointsTotal;

  /// [niche] Marks an action as not required for the day to count as done. Must not read as lesser or as outstanding work — nothing rewards reaching for one beyond the act itself.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalAction;

  /// [niche] Label on the collapsed panel that reopens the day's body copy once the day is committed. Names what the row holds, so the day title beside it is not mistaken for an action title. German compounds are the length stress case (ADR-0022) — the row wraps, it never truncates.
  ///
  /// In en, this message translates to:
  /// **'Today\'s framing'**
  String get dayFraming;

  /// Screen-reader description of the day-framing disclosure row: the day title, what the row is, and whether the body is currently shown. Mirrors actionSemanticMandatory's shape so the only audible difference is the part that matters.
  ///
  /// In en, this message translates to:
  /// **'{title}. Today\'s framing. {state}'**
  String dayFramingSemantic(String title, String state);

  /// Screen-reader state of the day-framing row when the body is expanded. Expanded and collapsed are announced in words, never left to the chevron alone.
  ///
  /// In en, this message translates to:
  /// **'Shown.'**
  String get dayFramingStateShown;

  /// [niche] Screen-reader state of the day-framing row when the body is collapsed. Flat and unpressured — a collapsed body is a reference put away, not something outstanding.
  ///
  /// In en, this message translates to:
  /// **'Hidden.'**
  String get dayFramingStateHidden;

  /// [niche] Shown in the report sheet before confirming, so the user sees what is about to be recorded. The outcome is derived from the ticks, not chosen. Announced to screen readers before Report is activated.
  ///
  /// In en, this message translates to:
  /// **'This records: {outcome}'**
  String willRecord(String outcome);

  /// Screen-reader description of the day's mandatory action row: what it is, that it is the one the grade depends on, its points, and whether it is ticked.
  ///
  /// In en, this message translates to:
  /// **'{title}. Required. Worth {points}. {state}'**
  String actionSemanticMandatory(String title, String points, String state);

  /// Screen-reader description of an optional action row. Mirrors the mandatory one so the only audible difference is the word that matters.
  ///
  /// In en, this message translates to:
  /// **'{title}. Optional. Worth {points}. {state}'**
  String actionSemanticOptional(String title, String points, String state);

  /// [niche] Screen-reader state of a ticked action. Ticked state is never encoded by colour alone, and this is the text half of that pairing.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get actionStateDone;

  /// [niche] Screen-reader state of an unticked action. Flat and unpressured: an unticked row is not outstanding work.
  ///
  /// In en, this message translates to:
  /// **'Not done.'**
  String get actionStateNotDone;
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
