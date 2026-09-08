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
