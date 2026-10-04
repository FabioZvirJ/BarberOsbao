import 'package:barber_osbao/features/planos/domain/models/plano.dart';
import 'package:barber_osbao/features/planos/domain/repositories/planos_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpPlanosRepository implements PlanosRepository {
  final DioClient _dioClient;

  HttpPlanosRepository(this._dioClient);

  @override
  Future<List<Plano>> getPlanos() async {
    final response = await _dioClient.dio.get('/plans');
    final data = response.data as List;
    return data.map((json) => Plano.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Plano> createPlano(Plano plano) async {
    final response = await _dioClient.dio.post('/plans', data: plano.toJson());
    return Plano.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Plano> updatePlano(Plano plano) async {
    final response = await _dioClient.dio.put('/plans/${plano.id}', data: plano.toJson());
    return Plano.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deletePlano(String id) async {
    await _dioClient.dio.delete('/plans/$id');
  }
}

