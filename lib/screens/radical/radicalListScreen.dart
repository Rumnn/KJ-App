import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../data/kanjiData.dart';
import '../../appTheme.dart';
class RadicalListScreen extends ConsumerWidget {
  const RadicalListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radicals = ref.watch(radicalListProvider);
    final grouped = <int, List<dynamic>>{};
    for (final r in radicals) {
      grouped.putIfAbsent(r.strokes, () => []).add(r);
    }
    final strokeCounts = grouped.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Radicals — 部首')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: strokeCounts.length,
        itemBuilder: (_, i) {
          final strokes = strokeCounts[i];
          final group = grouped[strokes]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('$strokes Stroke${strokes == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: group.map((r) => Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    child: Column(
                      children: [
                        Text(r.character, style: const TextStyle(fontSize: 26, color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text(r.meaning, style: const TextStyle(fontSize: 8, color: AppTheme.textMuted), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )).toList(),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}