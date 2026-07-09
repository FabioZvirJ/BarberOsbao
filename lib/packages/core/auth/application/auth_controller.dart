import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/models/user.dart';
import 'package:barber_osbao/packages/core/auth/domain/auth_repository.dart';
import 'package:barber_osbao/packages/core/auth/infrastructure/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// Provider for PrefHelper
final prefHelperProvider = Provider<PrefHelper>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrefHelper(prefs);
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final helper = ref.watch(prefHelperProvider);
  return AuthRepositoryImpl(helper);
});

// Controller to manage logged-in User
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    try {
      return await repo.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.updateUser(updatedUser);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      return null;
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email, password);
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
