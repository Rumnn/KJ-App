import '../services/hiveService.dart';
class StreakService {
  StreakService._();
  static const String _lastStudyKey = 'lastStudyDate';
  static const String _currentStreakKey = 'currentStreak';
  static const String _longestStreakKey = 'longestStreak';
  static int get currentStreak => HiveService.streakBox.get(_currentStreakKey, defaultValue: 0) as int;
  static int get longestStreak => HiveService.streakBox.get(_longestStreakKey, defaultValue: 0) as int;
  static String? get lastStudyDate => HiveService.streakBox.get(_lastStudyKey) as String?;
  static Future<void> recordStudySession() async {
    final today = _dateStr(DateTime.now());
    final last = lastStudyDate;
    if (last == today) return;
    final yesterday = _dateStr(DateTime.now().subtract(const Duration(days: 1)));
    int streak = currentStreak;
    if (last == yesterday) {
      streak += 1;
    } else {
      streak = 1;
    }
    await HiveService.streakBox.put(_lastStudyKey, today);
    await HiveService.streakBox.put(_currentStreakKey, streak);
    if (streak > longestStreak) {
      await HiveService.streakBox.put(_longestStreakKey, streak);
    }
  }
  static String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static List<String> getStudyDates() {
    final results = HiveService.getQuizResults();
    return results.map((r) => (r['date'] as String).substring(0, 10)).toSet().toList()..sort();
  }
  static Future<void> recalculateStreaksFromHistory() async {
    final dates = getStudyDates();
    if (dates.isEmpty) {
      await HiveService.streakBox.clear();
      return;
    }
    int streak = 1;
    int longest = 1;
    for (int i = 1; i < dates.length; i++) {
      final prevDate = DateTime.parse('${dates[i - 1]}T00:00:00Z');
      final currDate = DateTime.parse('${dates[i]}T00:00:00Z');
      if (currDate.difference(prevDate).inDays == 1) {
        streak++;
      } else {
        streak = 1;
      }
      if (streak > longest) longest = streak;
    }
    await HiveService.streakBox.put(_lastStudyKey, dates.last);
    await HiveService.streakBox.put(_currentStreakKey, streak);
    await HiveService.streakBox.put(_longestStreakKey, longest);
  }
}