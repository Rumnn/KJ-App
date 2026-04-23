import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../widgets/flashcardWidget.dart';
import '../../services/streakService.dart';
import '../../models/kanjiModel.dart';
import '../../data/kanjiData.dart';
import '../../appTheme.dart';
class FlashcardScreen extends ConsumerStatefulWidget {
  final String? level;
  const FlashcardScreen({super.key, this.level});
  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}
class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.85);
  final _random = Random();
  List<KanjiModel> _cards = [];
  int _idx = 0;
  @override
  void initState() {
    super.initState();
  }
  Future<void> _initCards() async {
    final allKanji = ref.read(kanjiDataProvider).value ?? {};
    if (allKanji.isEmpty) return;
    List<KanjiModel> pool;
    if (_selectedLevel != 'Mixed' && allKanji.containsKey(_selectedLevel)) {
      pool = List.from(allKanji[_selectedLevel]!);
    } else {
      pool = allKanji.values.expand((e) => e).toList();
    }
    pool.shuffle(_random);
    setState(() => _cards = pool.take(_cardCount).toList());
    await StreakService.recordStudySession();
  }
  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }
  bool _started = false;
  String _selectedLevel = 'Mixed';
  int _cardCount = 20;

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards Settings')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Level', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                dropdownColor: AppTheme.card,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Mixed', 'N5', 'N4', 'N3', 'N2', 'N1'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
                onChanged: (v) => setState(() => _selectedLevel = v!),
              ),
              const SizedBox(height: 24),
              const Text('Number Of Cards', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _cardCount,
                dropdownColor: AppTheme.card,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [10, 20, 30, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e Cards', style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
                onChanged: (v) => setState(() => _cardCount = v!),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _started = true);
                  _initCards();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Flashcards'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      );
    }

    if (_cards.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close_rounded)),
        title: Text('${_idx + 1} / ${_cards.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Swipe To Navigate • Tap To Flip', style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.8), fontSize: 13, letterSpacing: 1.2)),
            const Spacer(),
            SizedBox(
              height: 480,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: _cards.length,
                itemBuilder: (context, i) {
                  final k = _cards[i];
                  return AnimatedBuilder(
                    animation: _pageCtrl,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageCtrl.position.haveDimensions) {
                        value = _pageCtrl.page! - i;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: FlashcardWidget(
                        frontText: k.character,
                        backMeaning: k.primaryMeaning,
                        backOnReading: k.onReadingsText,
                        backKunReading: k.kunReadingsText,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(flex: 2),
            if (_idx == _cards.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('Complete Session'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}