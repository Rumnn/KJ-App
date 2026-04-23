import 'package:flutter/material.dart';
import '../appTheme.dart';
class FlashcardWidget extends StatefulWidget {
  final String frontText;
  final String backMeaning;
  final String backOnReading;
  final String backKunReading;
  const FlashcardWidget({super.key, required this.frontText, required this.backMeaning, required this.backOnReading, required this.backKunReading});
  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}
class _FlashcardWidgetState extends State<FlashcardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showBack = false;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween<double>(begin: 0.0, end: 3.14159265).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  void _flip() {
    if (_ctrl.isAnimating) return;
    if (_showBack) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _showBack = !_showBack);
  }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _flip,
    child: AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final angle = _anim.value;
        final isBack = angle.abs() > 0.785;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isBack ? AppTheme.accentGlow : AppTheme.border, width: 2),
              boxShadow: const [BoxShadow(color: AppTheme.accentGlow, blurRadius: 24, spreadRadius: 0)],
            ),
            child: isBack
              ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(3.1416),
                child: _BackContent(meaning: widget.backMeaning, onReading: widget.backOnReading, kunReading: widget.backKunReading),
              )
              : _FrontContent(character: widget.frontText),
          ),
        );
      },
    ),
  );
}
class _FrontContent extends StatelessWidget {
  final String character;
  const _FrontContent({required this.character});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ShaderMask(
        shaderCallback: (b) => AppTheme.accentGradient.createShader(b),
        child: Text(character, style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      const SizedBox(height: 16),
      const Text('Tap To Reveal', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
    ],
  );
}
class _BackContent extends StatelessWidget {
  final String meaning;
  final String onReading;
  final String kunReading;
  const _BackContent({required this.meaning, required this.onReading, required this.kunReading});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(meaning, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (onReading.isNotEmpty) _ReadingRow(label: 'On', value: onReading, color: AppTheme.accent),
        if (kunReading.isNotEmpty) _ReadingRow(label: 'Kun', value: kunReading, color: AppTheme.gold),
      ],
    ),
  );
}
class _ReadingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ReadingRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary))),
      ],
    ),
  );
}