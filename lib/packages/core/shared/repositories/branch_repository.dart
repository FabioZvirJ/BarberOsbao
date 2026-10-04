import 'package:barber_osbao/packages/core/models/branch.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return BranchRepository(client);
});

class BranchRepository {
  final DioClient _client;

  BranchRepository(this._client);

  Future<List<Branch>> getBranches() async {
    final response = await _client.dio.get('/branches');
    final list = response.data as List;
    return list.map((item) => Branch.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Branch> getBranch(String idOrSlug) async {
    final response = await _client.dio.get('/branches/$idOrSlug');
    return Branch.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Branch> createBranch({
    required String name,
    required String address,
    String? slug,
    String? neighborhood,
    String? city,
    String? state,
    String? phone,
  }) async {
    final response = await _client.dio.post('/branches', data: {
      'name': name,
      'address': address,
      if (slug != null && slug.isNotEmpty) 'slug': slug,
      if (neighborhood != null && neighborhood.isNotEmpty) 'neighborhood': neighborhood,
      'city': city ?? 'Mallet',
      'state': state ?? 'PR',
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return Branch.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Branch> updateBranch(String id, Map<String, dynamic> data) async {
    final response = await _client.dio.put('/branches/$id', data: data);
    return Branch.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBranch(String id) async {
    await _client.dio.delete('/branches/$id');
  }
}
