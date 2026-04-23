import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:go_router/go_router.dart';
import '../../appTheme.dart';
class WritingPracticeScreen extends StatefulWidget {
  final String character;
  const WritingPracticeScreen({super.key, required this.character});
  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}
class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final _ink = Ink();
  final List<StrokePoint> _points = [];
  final _recognizer = DigitalInkRecognizer(languageCode: 'ja');
  bool _isRecognizing = false;
  String? _result;
  bool _correct = false;
  @override
  void dispose() { _recognizer.close(); super.dispose(); }
  void _clear() {
    setState(() {
      _ink.strokes.clear();
      _points.clear();
      _result = null;
      _correct = false;
    });
  }
  Future<void> _recognize() async {
    if (_ink.strokes.isEmpty) return;
    setState(() { _isRecognizing = true; _result = null; _correct = false; });
    try {
      final modelManager = DigitalInkRecognizerModelManager();
      final isDownloaded = await modelManager.isModelDownloaded('ja');
      if (!isDownloaded) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Japanese Ink Model...', style: TextStyle(color: AppTheme.textPrimary)), backgroundColor: AppTheme.card));
        await modelManager.downloadModel('ja');
      }
      final cands = await _recognizer.recognize(_ink);
      final r = cands.isNotEmpty ? cands.first.text : null;
      setState(() {
        _result = r;
        _correct = r == widget.character;
      });
      if (_correct && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(children: [Icon(Icons.check_circle_rounded, color: AppTheme.success), SizedBox(width: 8), Text('Perfect!')]),
          backgroundColor: AppTheme.card,
        ));
      }
    } catch (_) {}
    if (mounted) setState(() => _isRecognizing = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Writing Practice', style: TextStyle(fontSize: 16)),
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Target Kanji: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              Text(widget.character, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 2)),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      widget.character,
                      style: TextStyle(fontSize: 200, color: AppTheme.textPrimary.withValues(alpha: 0.04)),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SignaturePainter(ink: _ink),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (d) { _ink.strokes.add(Stroke()); _points.clear(); _points.add(StrokePoint(x: d.localPosition.dx, y: d.localPosition.dy, t: DateTime.now().millisecondsSinceEpoch)); _ink.strokes.last.points = _points.toList(); setState(() {}); },
                      onPanUpdate: (d) { _points.add(StrokePoint(x: d.localPosition.dx, y: d.localPosition.dy, t: DateTime.now().millisecondsSinceEpoch)); _ink.strokes.last.points = _points.toList(); setState(() {}); },
                      onPanEnd: (d) { setState(() {}); },
                    ),
                  ),
                  if (_isRecognizing) const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                ],
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _correct ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _correct ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_result!, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: _correct ? AppTheme.success : AppTheme.error)),
                  const SizedBox(width: 16),
                  Icon(_correct ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _correct ? AppTheme.success : AppTheme.error, size: 32),
                ],
              ),
            )
          ] else const SizedBox(height: 114),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ink.strokes.isEmpty ? null : _clear,
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cardHover, foregroundColor: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _ink.strokes.isEmpty || _isRecognizing ? null : _recognize,
                  icon: const Icon(Icons.analytics_rounded, size: 20),
                  label: const Text('Check'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
class SignaturePainter extends CustomPainter {
  Ink ink;
  SignaturePainter({required this.ink});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.textPrimary..strokeCap = StrokeCap.round..strokeWidth = 6.0;
    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
      }
    }
  }
  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}