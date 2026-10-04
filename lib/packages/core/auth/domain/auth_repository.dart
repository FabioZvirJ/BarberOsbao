import 'package:barber_osbao/packages/core/models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> updateUser(User user);
  Future<void> logout();
  Future<User> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  });
  Future<User> loginWithGoogle({
    required String email,
    required String name,
    String? avatarUrl,
  });
  Future<User> loginWithPhone({
    required String phone,
    String? name,
  });
}
