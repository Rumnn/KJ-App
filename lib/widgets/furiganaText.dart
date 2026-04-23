import 'package:flutter/material.dart';
import '../appTheme.dart';
class _FuriganaText extends StatelessWidget {
  final String reading;
  final String text;
  const _FuriganaText({required this.reading, required this.text});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(reading, style: const TextStyle(fontSize: 10, color: AppTheme.accentLight, height: 1.2)),
      Text(text, style: const TextStyle(fontSize: 18, color: AppTheme.textPrimary, fontWeight: FontWeight.w500, height: 1.2)),
    ],
  );
}
class FuriganaRow extends StatelessWidget {
  final String word;
  final String reading;
  final List<String> meanings;
  final String romanji;
  const FuriganaRow({super.key, required this.word, required this.reading, required this.meanings, this.romanji = ''});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _FuriganaText(reading: reading, text: word),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(meanings.join(', '), style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            if (romanji.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(romanji, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
            ]
          ],
        ),
      ),
    ],
  );
}