import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kj/l10n/app_localizations.dart';
import 'providers/localeProvider.dart';
import 'appTheme.dart';
import 'router.dart';
class KjApp extends ConsumerWidget {
  const KjApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider).value ?? const Locale('en');
    return MaterialApp.router(
      title: 'KJ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
