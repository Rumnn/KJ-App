import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:kj/l10n/app_localizations.dart';
import '../../providers/authProvider.dart';
import '../../providers/dashboardProvider.dart';
import '../../data/grammarData.dart';
import '../../data/kanjiData.dart';
import '../../data/vocabJlptData.dart';
import '../../widgets/circularProgress.dart';
import '../../widgets/kanjiGridCard.dart';
import '../../appTheme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardData = ref.watch(dashboardProvider);
    final kanjiAsync = ref.watch(kanjiDataProvider);
    final l10n = AppLocalizations.of(context)!;

    final user = authState.value;
    final userName = user?.email.split('@').first ?? l10n.defaultUser;
    final currentStreak = dashboardData.currentStreak;
    final xp = user?.xp ?? 0;
    final points = user?.points ?? 0;

    // Calculate progress based on quiz results
    final masteredCount = dashboardData.quizResults
        .where((r) => (r.score / r.total) >= 0.8)
        .length;
    final dailyGoal = 10;
    final progress = (masteredCount % dailyGoal) / dailyGoal;

    return Scaffold(
      body: _navIndex == 0
          ? kanjiAsync.when(
              data: (data) => _buildHomeTab(
                  userName,
                  currentStreak,
                  xp,
                  points,
                  data['N5']?.take(4).toList() ?? [],
                  masteredCount,
                  dailyGoal,
                  progress),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.errorLoadingData(e.toString()))),
            )
          : _navIndex == 1
              ? const _LessonsTab()
              : _navIndex == 2
                  ? Center(
                      child: Text(
                          l10n.quizComingSoon)) // Navigation handled in BottomNavBar
                  : Center(child: Text(l10n.profileComingSoon)),
      floatingActionButton: _buildChatFab(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeTab(String userName, int streak, int xp, int points,
      List<dynamic> recommended, int mastered, int goal, double progress) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                const Text(
                  'KanjiFlow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: AppTheme.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$xp XP',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.account_circle,
                      color: AppTheme.primary, size: 28),
                  onPressed: () => context.push('/home/settings'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Welcome & Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.okaeriUser(userName),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.keepItUp,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onBackground),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryFixedDim.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            AppTheme.tertiaryFixedDim.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppTheme.tertiary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tertiary,
                            height: 1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.streakDaysUpper,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.tertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Daily Progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    l10n.dailyProgressUpper,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  CircularProgress(progress: progress > 0 ? progress : 0.01),
                  const SizedBox(height: 16),
                  Text(
                    l10n.kanjiMastered(mastered, goal),
                    style: const TextStyle(
                        fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Continue Learning Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      l10n.continueLearningBadge,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.essentialVerbs,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.continueLearningSubtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push('/home/kanji/N5'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.continueText),
                      ),
                      const Row(
                        children: [
                          _SmallKanjiCircle(char: '行'),
                          _SmallKanjiCircle(char: '来'),
                          _SmallKanjiCircle(char: '出'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Recommended for you
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recommendedForYou,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onBackground),
                ),
                TextButton(
                  onPressed: () => setState(() => _navIndex = 1),
                  child: Text(l10n.viewAll,
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommended.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (_, i) {
                final k = recommended[i];
                return KanjiGridCard(
                  character: k.character,
                  romaji: k.kunReadings.isNotEmpty
                      ? k.kunReadings.first
                      : k.onReadings.first,
                  meaning: k.primaryMeaning,
                  onTap: () =>
                      context.push('/home/kanji/N5/detail/${k.character}'),
                );
              },
            ),
            const SizedBox(height: 40),

            const SizedBox(height: 40),

            // Leaderboard Preview
            GestureDetector(
              onTap: () => context.push('/home/leaderboard'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.communityRankings,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onBackground),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppTheme.gold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color:
                              AppTheme.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const _LeaderboardItem(
                            rank: 1,
                            name: 'KanjiMaster',
                            points: 1250,
                            isMe: false),
                        const Divider(),
                        _LeaderboardItem(
                            rank: 2,
                            name: userName,
                            points: points,
                            isMe: true),
                        const Divider(),
                        const _LeaderboardItem(
                            rank: 3,
                            name: 'SenseiBot',
                            points: 800,
                            isMe: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildChatFab() {
    return GestureDetector(
      onTap: () => context.push('/home/chat'),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4352A5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('先',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF7D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 2) {
            context.push('/home/quiz');
            return;
          }
          if (i == 3) {
            context.push('/home/settings');
            return;
          }
          setState(() => _navIndex = i);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home, color: AppTheme.primary),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: l10n.lessons,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined),
            label: l10n.quiz,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class _SmallKanjiCircle extends StatelessWidget {
  final String char;
  const _SmallKanjiCircle({required this.char});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _LessonsTab extends ConsumerWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final kanjiAsync = ref.watch(kanjiDataProvider);
    final grammarAsync = ref.watch(grammarDataProvider);
    final vocabAsync = ref.watch(vocabJlptDataProvider);
    final radicals = ref.watch(radicalListProvider);
    final List<(String, Color)> levels = [
      ('N5', AppTheme.jlptColors[0]),
      ('N4', AppTheme.jlptColors[1]),
      ('N3', AppTheme.jlptColors[2]),
      ('N2', AppTheme.jlptColors[3]),
      ('N1', AppTheme.jlptColors[4]),
    ];

    final groupedRadicals = <int, List<dynamic>>{};
    for (final radical in radicals) {
      groupedRadicals.putIfAbsent(radical.strokes, () => []).add(radical);
    }
    final strokeCounts = groupedRadicals.keys.toList()..sort();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 112),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lessons,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.lessonsSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          kanjiAsync.when(
            data: (data) => _LessonCarouselBlock(
              title: l10n.jlptKanji,
              subtitle: l10n.kanjiSubtitle,
              icon: Icons.school_outlined,
              color: AppTheme.primary,
              children: [
                for (final (level, color) in levels)
                  _LessonCarouselCard(
                    badge: level,
                    title: l10n.levelStudy(level),
                    subtitle: l10n.essentialKanji(data[level]?.length ?? 0),
                    color: color,
                    onTap: () => context.push('/home/kanji/$level'),
                  ),
              ],
            ),
            loading: () => const _CarouselLoadingBlock(),
            error: (e, _) => _CarouselErrorBlock(message: 'Error: $e'),
          ),
          grammarAsync.when(
            data: (data) => _LessonCarouselBlock(
              title: l10n.grammar,
              subtitle: l10n.grammarSubtitle,
              icon: Icons.article_outlined,
              color: AppTheme.primary,
              onViewAll: () => context.push('/home/grammar'),
              children: [
                _LessonActionCard(
                  icon: Icons.quiz_outlined,
                  title: l10n.grammarPractice,
                  subtitle: l10n.grammarPracticeSubtitle,
                  color: AppTheme.primary,
                  onTap: () => context.push('/home/grammar'),
                ),
                for (final (level, color) in [
                  ('N5', AppTheme.jlptColors[0]),
                  ('N4', AppTheme.jlptColors[1]),
                  ('N3', AppTheme.jlptColors[2]),
                ])
                  _LessonCarouselCard(
                    badge: level,
                    title: level,
                    subtitle: l10n.grammarPoints(data[level]?.length ?? 0),
                    color: color,
                    onTap: () => context.push('/home/grammar/$level'),
                  ),
              ],
            ),
            loading: () => const _CarouselLoadingBlock(),
            error: (e, _) => _CarouselErrorBlock(message: 'Error: $e'),
          ),
          vocabAsync.when(
            data: (data) => _LessonCarouselBlock(
              title: l10n.vocabulary,
              subtitle: l10n.vocabularySubtitle,
              icon: Icons.translate_outlined,
              color: AppTheme.secondary,
              onViewAll: () => context.push('/home/vocab'),
              children: [
                _LessonActionCard(
                  icon: Icons.extension_outlined,
                  title: l10n.vocabularyPractice,
                  subtitle: l10n.vocabularyPracticeSubtitle,
                  color: AppTheme.secondary,
                  onTap: () => context.push('/home/vocab'),
                ),
                for (final (level, color) in levels)
                  _LessonCarouselCard(
                    badge: level,
                    title: level,
                    subtitle: l10n.vocabularyWords(data[level]?.length ?? 0),
                    color: color,
                    onTap: () => context.push('/home/vocab/$level'),
                  ),
              ],
            ),
            loading: () => const _CarouselLoadingBlock(),
            error: (e, _) => _CarouselErrorBlock(message: 'Error: $e'),
          ),
          _LessonCarouselBlock(
            title: l10n.radicals,
            subtitle: l10n.radicalsSubtitle,
            icon: Icons.category_outlined,
            color: AppTheme.accent,
            children: [
              for (final strokes in strokeCounts.take(12))
                _RadicalCarouselCard(
                  title: strokes == 1
                      ? l10n.strokeCount(strokes)
                      : l10n.strokeCountPlural(strokes),
                  radicals: groupedRadicals[strokes]!,
                  color: AppTheme.jlptColors[(strokes - 1) % AppTheme.jlptColors.length],
                  onTap: () => context.push('/home/radicals'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonCarouselBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onViewAll;
  final List<Widget> children;

  const _LessonCarouselBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.children,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(l10n.viewAll),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => children[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCarouselCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LessonCarouselCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 224,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: color),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _LessonActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LessonActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 244,
        child: Material(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _RadicalCarouselCard extends StatelessWidget {
  final String title;
  final List<dynamic> radicals;
  final Color color;
  final VoidCallback onTap;

  const _RadicalCarouselCard({
    required this.title,
    required this.radicals,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 224,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: radicals
                        .take(8)
                        .map((radical) => Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                radical.character,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _CarouselLoadingBlock extends StatelessWidget {
  const _CarouselLoadingBlock();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 178,
        child: Center(child: CircularProgressIndicator()),
      );
}

class _CarouselErrorBlock extends StatelessWidget {
  final String message;

  const _CarouselErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(message, style: const TextStyle(color: AppTheme.error)),
      );
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool isMe;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppTheme.gold.withValues(alpha: 0.2)
                  : AppTheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? AppTheme.gold : AppTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              color: isMe ? AppTheme.primary : AppTheme.onBackground,
            ),
          ),
          const Spacer(),
          Text(
            '$points pts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
