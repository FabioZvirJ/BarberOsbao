import 'dart:convert';
import '../../../shared/models/user.dart';
import '../../../shared/utils/mock_data.dart';
import '../../../core/storage/pref_helper.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PrefHelper _prefHelper;

  AuthRepositoryImpl(this._prefHelper);

  @override
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate delay for loading state
    final cached = _prefHelper.getUserJson();
    if (cached != null) {
      return User.fromJson(jsonDecode(cached));
    }
    // Populate default
    final defaultUser = MockData.loggedUser;
    await _prefHelper.setUserJson(jsonEncode(defaultUser.toJson()));
    return defaultUser;
  }

  @override
  Future<User> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _prefHelper.setUserJson(jsonEncode(user.toJson()));
    await _prefHelper.setTheme(user.theme);
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _prefHelper.clearAll();
  }
}
