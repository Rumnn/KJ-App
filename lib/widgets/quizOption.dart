import 'package:flutter/material.dart';
import '../appTheme.dart';
class QuizOption extends StatelessWidget {
  final String text;
  final QuizOptionState optionState;
  final VoidCallback onTap;
  const QuizOption({super.key, required this.text, required this.optionState, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = _colors(optionState);
    return GestureDetector(
      onTap: optionState == QuizOptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: colors.$1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.$2, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.$3))),
            if (optionState == QuizOptionState.correct) const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
            if (optionState == QuizOptionState.wrong) const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 22),
          ],
        ),
      ),
    );
  }
  (Color, Color, Color) _colors(QuizOptionState s) => switch (s) {
    QuizOptionState.correct => (AppTheme.success.withValues(alpha: 0.15), AppTheme.success, AppTheme.success),
    QuizOptionState.wrong => (AppTheme.error.withValues(alpha: 0.15), AppTheme.error, AppTheme.error),
    QuizOptionState.idle => (AppTheme.card, AppTheme.border, AppTheme.textPrimary),
  };
}
enum QuizOptionState { idle, correct, wrong }