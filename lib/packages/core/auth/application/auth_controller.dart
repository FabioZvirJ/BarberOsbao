import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:barber_osbao/packages/core/models/user.dart';
import 'package:barber_osbao/packages/core/auth/domain/auth_repository.dart';
import 'package:barber_osbao/packages/core/auth/infrastructure/auth_repository_impl.dart';

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
  final client = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(helper, client);
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

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email, password);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> loginWithGoogle({
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.loginWithGoogle(
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> loginWithPhone({
    required String phone,
    String? name,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.loginWithPhone(
        phone: phone,
        name: name,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> loginAsGuest({String? name}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.loginAsGuest(name: name);
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      return null;
    });
  }

  Future<void> updateUser(User updatedUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.updateUser(updatedUser);
    });
  }

  Future<void> toggleTheme() async {
    final currentUser = state.value;
    if (currentUser != null) {
      final newTheme = currentUser.theme == 'light' ? 'dark' : 'light';
      final updated = currentUser.copyWith(theme: newTheme);
      await updateUser(updated);
    }
  }

  Future<void> setTheme(String newTheme) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updated = currentUser.copyWith(theme: newTheme);
      await updateUser(updated);
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
