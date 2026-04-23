import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/writing/writingPracticeScreen.dart';
import 'screens/onboarding/onboardingScreen.dart';
import 'screens/radical/radicalListScreen.dart';
import 'screens/flashcard/flashcardScreen.dart';
import 'screens/dashboard/dashboardScreen.dart';
import 'screens/settings/settingsScreen.dart';
import 'screens/kanji/kanjiDetailScreen.dart';
import 'screens/kanji/kanjiListScreen.dart';
import 'screens/auth/signUpScreen.dart';
import 'screens/auth/loginScreen.dart';
import 'screens/home/homeScreen.dart';
import 'screens/quiz/quizScreen.dart';
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      final onOnboarding = state.matchedLocation == '/onboarding';
      final onAuth = state.matchedLocation.startsWith('/auth');
      if (!seenOnboarding) return '/onboarding';
      if (token == null && !onAuth) return '/auth/login';
      if (token != null && (onOnboarding || onAuth)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'kanji/:level',
            builder: (_, state) => KanjiListScreen(level: state.pathParameters['level']!),
            routes: [
              GoRoute(
                path: 'detail/:character',
                builder: (_, state) => KanjiDetailScreen(character: state.pathParameters['character']!),
              ),
            ],
          ),
          GoRoute(path: 'radicals', builder: (_, __) => const RadicalListScreen()),
          GoRoute(path: 'quiz', builder: (_, state) => QuizScreen(level: state.uri.queryParameters['level'])),
          GoRoute(path: 'flashcard', builder: (_, state) => FlashcardScreen(level: state.uri.queryParameters['level'])),
          GoRoute(path: 'writing/:character', builder: (_, state) => WritingPracticeScreen(character: state.pathParameters['character']!)),
          GoRoute(path: 'dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => const Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      body: Center(child: Text('Page Not Found!', style: TextStyle(color: Colors.white))),
    ),
  );
});