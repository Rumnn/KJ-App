// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KJ';

  @override
  String get home => 'Home';

  @override
  String get lessons => 'Lessons';

  @override
  String get quiz => 'Quiz';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get supportInfo => 'Support & Info';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutSubtitle => 'Safely exit your account';

  @override
  String get clearLocalProgress => 'Clear Local Progress';

  @override
  String get clearLocalProgressSubtitle => 'Resets streak and local history';

  @override
  String get progressDataCleared => 'Progress data cleared';

  @override
  String get appVersion => 'App Version';

  @override
  String currentlyVersion(String version) {
    return 'Currently v$version';
  }

  @override
  String get donate => 'Donate';

  @override
  String get donateSubtitle => 'Support the developer';

  @override
  String get jlptLearner => 'JLPT Learner';

  @override
  String get notLoggedIn => 'Not Logged In';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue your Kanji journey';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'Password (Min 6 Chars)';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get minCharacters => 'Min 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get startJourney => 'Start your Kanji learning journey';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get defaultUser => 'User';

  @override
  String okaeriUser(String name) {
    return 'Okaeri, $name';
  }

  @override
  String get keepItUp => 'Keep it up!';

  @override
  String get streakDaysUpper => 'DAYS';

  @override
  String get dailyProgress => 'Daily Progress';

  @override
  String get dailyProgressUpper => 'DAILY PROGRESS';

  @override
  String kanjiMastered(int mastered, int goal) {
    return '$mastered/$goal Kanji Mastered';
  }

  @override
  String get continueLearningBadge => 'N5 LEVEL • WEEK 2';

  @override
  String get essentialVerbs => 'Essential Verbs';

  @override
  String get continueLearningSubtitle =>
      'Focusing on movement and direction radicals today.';

  @override
  String get continueText => 'Continue';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get viewAll => 'View All';

  @override
  String get communityRankings => 'Community Rankings';

  @override
  String get quizComingSoon => 'Quiz Screen Coming Soon';

  @override
  String get profileComingSoon => 'Profile Screen Coming Soon';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get days => 'Days';

  @override
  String get quizPerformance => 'Quiz Performance';

  @override
  String totalQuizzes(int count) {
    return '$count Total Quizzes';
  }

  @override
  String get recentStudyDays => 'Recent Study Days';

  @override
  String get noStudyDays => 'No study days yet. Start studying!';

  @override
  String get globalRankings => 'Global Rankings';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get pointsShort => 'pts';

  @override
  String get lessonsSubtitle =>
      'Choose a skill and level that fits your study session.';

  @override
  String get jlptKanji => 'JLPT Kanji';

  @override
  String get grammar => 'Grammar';

  @override
  String get vocabulary => 'Vocabulary';

  @override
  String get radicals => 'Radicals';

  @override
  String get kanjiSubtitle => 'Study kanji by JLPT level.';

  @override
  String get grammarSubtitle =>
      'Practice patterns with quizzes and flashcards.';

  @override
  String get vocabularySubtitle =>
      'Build words with quiz, flashcards, and matching.';

  @override
  String get radicalsSubtitle => 'Browse radicals grouped by stroke count.';

  @override
  String levelStudy(String level) {
    return '$level Level Study';
  }

  @override
  String essentialKanji(int count) {
    return '$count Essential Kanji';
  }

  @override
  String grammarPoints(int count) {
    return '$count Grammar Points';
  }

  @override
  String vocabularyWords(int count) {
    return '$count Vocabulary Words';
  }

  @override
  String get grammarPractice => 'Grammar Practice';

  @override
  String get grammarPracticeSubtitle => 'Quiz and flashcards for N5, N4, N3';

  @override
  String get vocabularyPractice => 'Vocabulary Practice';

  @override
  String get vocabularyPracticeSubtitle =>
      'Quiz, flashcards, and matching game';

  @override
  String strokeCount(int count) {
    return '$count Stroke';
  }

  @override
  String strokeCountPlural(int count) {
    return '$count Strokes';
  }

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminQuizResults => 'Quiz Results';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get activeUsers => 'Active Users';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get totalXp => 'Total XP';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get searchUsers => 'Search users';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get blocked => 'Blocked';

  @override
  String get user => 'User';

  @override
  String get admin => 'Admin';

  @override
  String get role => 'Role';

  @override
  String get status => 'Status';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get deleteQuizResult => 'Delete Quiz Result';

  @override
  String get confirmDeleteUser => 'Delete this user and all quiz results?';

  @override
  String get confirmDeleteQuizResult => 'Delete this quiz result?';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';
}
