import 'dart:convert';
import 'package:barber_osbao/packages/core/models/user.dart';
import 'package:barber_osbao/packages/core/utils/mock_data.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/auth/domain/auth_repository.dart';

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

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    User loggedInUser;
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == 'admin@barberosbao.com.br' || normalizedEmail == 'admin' || normalizedEmail == 'fabio@barberosbao.com.br') {
      loggedInUser = User(
        id: 'usr_admin',
        name: 'Fabio Zvir (Admin)',
        email: 'admin@barberosbao.com.br',
        phone: '(11) 99999-9999',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
        theme: 'dark',
        language: 'pt-BR',
        emailNotifications: true,
        pushNotifications: true,
        whatsappNotifications: false,
        role: 'admin',
      );
    } else {
      loggedInUser = User(
        id: 'usr_client',
        name: 'Fabio Zvir (Cliente)',
        email: email.isNotEmpty ? email : 'cliente@barberosbao.com.br',
        phone: '(11) 99999-9999',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
        theme: 'dark',
        language: 'pt-BR',
        emailNotifications: true,
        pushNotifications: true,
        whatsappNotifications: false,
        role: 'client',
      );
    }
    
    await _prefHelper.setUserJson(jsonEncode(loggedInUser.toJson()));
    await _prefHelper.setTheme(loggedInUser.theme);
    return loggedInUser;
  }
}
