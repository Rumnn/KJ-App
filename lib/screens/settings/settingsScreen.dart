import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../providers/authProvider.dart';
import '../../services/hiveService.dart';
import '../../appConfig.dart';
import '../../appTheme.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/auth/login');
  }
  Future<void> _openDonate() async {
    final uri = Uri.parse(AppConfig.donateUrl);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accent, width: 1.5),
                  ),
                  child: const Center(child: Icon(Icons.person_rounded, size: 32, color: AppTheme.accent)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.email ?? 'Not Logged In', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      Text('漢字', style: TextStyle(fontSize: 12, color: AppTheme.success.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('App Information', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          const _SettingsTile(icon: Icons.info_outline_rounded, title: 'Version', trailing: Text(AppConfig.appVersion, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          const Divider(height: 1, color: AppTheme.border),
          const _SettingsTile(icon: Icons.code_rounded, title: 'Made With Flutter', subtitle: 'With FastifyJS'),
          const SizedBox(height: 32),
          const Text('Data & Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear Local Data',
            subtitle: 'Resets Streak & Device Quiz History',
            color: AppTheme.error,
            onTap: () async {
              await HiveService.clearAll();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local Data Cleared')));
            },
          ),
          const Divider(height: 1, color: AppTheme.border),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            onTap: () => _logout(context, ref),
          ),
          const SizedBox(height: 48),
          Center(
            child: ElevatedButton.icon(
              onPressed: _openDonate,
              icon: const Icon(Icons.favorite_rounded, color: AppTheme.error, size: 18),
              label: const Text('Support The Developer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.card,
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.border),
                elevation: 0,
                minimumSize: const Size(200, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color color;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.color = AppTheme.textPrimary, this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
    subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)) : null,
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20) : null),
  );
}