import 'package:flutter/material.dart';
import 'package:kj/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/authProvider.dart';
import '../../providers/localeProvider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? const Locale('en');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSettings),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
                    child: Icon(Icons.person, size: 32, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? l10n.notLoggedIn,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isAdmin == true ? l10n.admin : l10n.jlptLearner,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: l10n.accountSettings),
          const SizedBox(height: 12),
          if (user?.isAdmin == true)
            _SettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: l10n.adminPanel,
              subtitle: '${l10n.adminUsers} • ${l10n.adminQuizResults}',
              color: AppTheme.primary,
              onTap: () => context.push('/home/admin'),
            ),
          _LanguageTile(
            currentCode: locale.languageCode,
            onChanged: (code) =>
                ref.read(localeProvider.notifier).setLocale(Locale(code)),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.signOut,
            subtitle: l10n.signOutSubtitle,
            color: AppTheme.error,
            onTap: () => _logout(context, ref),
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: l10n.supportInfo),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.appVersion,
            subtitle: l10n.currentlyVersion(AppConfig.appVersion),
          ),
          _SettingsTile(
            icon: Icons.favorite_outline,
            title: l10n.donate,
            subtitle: l10n.donateSubtitle,
            onTap: _openDonate,
          ),
          const SizedBox(height: 60),
          Center(
            child: Text(
              'MADE WITH PKA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onChanged;

  const _LanguageTile({required this.currentCode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded, color: AppTheme.onBackground),
              const SizedBox(width: 16),
              Text(
                l10n.language,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.english)),
                ButtonSegment(value: 'vi', label: Text(l10n.vietnamese)),
              ],
              selected: {currentCode == 'vi' ? 'vi' : 'en'},
              onSelectionChanged: (value) => onChanged(value.first),
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
        letterSpacing: 1.2,
      ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: finalColor),
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
