import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(() => LocaleNotifier());

class LocaleNotifier extends AsyncNotifier<Locale> {
  static const _key = 'appLocale';

  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    state = AsyncData(locale);
  }
}
