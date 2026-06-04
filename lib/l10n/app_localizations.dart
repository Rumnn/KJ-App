import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KJ'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @supportInfo.
  ///
  /// In en, this message translates to:
  /// **'Support & Info'**
  String get supportInfo;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safely exit your account'**
  String get signOutSubtitle;

  /// No description provided for @clearLocalProgress.
  ///
  /// In en, this message translates to:
  /// **'Clear Local Progress'**
  String get clearLocalProgress;

  /// No description provided for @clearLocalProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resets streak and local history'**
  String get clearLocalProgressSubtitle;

  /// No description provided for @progressDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Progress data cleared'**
  String get progressDataCleared;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @currentlyVersion.
  ///
  /// In en, this message translates to:
  /// **'Currently v{version}'**
  String currentlyVersion(String version);

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support the developer'**
  String get donateSubtitle;

  /// No description provided for @jlptLearner.
  ///
  /// In en, this message translates to:
  /// **'JLPT Learner'**
  String get jlptLearner;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get notLoggedIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your Kanji journey'**
  String get signInToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Password (Min 6 Chars)'**
  String get passwordMin;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmail;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get minCharacters;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your Kanji learning journey'**
  String get startJourney;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @okaeriUser.
  ///
  /// In en, this message translates to:
  /// **'Okaeri, {name}'**
  String okaeriUser(String name);

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @streakDaysUpper.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get streakDaysUpper;

  /// No description provided for @dailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgress;

  /// No description provided for @dailyProgressUpper.
  ///
  /// In en, this message translates to:
  /// **'DAILY PROGRESS'**
  String get dailyProgressUpper;

  /// No description provided for @kanjiMastered.
  ///
  /// In en, this message translates to:
  /// **'{mastered}/{goal} Kanji Mastered'**
  String kanjiMastered(int mastered, int goal);

  /// No description provided for @continueLearningBadge.
  ///
  /// In en, this message translates to:
  /// **'N5 LEVEL • WEEK 2'**
  String get continueLearningBadge;

  /// No description provided for @essentialVerbs.
  ///
  /// In en, this message translates to:
  /// **'Essential Verbs'**
  String get essentialVerbs;

  /// No description provided for @continueLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focusing on movement and direction radicals today.'**
  String get continueLearningSubtitle;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @communityRankings.
  ///
  /// In en, this message translates to:
  /// **'Community Rankings'**
  String get communityRankings;

  /// No description provided for @quizComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Quiz Screen Coming Soon'**
  String get quizComingSoon;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile Screen Coming Soon'**
  String get profileComingSoon;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @quizPerformance.
  ///
  /// In en, this message translates to:
  /// **'Quiz Performance'**
  String get quizPerformance;

  /// No description provided for @totalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'{count} Total Quizzes'**
  String totalQuizzes(int count);

  /// No description provided for @recentStudyDays.
  ///
  /// In en, this message translates to:
  /// **'Recent Study Days'**
  String get recentStudyDays;

  /// No description provided for @noStudyDays.
  ///
  /// In en, this message translates to:
  /// **'No study days yet. Start studying!'**
  String get noStudyDays;

  /// No description provided for @globalRankings.
  ///
  /// In en, this message translates to:
  /// **'Global Rankings'**
  String get globalRankings;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsShort;

  /// No description provided for @lessonsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a skill and level that fits your study session.'**
  String get lessonsSubtitle;

  /// No description provided for @jlptKanji.
  ///
  /// In en, this message translates to:
  /// **'JLPT Kanji'**
  String get jlptKanji;

  /// No description provided for @grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammar;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabulary;

  /// No description provided for @radicals.
  ///
  /// In en, this message translates to:
  /// **'Radicals'**
  String get radicals;

  /// No description provided for @kanjiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Study kanji by JLPT level.'**
  String get kanjiSubtitle;

  /// No description provided for @grammarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice patterns with quizzes and flashcards.'**
  String get grammarSubtitle;

  /// No description provided for @vocabularySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build words with quiz, flashcards, and matching.'**
  String get vocabularySubtitle;

  /// No description provided for @radicalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse radicals grouped by stroke count.'**
  String get radicalsSubtitle;

  /// No description provided for @levelStudy.
  ///
  /// In en, this message translates to:
  /// **'{level} Level Study'**
  String levelStudy(String level);

  /// No description provided for @essentialKanji.
  ///
  /// In en, this message translates to:
  /// **'{count} Essential Kanji'**
  String essentialKanji(int count);

  /// No description provided for @grammarPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} Grammar Points'**
  String grammarPoints(int count);

  /// No description provided for @vocabularyWords.
  ///
  /// In en, this message translates to:
  /// **'{count} Vocabulary Words'**
  String vocabularyWords(int count);

  /// No description provided for @grammarPractice.
  ///
  /// In en, this message translates to:
  /// **'Grammar Practice'**
  String get grammarPractice;

  /// No description provided for @grammarPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz and flashcards for N5, N4, N3'**
  String get grammarPracticeSubtitle;

  /// No description provided for @vocabularyPractice.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Practice'**
  String get vocabularyPractice;

  /// No description provided for @vocabularyPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz, flashcards, and matching game'**
  String get vocabularyPracticeSubtitle;

  /// No description provided for @strokeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Stroke'**
  String strokeCount(int count);

  /// No description provided for @strokeCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} Strokes'**
  String strokeCountPlural(int count);

  /// No description provided for @adminOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get adminOverview;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminQuizResults.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get adminQuizResults;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteQuizResult.
  ///
  /// In en, this message translates to:
  /// **'Delete Quiz Result'**
  String get deleteQuizResult;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete this user and all quiz results?'**
  String get confirmDeleteUser;

  /// No description provided for @confirmDeleteQuizResult.
  ///
  /// In en, this message translates to:
  /// **'Delete this quiz result?'**
  String get confirmDeleteQuizResult;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
