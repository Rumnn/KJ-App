import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../providers/authProvider.dart';
import '../../providers/dashboardProvider.dart';
import '../../data/kanjiData.dart';
import '../../widgets/circularProgress.dart';
import '../../widgets/kanjiGridCard.dart';
import '../../widgets/shimmerLoader.dart';
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

    final user = authState.value;
    final userName = user?.email.split('@').first ?? 'User';
    final currentStreak = dashboardData.currentStreak;
    final xp = user?.xp ?? 0;
    final points = user?.points ?? 0;

    // Calculate progress based on quiz results
    final totalQuizzes = dashboardData.quizResults.length;
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
              error: (e, _) => Center(child: Text('Error loading data: $e')),
            )
          : _navIndex == 1
              ? const _LessonsTab()
              : _navIndex == 2
                  ? const Center(
                      child: Text(
                          'Quiz Screen Coming Soon')) // Navigation handled in BottomNavBar
                  : const Center(child: Text('Profile Screen Coming Soon')),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeTab(String userName, int streak, int xp, int points,
      List<dynamic> recommended, int mastered, int goal, double progress) {
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
                      'Okaeri, $userName',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Keep it up!',
                      style: TextStyle(
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
                      const Text(
                        'DAYS',
                        style: TextStyle(
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
                  const Text(
                    'DAILY PROGRESS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  CircularProgress(progress: progress > 0 ? progress : 0.01),
                  const SizedBox(height: 16),
                  Text(
                    '$mastered/$goal Kanji Mastered',
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
                    child: const Text(
                      'N5 LEVEL • WEEK 2',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Essential Verbs',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Focusing on movement and direction radicals today.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
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
                        child: const Text('Continue'),
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
                const Text(
                  'Recommended for you',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onBackground),
                ),
                TextButton(
                  onPressed: () => setState(() => _navIndex = 1),
                  child: const Text('View All',
                      style: TextStyle(
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
                      const Text(
                        'Community Rankings',
                        style: TextStyle(
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
                          color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const _LeaderboardItem(
                            rank: 1, name: 'KanjiMaster', points: 1250, isMe: false),
                        const Divider(),
                        _LeaderboardItem(
                            rank: 2, name: userName, points: points, isMe: true),
                        const Divider(),
                        const _LeaderboardItem(
                            rank: 3, name: 'SenseiBot', points: 800, isMe: false),
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

  Widget _buildBottomNavBar() {
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'Quiz',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
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
    final kanjiAsync = ref.watch(kanjiDataProvider);
    final List<(String, Color)> levels = [
      ('N5', AppTheme.jlptColors[0]),
      ('N4', AppTheme.jlptColors[1]),
      ('N3', AppTheme.jlptColors[2]),
      ('N2', AppTheme.jlptColors[3]),
      ('N1', AppTheme.jlptColors[4]),
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SafeArea(child: SizedBox(height: 16)),
          const TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'JLPT Kanji'),
              Tab(text: 'Radicals'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                kanjiAsync.when(
                  data: (data) => ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: levels.length,
                    itemBuilder: (_, i) {
                      final (level, color) = levels[i];
                      final count = data[level]?.length ?? 0;
                      return GestureDetector(
                        onTap: () => context.push('/home/kanji/$level'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border:
                                Border.all(color: color.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                  color: color.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(level,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: color))),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$level Level Study',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text('$count Essential Kanji',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: color),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                const _RadicalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadicalsTab extends ConsumerWidget {
  const _RadicalsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radicals = ref.watch(radicalListProvider);
    final grouped = <int, List<dynamic>>{};
    for (final r in radicals) {
      grouped.putIfAbsent(r.strokes, () => []).add(r);
    }
    final strokeCounts = grouped.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: strokeCounts.length,
      itemBuilder: (_, i) {
        final strokes = strokeCounts[i];
        final group = grouped[strokes]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('$strokes Stroke${strokes == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2)),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group
                    .map((r) => Container(
                          width: 72,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.outlineVariant
                                      .withValues(alpha: 0.3))),
                          child: Column(
                            children: [
                              Text(r.character,
                                  style: const TextStyle(
                                      fontSize: 26, color: AppTheme.primary)),
                              const SizedBox(height: 2),
                              Text(r.meaning,
                                  style: const TextStyle(
                                      fontSize: 8, color: AppTheme.textMuted),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
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
