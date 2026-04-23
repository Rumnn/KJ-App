import 'package:flutter/material.dart';
import '../models/kanjiModel.dart';
import '../appTheme.dart';
class KanjiCard extends StatelessWidget {
  final KanjiModel kanji;
  final Color levelColor;
  final VoidCallback onTap;
  const KanjiCard({super.key, required this.kanji, required this.levelColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: levelColor, shape: BoxShape.circle),
          ),
          Text(kanji.character, style: const TextStyle(fontSize: 32, color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            kanji.primaryMeaning,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
class KanjiListTile extends StatelessWidget {
  final KanjiModel kanji;
  final Color levelColor;
  final VoidCallback onTap;
  const KanjiListTile({super.key, required this.kanji, required this.levelColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: levelColor.withValues(alpha: 0.3)),
            ),
            child: Text(kanji.character, style: const TextStyle(fontSize: 28, color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kanji.primaryMeaning, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${kanji.onReadingsText} • ${kanji.kunReadingsText}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text('${kanji.strokeCount}画', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
        ],
      ),
    ),
  );
}