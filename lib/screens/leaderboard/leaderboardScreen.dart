import 'package:flutter/material.dart';
import 'package:kj/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/authService.dart';
import '../../providers/authProvider.dart';
import '../../appTheme.dart';
import '../../widgets/shimmerLoader.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = AuthService.getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.globalRankings),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ShimmerListLoader());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<dynamic> players = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _leaderboardFuture = AuthService.getLeaderboard();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final rank = index + 1;
                final isMe = player['email'] == currentUser?.email;

                return _RankItem(
                  rank: rank,
                  name: player['email'].split('@').first,
                  points: player['points'] ?? 0,
                  xp: player['xp'] ?? 0,
                  quizCount: player['quizCount'] ?? 0,
                  isMe: isMe,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RankItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final int xp;
  final int quizCount;
  final bool isMe;

  const _RankItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.xp,
    required this.quizCount,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMe ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.outlineVariant.withValues(alpha: 0.2),
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          _buildRankBadge(rank),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                    color: isMe ? AppTheme.primary : AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(label: '$xp XP', icon: Icons.stars_rounded, color: AppTheme.gold),
                    const SizedBox(width: 8),
                    _InfoChip(label: '$quizCount Quizzes', icon: Icons.task_alt_rounded, color: AppTheme.secondary),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$points pts',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color bgColor = AppTheme.surfaceContainer;
    Color textColor = AppTheme.textMuted;

    if (rank == 1) {
      bgColor = AppTheme.gold.withValues(alpha: 0.2);
      textColor = AppTheme.gold;
    } else if (rank == 2) {
      bgColor = const Color(0xFFC0C0C0).withValues(alpha: 0.2);
      textColor = const Color(0xFF707070);
    } else if (rank == 3) {
      bgColor = const Color(0xFFCD7F32).withValues(alpha: 0.2);
      textColor = const Color(0xFFCD7F32);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
