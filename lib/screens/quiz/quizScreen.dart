import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../services/hiveService.dart';
import '../../widgets/quizOption.dart';
import '../../models/kanjiModel.dart';
import '../../data/kanjiData.dart';
import '../../appTheme.dart';
class QuizScreen extends ConsumerStatefulWidget {
  final String? level;
  const QuizScreen({super.key, this.level});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _random = Random();
  List<KanjiModel> _pool = [];
  List<KanjiModel> _questions = [];
  int _qIdx = 0;
  int _score = 0;
  List<String> _options = [];
  int _selectedOption = -1;
  int _correctIndex = -1;
  bool _answered = false;
  @override
  void initState() {
    super.initState();
  }
  void _initQuiz() {
    final allKanji = ref.read(kanjiDataProvider).value ?? {};
    if (allKanji.isEmpty) return;
    if (_selectedLevel != 'Mixed' && allKanji.containsKey(_selectedLevel)) {
      _pool = List.from(allKanji[_selectedLevel]!);
    } else {
      _pool = allKanji.values.expand((e) => e).toList();
    }
    if (_pool.length < 4) return;
    _pool.shuffle(_random);
    _questions = _pool.take(_questionCount).toList();
    _loadQuestion();
  }
  void _loadQuestion() {
    setState(() {
      _answered = false;
      _selectedOption = -1;
      final q = _questions[_qIdx];
      final wrongAnswers = _pool
          .where((k) => k.character != q.character)
          .map((k) => k.primaryMeaning)
          .toList()
        ..shuffle(_random);
      _options = [q.primaryMeaning, ...wrongAnswers.take(3)]..shuffle(_random);
      _correctIndex = _options.indexOf(q.primaryMeaning);
    });
  }
  void _onOptionTap(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = index;
      if (index == _correctIndex) _score++;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_qIdx < _questions.length - 1) {
        _qIdx++;
        _loadQuestion();
      } else {
        _finishQuiz();
      }
    });
  }
  Future<void> _finishQuiz() async {
    await HiveService.saveQuizResult(widget.level ?? 'Mixed', _score, _questions.length);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.border)),
        title: const Text('Quiz Complete!', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_score / ${_questions.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.accent)),
            const SizedBox(height: 8),
            Text(_score >= 8 ? 'Excellent Work!' : 'Keep Practicing!', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            child: const Text('Back To Home'),
          ),
        ],
      ),
    );
  }
  bool _started = false;
  String _selectedLevel = 'Mixed';
  int _questionCount = 10;
  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Settings')),
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
              const Text('Number Of Questions', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _questionCount,
                dropdownColor: AppTheme.card,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [10, 20, 30, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e Questions', style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
                onChanged: (v) => setState(() => _questionCount = v!),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _started = true);
                  _initQuiz();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Quiz'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      );
    }
    if (_questions.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final q = _questions[_qIdx];
    final progress = (_qIdx) / _questions.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close_rounded)),
        title: Text('${_qIdx + 1} / ${_questions.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.card,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                ),
              ),
              const Spacer(),
              const Text('What Does This Kanji Mean?', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
              const SizedBox(height: 32),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 10)],
                ),
                alignment: Alignment.center,
                child: Text(q.character, style: const TextStyle(fontSize: 80, color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              ...List.generate(4, (i) {
                QuizOptionState state = QuizOptionState.idle;
                if (_answered) {
                  if (i == _correctIndex) {
                    state = QuizOptionState.correct;
                  } else if (i == _selectedOption) {
                    state = QuizOptionState.wrong;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: QuizOption(
                    text: _options[i],
                    optionState: state,
                    onTap: () => _onOptionTap(i),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}