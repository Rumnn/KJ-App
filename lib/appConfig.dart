import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();
  // Web: localhost, Android Emulator: 10.0.2.2, Physical Device: LAN IP of your PC
  static const String _localIp = '10.2.198.213'; // IP LAN của máy tính
  static const String apiBaseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://$_localIp:3000';
  static const String appName = 'KJ';
  static const String appVersion = '1.0.0';
  static const String hiveBoxStreak = 'streakBox';
  static const String hiveBoxQuiz = 'quizBox';
  static const String hiveBoxPrefs = 'prefsBox';
  static const String donateUrl = '#####';
}