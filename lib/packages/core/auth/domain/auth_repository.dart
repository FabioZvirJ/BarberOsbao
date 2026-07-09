import 'package:barber_osbao/packages/core/models/user.dart';

abstract class AuthRepository {
  Future<User> getCurrentUser();
  Future<User> updateUser(User user);
  Future<void> logout();
  Future<User> login(String email, String password);
}
