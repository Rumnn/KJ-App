import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hiveService.dart';
import '../services/streakService.dart';
import '../models/quizResultModel.dart';
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardData>(() => DashboardNotifier());
class DashboardNotifier extends Notifier<DashboardData> {
  @override
  DashboardData build() {
    _listenToHive();
    return _loadData();
  }
  void _listenToHive() {
    HiveService.quizBox.listenable().addListener(_updateState);
    HiveService.streakBox.listenable().addListener(_updateState);
  }
  void _updateState() {
    state = _loadData();
  }
  DashboardData _loadData() {
    final raw = HiveService.getQuizResults();
    final results = raw.map((r) => QuizResultModel.fromJson(Map<String, dynamic>.from(r))).toList();
    return DashboardData(
      currentStreak: StreakService.currentStreak,
      longestStreak: StreakService.longestStreak,
      studyDates: StreakService.getStudyDates(),
      quizResults: results,
    );
  }
}
class DashboardData {
  final int currentStreak;
  final int longestStreak;
  final List<String> studyDates;
  final List<QuizResultModel> quizResults;
  const DashboardData({
    required this.currentStreak,
    required this.longestStreak,
    required this.studyDates,
    required this.quizResults,
  });
}