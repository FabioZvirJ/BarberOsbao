import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:barber_osbao/packages/core/models/user.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PrefHelper _prefHelper;
  final DioClient _dioClient;

  AuthRepositoryImpl(this._prefHelper, this._dioClient);

  User _parseUserFromBackend(Map<String, dynamic> data, {String? theme}) {
    return User(
      id: data['id']?.toString() ?? '',
      name: (data['name']?.toString() ?? 'Usuário').trim(),
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      avatarUrl: (data['avatarUrl'] != null && data['avatarUrl'].toString().isNotEmpty)
          ? data['avatarUrl'].toString()
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      theme: theme ?? _prefHelper.getTheme(),
      language: 'pt-BR',
      emailNotifications: true,
      pushNotifications: true,
      whatsappNotifications: false,
      role: (data['role']?.toString() ?? 'client').toLowerCase(),
    );
  }

  Future<User> _saveSession(String token, Map<String, dynamic> userData) async {
    await _prefHelper.setToken(token);
    final user = _parseUserFromBackend(userData);
    await _prefHelper.setUserJson(jsonEncode(user.toJson()));
    await _prefHelper.setTheme(user.theme);
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = _prefHelper.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final cachedJson = _prefHelper.getUserJson();
    if (cachedJson != null) {
      try {
        final localUser = User.fromJson(jsonDecode(cachedJson));
        return localUser;
      } catch (_) {}
    }

    // Tenta validar com a API /auth/me se não houver cache
    try {
      final response = await _dioClient.dio.get('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        final user = _parseUserFromBackend(response.data);
        await _prefHelper.setUserJson(jsonEncode(user.toJson()));
        return user;
      }
    } catch (_) {
      // Se o token estiver expirado ou inválido
      await _prefHelper.clearAuth();
    }
    return null;
  }

  @override
  Future<User> updateUser(User user) async {
    await _prefHelper.setUserJson(jsonEncode(user.toJson()));
    await _prefHelper.setTheme(user.theme);
    return user;
  }

  @override
  Future<void> logout() async {
    await _prefHelper.clearAuth();
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;
      return await _saveSession(token, userData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?.toString() ?? 'Falha ao autenticar';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone?.trim(),
          'role': role ?? 'client',
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;
      return await _saveSession(token, userData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?.toString() ?? 'Falha ao criar conta';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<User> loginWithGoogle({
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/google',
        data: {
          'email': email.trim().toLowerCase(),
          'name': name.trim(),
          'avatarUrl': avatarUrl,
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;
      return await _saveSession(token, userData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?.toString() ?? 'Falha ao conectar com Google';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<User> loginWithPhone({
    required String phone,
    String? name,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/phone',
        data: {
          'phone': phone.trim(),
          'name': name?.trim(),
        },
      );

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;
      return await _saveSession(token, userData);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?.toString() ?? 'Falha ao autenticar por celular';
      throw Exception(errorMsg);
    }
  }
}
