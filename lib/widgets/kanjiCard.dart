import 'package:flutter/material.dart';
import '../models/kanjiModel.dart';
import '../appTheme.dart';

class KanjiCard extends StatelessWidget {
  final KanjiModel kanji;
  final Color levelColor;
  final VoidCallback onTap;

  const KanjiCard({
    super.key,
    required this.kanji,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: levelColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kanji.character, 
            style: const TextStyle(
              fontSize: 32, 
              color: AppTheme.onBackground, 
              fontWeight: FontWeight.w600
            )
          ),
          const SizedBox(height: 4),
          Text(
            kanji.primaryMeaning,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
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

  const KanjiListTile({
    super.key,
    required this.kanji,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              kanji.character, 
              style: TextStyle(fontSize: 26, color: levelColor, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kanji.primaryMeaning, 
                  style: const TextStyle(fontSize: 16, color: AppTheme.onBackground, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 2),
                Text(
                  '${kanji.onReadingsText} • ${kanji.kunReadingsText}', 
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineVariant),
        ],
      ),
    ),
  );
}