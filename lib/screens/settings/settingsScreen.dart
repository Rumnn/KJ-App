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
        title: const Text('Profile Settings'),
        leading: IconButton(
          onPressed: () => context.pop(), 
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary)
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 32, color: AppTheme.primary)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Not Logged In', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JLPT Learner', 
                        style: TextStyle(fontSize: 14, color: AppTheme.secondary.withValues(alpha: 0.8), fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const _SectionHeader(title: 'Account Settings'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'Safely exit your account',
            color: AppTheme.error,
            onTap: () => _logout(context, ref),
          ),
          
          const SizedBox(height: 32),
          const _SectionHeader(title: 'Data Management'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear Local Progress',
            subtitle: 'Resets streak and local history',
            onTap: () async {
              await HiveService.clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress data cleared'))
                );
              }
            },
          ),
          
          const SizedBox(height: 32),
          const _SectionHeader(title: 'Support & Info'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: 'Currently v${AppConfig.appVersion}',
          ),
          _SettingsTile(
            icon: Icons.favorite_outline,
            title: 'Donate',
            subtitle: 'Support the developer',
            onTap: _openDonate,
          ),
          
          const SizedBox(height: 60),
          Center(
            child: Text(
              'MADE WITH ♥ BY ANTIGRAVITY',
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w800, 
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                letterSpacing: 1.5
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w700, 
        color: AppTheme.textMuted, 
        letterSpacing: 1.2
      )
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? AppTheme.onBackground;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: finalColor, size: 24),
        title: Text(
          title, 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: finalColor)
        ),
        subtitle: subtitle != null 
          ? Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)) 
          : null,
        trailing: onTap != null 
          ? const Icon(Icons.chevron_right, color: AppTheme.textMuted) 
          : null,
      ),
    );
  }
}