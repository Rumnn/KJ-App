import 'package:flutter/material.dart';
import '../appTheme.dart';

class KanjiGridCard extends StatelessWidget {
  final String character;
  final String romaji;
  final String meaning;
  final VoidCallback? onTap;

  const KanjiGridCard({
    super.key,
    required this.character,
    required this.romaji,
    required this.meaning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              character,
              style: const TextStyle(
                fontSize: 48,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              romaji,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              meaning,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
