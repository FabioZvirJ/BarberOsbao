import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/system_user.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return UsersRepository(client);
});

class UsersRepository {
  final DioClient _client;

  UsersRepository(this._client);

  Future<List<SystemUser>> getUsers({String? role, String? search}) async {
    final response = await _client.dio.get('/users', queryParameters: {
      if (role != null && role.isNotEmpty && role != 'all') 'role': role,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = response.data as List;
    return list.map((item) => SystemUser.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<SystemUser> createUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'client',
  }) async {
    final response = await _client.dio.post('/users', data: {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
      'role': role,
    });
    return SystemUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SystemUser> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _client.dio.put('/users/$id', data: data);
    return SystemUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    await _client.dio.delete('/users/$id');
  }
}

