import '../../../../shared/models/user.dart';

abstract class AuthRepository {
  Future<User> getCurrentUser();
  Future<User> updateUser(User user);
  Future<void> logout();
}
