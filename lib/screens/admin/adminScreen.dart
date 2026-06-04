import 'package:flutter/material.dart';
import 'package:kj/l10n/app_localizations.dart';
import '../../services/adminService.dart';
import '../../appTheme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;
  late Future<Map<String, dynamic>> _usersFuture;
  late Future<Map<String, dynamic>> _quizFuture;
  final _searchCtrl = TextEditingController();
  String _role = '';
  String _status = '';
  String _level = '';

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refreshAll() {
    _summaryFuture = AdminService.getSummary();
    _usersFuture = AdminService.getUsers();
    _quizFuture = AdminService.getQuizResults();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = AdminService.getUsers(
        search: _searchCtrl.text.trim(),
        role: _role,
        status: _status,
      );
      _summaryFuture = AdminService.getSummary();
    });
  }

  void _refreshQuiz() {
    setState(() {
      _quizFuture = AdminService.getQuizResults(level: _level);
      _summaryFuture = AdminService.getSummary();
    });
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AdminService.handleError(error))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminPanel),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.adminOverview, icon: const Icon(Icons.analytics_outlined)),
              Tab(text: l10n.adminUsers, icon: const Icon(Icons.people_outline)),
              Tab(text: l10n.adminQuizResults, icon: const Icon(Icons.fact_check_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(summaryFuture: _summaryFuture),
            _UsersTab(
              usersFuture: _usersFuture,
              searchCtrl: _searchCtrl,
              role: _role,
              status: _status,
              onRoleChanged: (value) {
                _role = value;
                _refreshUsers();
              },
              onStatusChanged: (value) {
                _status = value;
                _refreshUsers();
              },
              onSearch: _refreshUsers,
              onUserTap: _openUserSheet,
            ),
            _QuizTab(
              quizFuture: _quizFuture,
              level: _level,
              onLevelChanged: (value) {
                _level = value;
                _refreshQuiz();
              },
              onDelete: _deleteQuizResult,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUserSheet(Map<String, dynamic> user) async {
    final l10n = AppLocalizations.of(context)!;
    final id = user['_id'] as String;
    try {
      final detail = await AdminService.getUserDetail(id);
      if (!mounted) return;
      final current = Map<String, dynamic>.from(detail['user'] as Map);
      final results = List<Map<String, dynamic>>.from(detail['quizResults'] as List);
      String role = current['role'] as String? ?? 'user';
      String status = current['status'] as String? ?? 'active';

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current['email'] as String? ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  _OptionRow(
                    label: l10n.role,
                    value: role,
                    values: const ['user', 'admin'],
                    labels: [l10n.user, l10n.admin],
                    onChanged: (value) => setSheetState(() => role = value),
                  ),
                  const SizedBox(height: 12),
                  _OptionRow(
                    label: l10n.status,
                    value: status,
                    values: const ['active', 'blocked'],
                    labels: [l10n.active, l10n.blocked],
                    onChanged: (value) => setSheetState(() => status = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            try {
                              await AdminService.updateUser(id, role: role, status: status);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              _refreshUsers();
                            } catch (error) {
                              _showError(error);
                            }
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: Text(l10n.save),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () async {
                          if (!await _confirm(l10n.deleteUser, l10n.confirmDeleteUser)) return;
                          try {
                            await AdminService.deleteUser(id);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _refreshUsers();
                          } catch (error) {
                            _showError(error);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.adminQuizResults,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...results.take(8).map((result) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${result['level']}  ${result['score']}/${result['total']}'),
                        subtitle: Text(result['date'] as String? ?? ''),
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteQuizResult(String id) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirm(l10n.deleteQuizResult, l10n.confirmDeleteQuizResult)) return;
    try {
      await AdminService.deleteQuizResult(id);
      _refreshQuiz();
    } catch (error) {
      _showError(error);
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final Future<Map<String, dynamic>> summaryFuture;

  const _OverviewTab({required this.summaryFuture});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<Map<String, dynamic>>(
      future: summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final topUsers = List<Map<String, dynamic>>.from(data['topUsers'] as List? ?? const []);
        final cards = [
          (l10n.totalUsers, data['totalUsers'] ?? 0, Icons.people_outline, AppTheme.primary),
          (l10n.activeUsers, data['activeUsers'] ?? 0, Icons.verified_user_outlined, AppTheme.secondary),
          (l10n.blockedUsers, data['blockedUsers'] ?? 0, Icons.block_outlined, AppTheme.error),
          (l10n.adminQuizResults, data['totalQuizResults'] ?? 0, Icons.quiz_outlined, AppTheme.gold),
          (l10n.totalXp, data['totalXp'] ?? 0, Icons.stars_outlined, AppTheme.accent),
          (l10n.totalPoints, data['totalPoints'] ?? 0, Icons.emoji_events_outlined, AppTheme.tertiary),
        ];
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _MetricCard(title: card.$1, value: '${card.$2}', icon: card.$3, color: card.$4);
                },
              ),
              const SizedBox(height: 20),
              Text(l10n.communityRankings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...topUsers.map((user) => _UserTile(user: user, onTap: null)),
            ],
          ),
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  final Future<Map<String, dynamic>> usersFuture;
  final TextEditingController searchCtrl;
  final String role;
  final String status;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onSearch;
  final ValueChanged<Map<String, dynamic>> onUserTap;

  const _UsersTab({
    required this.usersFuture,
    required this.searchCtrl,
    required this.role,
    required this.status,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onSearch,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: l10n.searchUsers,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(onPressed: onSearch, icon: const Icon(Icons.arrow_forward)),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(label: l10n.all, selected: role.isEmpty, onTap: () => onRoleChanged('')),
              _FilterChip(label: l10n.user, selected: role == 'user', onTap: () => onRoleChanged('user')),
              _FilterChip(label: l10n.admin, selected: role == 'admin', onTap: () => onRoleChanged('admin')),
              const SizedBox(width: 12),
              _FilterChip(label: l10n.active, selected: status == 'active', onTap: () => onStatusChanged(status == 'active' ? '' : 'active')),
              _FilterChip(label: l10n.blocked, selected: status == 'blocked', onTap: () => onStatusChanged(status == 'blocked' ? '' : 'blocked')),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: usersFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.hasError) return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                return const Center(child: CircularProgressIndicator());
              }
              final users = List<Map<String, dynamic>>.from(snapshot.data!['items'] as List? ?? const []);
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: users.length,
                itemBuilder: (context, index) => _UserTile(
                  user: users[index],
                  onTap: () => onUserTap(users[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuizTab extends StatelessWidget {
  final Future<Map<String, dynamic>> quizFuture;
  final String level;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String> onDelete;

  const _QuizTab({
    required this.quizFuture,
    required this.level,
    required this.onLevelChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: ['', 'N5', 'N4', 'N3', 'N2', 'N1']
                .map((item) => _FilterChip(
                      label: item.isEmpty ? l10n.all : item,
                      selected: level == item,
                      onTap: () => onLevelChanged(item),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: quizFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.hasError) return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                return const Center(child: CircularProgressIndicator());
              }
              final results = List<Map<String, dynamic>>.from(snapshot.data!['items'] as List? ?? const []);
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final user = result['userId'] is Map ? Map<String, dynamic>.from(result['userId'] as Map) : null;
                  return Card(
                    child: ListTile(
                      title: Text('${result['level']}  ${result['score']}/${result['total']}'),
                      subtitle: Text('${user?['email'] ?? 'Unknown'}\n${result['date'] ?? ''}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(result['_id'] as String),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'user';
    final status = user['status'] as String? ?? 'active';
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(role == 'admin' ? 'A' : 'U')),
        title: Text(user['email'] as String? ?? ''),
        subtitle: Text('$role • $status • ${user['quizCount'] ?? 0} quiz'),
        trailing: Text('${user['points'] ?? 0} pts'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}

class _OptionRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final List<String> labels;
  final ValueChanged<String> onChanged;

  const _OptionRow({
    required this.label,
    required this.value,
    required this.values,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: SegmentedButton<String>(
              segments: [
                for (var i = 0; i < values.length; i++)
                  ButtonSegment(value: values[i], label: Text(labels[i])),
              ],
              selected: {value},
              onSelectionChanged: (next) => onChanged(next.first),
            ),
          ),
        ],
      );
}
