import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/authService.dart';
import '../models/userModel.dart';
import 'dashboardProvider.dart';
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final user = await AuthService.loadSavedUser();
    if (user != null) {
      AuthService.syncProgress().then((_) {
        if (ref.exists(dashboardProvider)) ref.invalidate(dashboardProvider);
      });
    }
    return user;
  }
  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await AuthService.register(email, password);
      await AuthService.syncProgress();
      if (ref.exists(dashboardProvider)) ref.invalidate(dashboardProvider);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await AuthService.login(email, password);
      await AuthService.syncProgress();
      if (ref.exists(dashboardProvider)) ref.invalidate(dashboardProvider);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  Future<void> logout() async {
    await AuthService.logout();
    state = const AsyncData(null);
  }
}