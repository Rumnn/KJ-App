import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/quizResultModel.dart';
import '../appTheme.dart';
class StreakChart extends StatelessWidget {
  final List<QuizResultModel> results;
  const StreakChart({super.key, required this.results});
  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const Center(child: Text('No Quiz Data Yet!', style: TextStyle(color: AppTheme.textMuted)));
    final recent = results.length > 10 ? results.sublist(results.length - 10) : results;
    final spots = List.generate(recent.length, (i) => FlSpot(i.toDouble(), recent[i].percentage * 100));
    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 25,
              getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= recent.length) return const SizedBox();
                final d = recent[idx].date;
                return Text('${d.month}/${d.day}', style: const TextStyle(fontSize: 9, color: AppTheme.textMuted));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (recent.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentLight]),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: AppTheme.accentLight, strokeWidth: 2, strokeColor: AppTheme.background),
            ),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppTheme.accent.withValues(alpha: 0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }
}