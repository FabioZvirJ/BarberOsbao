import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/system_user.dart';
import 'package:barber_osbao/packages/core/shared/repositories/users_repository.dart';

final usersProvider = AsyncNotifierProvider<UsersController, List<SystemUser>>(
  () => UsersController(),
);

class UsersController extends AsyncNotifier<List<SystemUser>> {
  @override
  Future<List<SystemUser>> build() async {
    final repo = ref.watch(usersRepositoryProvider);
    try {
      return await repo.getUsers();
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(usersRepositoryProvider);
      return await repo.getUsers();
    });
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'client',
  }) async {
    final repo = ref.read(usersRepositoryProvider);
    await repo.createUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    await refresh();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final repo = ref.read(usersRepositoryProvider);
    await repo.updateUser(id, data);
    await refresh();
  }

  Future<void> deleteUser(String id) async {
    final repo = ref.read(usersRepositoryProvider);
    await repo.deleteUser(id);
    await refresh();
  }
}

