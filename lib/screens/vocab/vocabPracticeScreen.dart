import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../appTheme.dart';
import '../../data/vocabJlptData.dart';
import '../../models/vocabJlptModel.dart';
import '../../services/hiveService.dart';
import '../../services/streakService.dart';
import '../../widgets/quizOption.dart';

class VocabPracticeScreen extends ConsumerWidget {
  const VocabPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabJlptDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Practice')),
      body: vocabAsync.when(
        data: (data) {
          final total =
              data.values.fold<int>(0, (sum, list) => sum + list.length);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _ModeCard(
                title: 'Vocabulary Quiz',
                subtitle: '$total words across N5, N4, N3, N2, and N1',
                icon: Icons.quiz_rounded,
                color: AppTheme.primary,
                onTap: () => context.push('/home/vocab/quiz'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Vocabulary Flashcards',
                subtitle: 'Review words, readings, and meanings',
                icon: Icons.style_rounded,
                color: AppTheme.secondary,
                onTap: () => context.push('/home/vocab/flashcard'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Matching Game',
                subtitle: 'Match words with meanings against the clock',
                icon: Icons.extension_rounded,
                color: AppTheme.tertiary,
                onTap: () => context.push('/home/vocab/match'),
              ),
              const SizedBox(height: 28),
              const Text(
                'Levels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._levels.map((level) {
                final color = _levelColor(level);
                final count = data[level]?.length ?? 0;
                return GestureDetector(
                  onTap: () => context.push('/home/vocab/$level'),
                  child: _LevelRow(
                    level: level,
                    label: '$count Vocabulary Words',
                    color: color,
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class VocabListScreen extends ConsumerStatefulWidget {
  final String level;

  const VocabListScreen({super.key, required this.level});

  @override
  ConsumerState<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends ConsumerState<VocabListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(widget.level);
    final vocabAsync = ref.watch(vocabJlptByLevelProvider(widget.level));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.level} Vocabulary',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: vocabAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final filtered = items.asMap().entries.where((entry) {
            final vocab = entry.value;
            final query = _query.trim().toLowerCase();
            if (query.isEmpty) return true;
            return vocab.original.toLowerCase().contains(query) ||
                vocab.furigana.toLowerCase().contains(query) ||
                vocab.english.toLowerCase().contains(query);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.level} vocabulary...',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              ...filtered.map((entry) {
                final vocab = entry.value;
                return _VocabListTile(
                  vocab: vocab,
                  color: color,
                  onTap: () => context.push(
                    '/home/vocab/${widget.level}/detail/${entry.key}',
                  ),
                );
              }),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No vocabulary found.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class VocabDetailScreen extends ConsumerWidget {
  final String level;
  final int index;

  const VocabDetailScreen({
    super.key,
    required this.level,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabJlptByLevelProvider(level));
    final color = _levelColor(level);

    return vocabAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (items) {
        if (index < 0 || index >= items.length) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Vocabulary Not Found')),
          );
        }

        final vocab = items[index];
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _LevelBadge(level: vocab.level, color: color),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        vocab.original,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (vocab.furigana.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          vocab.furigana,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _DetailSection(
                  title: 'Meaning',
                  child: Text(
                    vocab.english,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VocabQuizScreen extends ConsumerStatefulWidget {
  final String? level;

  const VocabQuizScreen({super.key, this.level});

  @override
  ConsumerState<VocabQuizScreen> createState() => _VocabQuizScreenState();
}

class _VocabQuizScreenState extends ConsumerState<VocabQuizScreen> {
  final _random = Random();
  List<VocabJlptModel> _pool = [];
  List<VocabJlptModel> _questions = [];
  List<String> _options = [];
  bool _started = false;
  bool _answered = false;
  String _selectedLevel = 'Mixed';
  int _questionCount = 10;
  int _qIdx = 0;
  int _score = 0;
  int _selectedOption = -1;
  int _correctIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.level ?? 'Mixed';
  }

  void _initQuiz() {
    final allVocab = ref.read(vocabJlptDataProvider).value ?? {};
    _pool = _poolForLevel(allVocab, _selectedLevel);
    if (_pool.length < 4) return;
    _pool.shuffle(_random);
    _questions = _pool.take(min(_questionCount, _pool.length)).toList();
    _qIdx = 0;
    _score = 0;
    _loadQuestion();
  }

  void _loadQuestion() {
    setState(() {
      _answered = false;
      _selectedOption = -1;
      final q = _questions[_qIdx];
      final wrongAnswers = _pool
          .where((v) => v.id != q.id)
          .map((v) => v.english)
          .where((text) => text.trim().isNotEmpty && text != q.english)
          .toSet()
          .toList()
        ..shuffle(_random);
      _options = [q.english, ...wrongAnswers.take(3)]..shuffle(_random);
      _correctIndex = _options.indexOf(q.english);
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
    await HiveService.saveQuizResult(
      'Vocab $_selectedLevel',
      _score,
      _questions.length,
    );
    if (!mounted) return;
    _showCompleteDialog(
      context: context,
      title: 'Quiz Complete!',
      scoreText: '$_score / ${_questions.length}',
      subtitle: _score >= (_questions.length * 0.8)
          ? 'Excellent Work!'
          : 'Keep Practicing!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabJlptDataProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary Quiz Settings')),
        body: vocabAsync.when(
          data: (_) => _SettingsBody(
            selectedLevel: _selectedLevel,
            count: _questionCount,
            countValues: const [10, 20, 30, 50],
            countLabel: 'Questions',
            onLevelChanged: (v) => setState(() => _selectedLevel = v),
            onCountChanged: (v) => setState(() => _questionCount = v),
            onStart: () {
              setState(() => _started = true);
              _initQuiz();
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    }

    if (_questions.isEmpty || _options.length < 4) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_qIdx];
    final progress = _qIdx / _questions.length;
    final color = _levelColor(q.level);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          '${_qIdx + 1} / ${_questions.length}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
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
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose The Correct Meaning',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              _PromptCard(vocab: q, color: color),
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
                  padding: const EdgeInsets.only(bottom: 14),
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

class VocabFlashcardScreen extends ConsumerStatefulWidget {
  final String? level;

  const VocabFlashcardScreen({super.key, this.level});

  @override
  ConsumerState<VocabFlashcardScreen> createState() =>
      _VocabFlashcardScreenState();
}

class _VocabFlashcardScreenState extends ConsumerState<VocabFlashcardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.88);
  final _random = Random();
  List<VocabJlptModel> _cards = [];
  bool _started = false;
  String _selectedLevel = 'Mixed';
  int _cardCount = 20;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.level ?? 'Mixed';
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _initCards() async {
    final allVocab = ref.read(vocabJlptDataProvider).value ?? {};
    final pool = _poolForLevel(allVocab, _selectedLevel)..shuffle(_random);
    setState(() => _cards = pool.take(min(_cardCount, pool.length)).toList());
    await StreakService.recordStudySession();
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabJlptDataProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary Flashcards Settings')),
        body: vocabAsync.when(
          data: (_) => _SettingsBody(
            selectedLevel: _selectedLevel,
            count: _cardCount,
            countValues: const [10, 20, 30, 50],
            countLabel: 'Cards',
            onLevelChanged: (v) => setState(() => _selectedLevel = v),
            onCountChanged: (v) => setState(() => _cardCount = v),
            onStart: () {
              setState(() => _started = true);
              _initCards();
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    }

    if (_cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          '${_idx + 1} / ${_cards.length}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Swipe To Navigate - Tap To Flip',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 500,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: _cards.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 20,
                  ),
                  child: VocabFlashcardWidget(vocab: _cards[i]),
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class VocabMatchScreen extends ConsumerStatefulWidget {
  final String? level;

  const VocabMatchScreen({super.key, this.level});

  @override
  ConsumerState<VocabMatchScreen> createState() => _VocabMatchScreenState();
}

class _VocabMatchScreenState extends ConsumerState<VocabMatchScreen> {
  final _random = Random();
  List<VocabJlptModel> _words = [];
  List<VocabJlptModel> _meanings = [];
  Set<int> _completedWordIds = {};
  Set<int> _completedMeaningIds = {};
  bool _started = false;
  String _selectedLevel = 'Mixed';
  int _pairCount = 8;
  int _elapsedSeconds = 0;
  int _wrongAttempts = 0;
  int? _selectedWordId;
  int? _selectedMeaningId;
  bool _showWrong = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.level ?? 'Mixed';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    final allVocab = ref.read(vocabJlptDataProvider).value ?? {};
    final pool = _poolForLevel(allVocab, _selectedLevel)..shuffle(_random);
    _words = pool.take(min(_pairCount, pool.length)).toList();
    _meanings = List.from(_words)..shuffle(_random);
    _completedWordIds = {};
    _completedMeaningIds = {};
    _selectedWordId = null;
    _selectedMeaningId = null;
    _elapsedSeconds = 0;
    _wrongAttempts = 0;
    _showWrong = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _selectWord(VocabJlptModel vocab) {
    if (_completedWordIds.contains(vocab.id)) return;
    setState(() {
      _selectedWordId = vocab.id;
      _showWrong = false;
    });
    _tryMatch();
  }

  void _selectMeaning(VocabJlptModel vocab) {
    if (_completedMeaningIds.contains(vocab.id)) return;
    setState(() {
      _selectedMeaningId = vocab.id;
      _showWrong = false;
    });
    _tryMatch();
  }

  void _tryMatch() {
    final wordId = _selectedWordId;
    final meaningId = _selectedMeaningId;
    if (wordId == null || meaningId == null) return;

    if (wordId == meaningId) {
      setState(() {
        _completedWordIds = {..._completedWordIds, wordId};
        _completedMeaningIds = {..._completedMeaningIds, meaningId};
        _selectedWordId = null;
        _selectedMeaningId = null;
      });
      if (_completedWordIds.length == _words.length) _finishGame();
    } else {
      setState(() {
        _wrongAttempts++;
        _showWrong = true;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {
          _selectedWordId = null;
          _selectedMeaningId = null;
          _showWrong = false;
        });
      });
    }
  }

  Future<void> _finishGame() async {
    _timer?.cancel();
    final score = _score;
    final maxScore = _words.length * 100 + 600;
    await HiveService.saveQuizResult(
      'Vocab Match $_selectedLevel',
      score,
      maxScore,
    );
    if (!mounted) return;
    _showCompleteDialog(
      context: context,
      title: 'Game Complete!',
      scoreText: '$score / $maxScore',
      subtitle:
          'Time: ${_formatTime(_elapsedSeconds)} - Mistakes: $_wrongAttempts',
    );
  }

  int get _score {
    final baseScore = _completedWordIds.length * 100;
    final penalty = _wrongAttempts * 25;
    final timeBonus = max(0, 300 - _elapsedSeconds) * 2;
    return max(0, baseScore + timeBonus - penalty);
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabJlptDataProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Matching Game Settings')),
        body: vocabAsync.when(
          data: (_) => _SettingsBody(
            selectedLevel: _selectedLevel,
            count: _pairCount,
            countValues: const [6, 8, 10, 12],
            countLabel: 'Pairs',
            onLevelChanged: (v) => setState(() => _selectedLevel = v),
            onCountChanged: (v) => setState(() => _pairCount = v),
            onStart: () {
              setState(() => _started = true);
              _initGame();
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    }

    if (_words.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          '${_completedWordIds.length} / ${_words.length}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _StatChip(
                    icon: Icons.timer_rounded,
                    label: _formatTime(_elapsedSeconds),
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.star_rounded,
                    label: '$_score pts',
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.close_rounded,
                    label: '$_wrongAttempts',
                  ),
                ],
              ),
              if (_showWrong) ...[
                const SizedBox(height: 12),
                const Text(
                  'Try again',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: _words
                            .map(
                              (vocab) => _MatchCard(
                                title: vocab.original,
                                subtitle: vocab.furigana,
                                selected: _selectedWordId == vocab.id,
                                completed: _completedWordIds.contains(vocab.id),
                                wrong:
                                    _showWrong && _selectedWordId == vocab.id,
                                onTap: () => _selectWord(vocab),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListView(
                        children: _meanings
                            .map(
                              (vocab) => _MatchCard(
                                title: vocab.english,
                                subtitle: '',
                                selected: _selectedMeaningId == vocab.id,
                                completed:
                                    _completedMeaningIds.contains(vocab.id),
                                wrong: _showWrong &&
                                    _selectedMeaningId == vocab.id,
                                onTap: () => _selectMeaning(vocab),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VocabFlashcardWidget extends StatefulWidget {
  final VocabJlptModel vocab;

  const VocabFlashcardWidget({super.key, required this.vocab});

  @override
  State<VocabFlashcardWidget> createState() => _VocabFlashcardWidgetState();
}

class _VocabFlashcardWidgetState extends State<VocabFlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(begin: 0, end: 3.14159265).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
                height: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isBack ? AppTheme.accentGlow : AppTheme.border,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.accentGlow,
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.1416),
                        child: _VocabBackContent(vocab: widget.vocab),
                      )
                    : _VocabFrontContent(vocab: widget.vocab),
              ),
            );
          },
        ),
      );
}

class _VocabFrontContent extends StatelessWidget {
  final VocabJlptModel vocab;

  const _VocabFrontContent({required this.vocab});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LevelBadge(level: vocab.level, color: Colors.white),
          const SizedBox(height: 18),
          Text(
            vocab.original,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (vocab.furigana.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              vocab.furigana,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Tap To Reveal',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      );
}

class _VocabBackContent extends StatelessWidget {
  final VocabJlptModel vocab;

  const _VocabBackContent({required this.vocab});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          vocab.english,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            height: 1.35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
}

class _VocabListTile extends StatelessWidget {
  final VocabJlptModel vocab;
  final Color color;
  final VoidCallback onTap;

  const _VocabListTile({
    required this.vocab,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              _LevelBadge(level: vocab.level, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocab.original,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (vocab.furigana.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        vocab.furigana,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      vocab.english,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      );
}

class _PromptCard extends StatelessWidget {
  final VocabJlptModel vocab;
  final Color color;

  const _PromptCard({required this.vocab, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            _LevelBadge(level: vocab.level, color: color),
            const SizedBox(height: 16),
            Text(
              vocab.original,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            if (vocab.furigana.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                vocab.furigana,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      );
}

class _SettingsBody extends StatelessWidget {
  final String selectedLevel;
  final int count;
  final List<int> countValues;
  final String countLabel;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;

  const _SettingsBody({
    required this.selectedLevel,
    required this.count,
    required this.countValues,
    required this.countLabel,
    required this.onLevelChanged,
    required this.onCountChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Level',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedLevel,
              dropdownColor: AppTheme.card,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['Mixed', ..._levels]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onLevelChanged(v);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Number Of $countLabel',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: count,
              dropdownColor: AppTheme.card,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: countValues
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        '$e $countLabel',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onCountChanged(v);
              },
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      );
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      );
}

class _LevelRow extends StatelessWidget {
  final String level;
  final String label;
  final Color color;

  const _LevelRow({
    required this.level,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            _LevelBadge(level: level, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      );
}

class _LevelBadge extends StatelessWidget {
  final String level;
  final Color color;

  const _LevelBadge({required this.level, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          level,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
}

class _MatchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final bool completed;
  final bool wrong;
  final VoidCallback onTap;

  const _MatchCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.completed,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = completed
        ? AppTheme.success
        : wrong
            ? AppTheme.error
            : selected
                ? AppTheme.primary
                : AppTheme.border;
    final bgColor = completed
        ? AppTheme.success.withValues(alpha: 0.12)
        : wrong
            ? AppTheme.error.withValues(alpha: 0.12)
            : selected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : AppTheme.card;

    return GestureDetector(
      onTap: completed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minHeight: 78),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: completed ? AppTheme.success : AppTheme.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

List<VocabJlptModel> _poolForLevel(
  Map<String, List<VocabJlptModel>> allVocab,
  String level,
) {
  if (level != 'Mixed' && allVocab.containsKey(level)) {
    return List.from(allVocab[level]!);
  }
  return allVocab.values.expand((e) => e).toList();
}

void _showCompleteDialog({
  required BuildContext context,
  required String title,
  required String scoreText,
  required String subtitle,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            scoreText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.pop();
          },
          child: const Text('Back'),
        ),
      ],
    ),
  );
}

String _formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')}';
}

Color _levelColor(String level) => switch (level) {
      'N5' => AppTheme.jlptColors[0],
      'N4' => AppTheme.jlptColors[1],
      'N3' => AppTheme.jlptColors[2],
      'N2' => AppTheme.jlptColors[3],
      'N1' => AppTheme.jlptColors[4],
      _ => AppTheme.primary,
    };

const _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
