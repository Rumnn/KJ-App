import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();
  static const String apiBaseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  static const String appName = 'KJ';
  static const String appVersion = '1.0.0';
  static const String hiveBoxStreak = 'streakBox';
  static const String hiveBoxQuiz = 'quizBox';
  static const String hiveBoxPrefs = 'prefsBox';
  static const String donateUrl = '#####';
}