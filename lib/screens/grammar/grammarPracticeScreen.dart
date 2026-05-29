import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../appTheme.dart';
import '../../data/grammarData.dart';
import '../../models/grammarModel.dart';
import '../../services/hiveService.dart';
import '../../services/streakService.dart';
import '../../widgets/quizOption.dart';

class GrammarPracticeScreen extends ConsumerWidget {
  const GrammarPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(grammarDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Practice')),
      body: grammarAsync.when(
        data: (data) {
          final levels = [
            ('N5', AppTheme.jlptColors[0]),
            ('N4', AppTheme.jlptColors[1]),
            ('N3', AppTheme.jlptColors[2]),
          ];
          final total =
              data.values.fold<int>(0, (sum, list) => sum + list.length);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _ModeCard(
                title: 'Grammar Quiz',
                subtitle: '$total grammar points across N5, N4, and N3',
                icon: Icons.quiz_rounded,
                color: AppTheme.primary,
                onTap: () => context.push('/home/grammar/quiz'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Grammar Flashcards',
                subtitle: 'Review patterns, formations, and examples',
                icon: Icons.style_rounded,
                color: AppTheme.secondary,
                onTap: () => context.push('/home/grammar/flashcard'),
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
              ...levels.map((item) {
                final (level, color) = item;
                final count = data[level]?.length ?? 0;
                return GestureDetector(
                  onTap: () => context.push('/home/grammar/$level'),
                  child: Container(
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
                            '$count Grammar Points',
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

class GrammarListScreen extends ConsumerStatefulWidget {
  final String level;

  const GrammarListScreen({super.key, required this.level});

  @override
  ConsumerState<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends ConsumerState<GrammarListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(widget.level);
    final grammarAsync = ref.watch(grammarByLevelProvider(widget.level));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.level} Grammar',
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
      body: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final filtered = items.asMap().entries.where((entry) {
            final grammar = entry.value;
            final query = _query.trim().toLowerCase();
            if (query.isEmpty) return true;
            return grammar.title.toLowerCase().contains(query) ||
                grammar.shortExplanation.toLowerCase().contains(query) ||
                grammar.formation.toLowerCase().contains(query);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.level} grammar...',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              ...filtered.map((entry) {
                final grammar = entry.value;
                return _GrammarListTile(
                  grammar: grammar,
                  color: color,
                  onTap: () => context.push(
                    '/home/grammar/${widget.level}/detail/${entry.key}',
                  ),
                );
              }),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No grammar points found.',
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

class GrammarDetailScreen extends ConsumerWidget {
  final String level;
  final int index;

  const GrammarDetailScreen({
    super.key,
    required this.level,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(grammarByLevelProvider(level));
    final color = _levelColor(level);

    return grammarAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (items) {
        if (index < 0 || index >= items.length) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text(
                'Grammar Point Not Found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        final grammar = items[index];
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _LevelBadge(level: grammar.level, color: color),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      grammar.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailSection(
                  title: 'Meaning',
                  child: Text(
                    grammar.shortExplanation,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (grammar.formation.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: 'Formation',
                    child: Text(
                      grammar.formation,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
                if (grammar.longExplanation.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: 'Explanation',
                    child: Text(
                      grammar.longExplanation,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (grammar.examples.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...grammar.examples.asMap().entries.map((entry) {
                    return _ExampleCard(
                      example: entry.value,
                      number: entry.key + 1,
                      color: color,
                    );
                  }),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GrammarQuizScreen extends ConsumerStatefulWidget {
  final String? level;

  const GrammarQuizScreen({super.key, this.level});

  @override
  ConsumerState<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends ConsumerState<GrammarQuizScreen> {
  final _random = Random();
  List<GrammarModel> _pool = [];
  List<GrammarModel> _questions = [];
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
    final allGrammar = ref.read(grammarDataProvider).value ?? {};
    if (allGrammar.isEmpty) return;

    if (_selectedLevel != 'Mixed' && allGrammar.containsKey(_selectedLevel)) {
      _pool = List.from(allGrammar[_selectedLevel]!);
    } else {
      _pool = allGrammar.values.expand((e) => e).toList();
    }

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
      final correct = _answerText(q);
      final wrongAnswers = _pool
          .where((g) => g.title != q.title)
          .map(_answerText)
          .where((text) => text != correct)
          .where((text) => text.trim().isNotEmpty)
          .toList()
        ..shuffle(_random);
      _options = [correct, ...wrongAnswers.take(3)]..shuffle(_random);
      _correctIndex = _options.indexOf(correct);
    });
  }

  String _answerText(GrammarModel grammar) {
    if (grammar.shortExplanation.trim().isNotEmpty) {
      return grammar.shortExplanation;
    }
    if (grammar.longExplanation.trim().isNotEmpty) {
      return grammar.longExplanation;
    }
    if (grammar.formation.trim().isNotEmpty) return grammar.formation;
    return grammar.title;
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
      'Grammar $_selectedLevel',
      _score,
      _questions.length,
    );
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Quiz Complete!',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_questions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= (_questions.length * 0.8)
                  ? 'Excellent Work!'
                  : 'Keep Practicing!',
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

  @override
  Widget build(BuildContext context) {
    final grammarAsync = ref.watch(grammarDataProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grammar Quiz Settings')),
        body: grammarAsync.when(
          data: (_) => _SettingsBody(
            selectedLevel: _selectedLevel,
            count: _questionCount,
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_qIdx];
    final progress = _qIdx / _questions.length;

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
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose The Correct Meaning',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _LevelBadge(
                      level: q.level,
                      color: _levelColor(q.level),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      q.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
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

class _GrammarListTile extends StatelessWidget {
  final GrammarModel grammar;
  final Color color;
  final VoidCallback onTap;

  const _GrammarListTile({
    required this.grammar,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LevelBadge(level: grammar.level, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grammar.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (grammar.shortExplanation.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        grammar.shortExplanation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    if (grammar.formation.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        grammar.formation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
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

class _ExampleCard extends StatelessWidget {
  final GrammarExampleModel example;
  final int number;
  final Color color;

  const _ExampleCard({
    required this.example,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Example',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (example.jp.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                example.jp,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
            if (example.romaji.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                example.romaji,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
            if (example.vn.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                example.vn,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
}

class GrammarFlashcardScreen extends ConsumerStatefulWidget {
  final String? level;

  const GrammarFlashcardScreen({super.key, this.level});

  @override
  ConsumerState<GrammarFlashcardScreen> createState() =>
      _GrammarFlashcardScreenState();
}

class _GrammarFlashcardScreenState
    extends ConsumerState<GrammarFlashcardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.88);
  final _random = Random();
  List<GrammarModel> _cards = [];
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
    final allGrammar = ref.read(grammarDataProvider).value ?? {};
    if (allGrammar.isEmpty) return;

    List<GrammarModel> pool;
    if (_selectedLevel != 'Mixed' && allGrammar.containsKey(_selectedLevel)) {
      pool = List.from(allGrammar[_selectedLevel]!);
    } else {
      pool = allGrammar.values.expand((e) => e).toList();
    }

    pool.shuffle(_random);
    setState(() => _cards = pool.take(min(_cardCount, pool.length)).toList());
    await StreakService.recordStudySession();
  }

  @override
  Widget build(BuildContext context) {
    final grammarAsync = ref.watch(grammarDataProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grammar Flashcards Settings')),
        body: grammarAsync.when(
          data: (_) => _SettingsBody(
            selectedLevel: _selectedLevel,
            count: _cardCount,
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                itemBuilder: (context, i) {
                  final grammar = _cards[i];
                  return AnimatedBuilder(
                    animation: _pageCtrl,
                    builder: (context, child) {
                      double value = 1;
                      if (_pageCtrl.position.haveDimensions) {
                        value = _pageCtrl.page! - i;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 20,
                      ),
                      child: GrammarFlashcardWidget(grammar: grammar),
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

class GrammarFlashcardWidget extends StatefulWidget {
  final GrammarModel grammar;

  const GrammarFlashcardWidget({super.key, required this.grammar});

  @override
  State<GrammarFlashcardWidget> createState() => _GrammarFlashcardWidgetState();
}

class _GrammarFlashcardWidgetState extends State<GrammarFlashcardWidget>
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
                height: 360,
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
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.1416),
                        child: _GrammarBackContent(grammar: widget.grammar),
                      )
                    : _GrammarFrontContent(grammar: widget.grammar),
              ),
            );
          },
        ),
      );
}

class _GrammarFrontContent extends StatelessWidget {
  final GrammarModel grammar;

  const _GrammarFrontContent({required this.grammar});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LevelBadge(level: grammar.level, color: _levelColor(grammar.level)),
          const SizedBox(height: 18),
          Text(
            grammar.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tap To Reveal',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      );
}

class _GrammarBackContent extends StatelessWidget {
  final GrammarModel grammar;

  const _GrammarBackContent({required this.grammar});

  @override
  Widget build(BuildContext context) {
    final example = grammar.examples.isEmpty ? null : grammar.examples.first;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            grammar.shortExplanation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _InfoBlock(label: 'Formation', value: grammar.formation),
          if (example != null) ...[
            const SizedBox(height: 12),
            _InfoBlock(label: 'Example', value: example.jp),
            if (example.romaji.isNotEmpty)
              _InfoBlock(label: 'Romaji', value: example.romaji),
            if (example.vn.isNotEmpty)
              _InfoBlock(label: 'Meaning', value: example.vn),
          ],
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final String selectedLevel;
  final int count;
  final String countLabel;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;

  const _SettingsBody({
    required this.selectedLevel,
    required this.count,
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
              items: ['Mixed', 'N5', 'N4', 'N3']
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
              items: [10, 20, 30, 50]
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

Color _levelColor(String level) => switch (level) {
      'N5' => AppTheme.jlptColors[0],
      'N4' => AppTheme.jlptColors[1],
      'N3' => AppTheme.jlptColors[2],
      _ => AppTheme.primary,
    };
