import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/pref_helper.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';
import '../infrastructure/auth_repository_impl.dart';
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
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
