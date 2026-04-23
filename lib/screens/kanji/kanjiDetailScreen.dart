import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../widgets/furiganaText.dart';
import '../../models/kanjiModel.dart';
import '../../data/kanjiData.dart';
import '../../appTheme.dart';
class KanjiDetailScreen extends ConsumerWidget {
  final String character;
  const KanjiDetailScreen({super.key, required this.character});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(kanjiDataProvider);
    return allAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.accent))),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error)))),
      data: (data) {
        KanjiModel? kanji;
        for (final list in data.values) {
          kanji = list.cast<KanjiModel?>().firstWhere((k) => k?.character == character, orElse: () => null);
          if (kanji != null) break;
        }
        if (kanji == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Kanji Not Found', style: TextStyle(color: AppTheme.textSecondary))));
        final levelIdx = ['N5', 'N4', 'N3', 'N2', 'N1'].indexOf(kanji.jlpt);
        final color = levelIdx >= 0 ? AppTheme.jlptColors[levelIdx] : AppTheme.accent;
        return _DetailBody(kanji: kanji, levelColor: color);
      },
    );
  }
}
class _DetailBody extends StatefulWidget {
  final KanjiModel kanji;
  final Color levelColor;
  const _DetailBody({required this.kanji, required this.levelColor});
  @override
  State<_DetailBody> createState() => _DetailBodyState();
}
class _DetailBodyState extends State<_DetailBody> with TickerProviderStateMixin {
  StrokeOrderAnimationController? _strokeCtrl;
  String _errorMsg = '';
  @override
  void initState() {
    super.initState();
    _loadStrokeOrder();
  }
  Future<void> _loadStrokeOrder() async {
    setState(() => _errorMsg = '');
    try {
      final jsonStr = await downloadStrokeOrder(widget.kanji.character, http.Client());
      final ctrl = StrokeOrderAnimationController(
        StrokeOrder(jsonStr),
        this,
        strokeColor: AppTheme.textPrimary,
        outlineColor: AppTheme.border,
        hintColor: AppTheme.accent,
        onQuizCompleteCallback: (_) {},
      );
      if (mounted) setState(() => _strokeCtrl = ctrl);
    } catch (e) {
      if (mounted) setState(() => _errorMsg = 'No Stroke Data!');
      debugPrint('StrokeOrder Error: $e');
    }
  }
  @override
  void dispose() {
    _strokeCtrl?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: widget.levelColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(widget.kanji.jlpt, style: TextStyle(color: widget.levelColor, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [widget.levelColor.withValues(alpha: 0.15), Colors.transparent]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(widget.kanji.character, style: const TextStyle(fontSize: 80, color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(widget.kanji.meanings.join(', '), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), textAlign: TextAlign.center)),
          const SizedBox(height: 24),
          _SectionCard(children: [
            _InfoRow(label: 'On', value: widget.kanji.onReadingsText.isEmpty ? '—' : widget.kanji.onReadingsText, color: AppTheme.accent),
            const Divider(color: AppTheme.border, height: 16),
            _InfoRow(label: 'Kun', value: widget.kanji.kunReadingsText.isEmpty ? '—' : widget.kanji.kunReadingsText, color: AppTheme.gold),
            const Divider(color: AppTheme.border, height: 16),
            _InfoRow(label: 'Strokes', value: '${widget.kanji.strokeCount}', color: AppTheme.textSecondary),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Stroke Order'),
          const SizedBox(height: 12),
          Container(
            height: 250,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            child: _strokeCtrl != null
               ? StrokeOrderAnimator(_strokeCtrl!, size: const Size(200, 200))
               : _errorMsg.isNotEmpty
                   ? Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_errorMsg, style: const TextStyle(color: AppTheme.error, fontSize: 12), textAlign: TextAlign.center)),
                         const SizedBox(height: 12),
                         ElevatedButton(onPressed: _loadStrokeOrder, child: const Text('Retry')),
                       ],
                     )
                   : const Text('Loading Stroke Order...', style: TextStyle(color: AppTheme.textMuted)),
          ),
          if (_strokeCtrl != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StrokeButton(icon: Icons.play_arrow_rounded, label: 'Play', onTap: () => _strokeCtrl!.startAnimation()),
                const SizedBox(width: 12),
                _StrokeButton(icon: Icons.stop_rounded, label: 'Stop', onTap: () => _strokeCtrl!.stopAnimation()),
                const SizedBox(width: 12),
                _StrokeButton(icon: Icons.replay_rounded, label: 'Reset', onTap: () { _strokeCtrl!.stopAnimation(); _strokeCtrl!.reset(); }),
              ],
            ),
          ],
          if (widget.kanji.vocab.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Vocabulary'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: widget.kanji.vocab.length,
                separatorBuilder: (_, __) => const Divider(color: AppTheme.border, height: 16),
                itemBuilder: (_, i) => FuriganaRow(
                  word: widget.kanji.vocab[i].kanji,
                  reading: widget.kanji.vocab[i].reading,
                  meanings: widget.kanji.vocab[i].meanings,
                  romanji: widget.kanji.vocab[i].romanji,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/home/writing/${widget.kanji.character}'),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Practice Writing'),
          ),
        ],
      ),
    ),
  );
}
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 52,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary))),
    ],
  );
}
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2));
}
class _StrokeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _StrokeButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16, color: AppTheme.accent), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary))],
      ),
    ),
  );
}