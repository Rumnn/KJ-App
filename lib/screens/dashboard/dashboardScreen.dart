import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../providers/dashboardProvider.dart';
import '../../widgets/streakChart.dart';
import '../../appTheme.dart';
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _StreakCard(title: 'Current Streak', value: data.currentStreak.toString(), icon: Icons.local_fire_department_rounded, color: AppTheme.accent)),
                const SizedBox(width: 16),
                Expanded(child: _StreakCard(title: 'Longest Streak', value: data.longestStreak.toString(), icon: Icons.emoji_events_rounded, color: AppTheme.gold)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quiz Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text('${data.quizResults.length} Total Quizzes', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
              child: StreakChart(results: data.quizResults),
            ),
            const SizedBox(height: 32),
            const Text('Recent Study Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            if (data.studyDates.isEmpty)
              const Center(child: Text('No Study Days Yet! Start Studying!', style: TextStyle(color: AppTheme.textMuted)))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.studyDates.reversed.take(14).map((d) {
                  final ds = DateTime.parse(d);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
                    child: Text('${ds.month}/${ds.day}', style: const TextStyle(color: AppTheme.accentLight, fontSize: 13, fontWeight: FontWeight.w500)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
class _StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StreakCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Container(decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: Text('Days', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}