import 'package:barber_osbao/features/clube/domain/models/beneficio_clube.dart';
import 'package:barber_osbao/features/clube/domain/repositories/clube_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpClubeRepository implements ClubeRepository {
  final DioClient _dioClient;

  HttpClubeRepository(this._dioClient);

  @override
  Future<List<BeneficioClube>> getBeneficios() async {
    final response = await _dioClient.dio.get('/club/benefits');
    final data = response.data as List;
    return data.map((json) => BeneficioClube.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<BeneficioClube> createBeneficio(BeneficioClube beneficio) async {
    final response = await _dioClient.dio.post('/club/benefits', data: beneficio.toJson());
    return BeneficioClube.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BeneficioClube> updateBeneficio(BeneficioClube beneficio) async {
    final response = await _dioClient.dio.put('/club/benefits/${beneficio.id}', data: beneficio.toJson());
    return BeneficioClube.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBeneficio(String id) async {
    await _dioClient.dio.delete('/club/benefits/$id');
  }

  @override
  Future<void> reorderBeneficios(List<BeneficioClube> list) async {
    // Local reorder or backend update if desired
  }
}

