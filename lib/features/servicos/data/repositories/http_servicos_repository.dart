import 'package:barber_osbao/features/servicos/domain/models/servico.dart';
import 'package:barber_osbao/features/servicos/domain/repositories/servicos_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpServicosRepository implements ServicosRepository {
  final DioClient _dioClient;

  HttpServicosRepository(this._dioClient);

  @override
  Future<List<Servico>> getServicos() async {
    final response = await _dioClient.dio.get('/services');
    final data = response.data as List;
    return data.map((json) => Servico.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Servico> createServico(Servico servico) async {
    final response = await _dioClient.dio.post('/services', data: servico.toJson());
    return Servico.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Servico> updateServico(Servico servico) async {
    final response = await _dioClient.dio.put('/services/${servico.id}', data: servico.toJson());
    return Servico.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteServico(String id) async {
    await _dioClient.dio.delete('/services/$id');
  }

  @override
  Future<void> reorderServicos(List<Servico> servicos) async {
    await _dioClient.dio.put(
      '/services/reorder',
      data: {
        'serviceIds': servicos.map((s) => s.id).toList(),
      },
    );
  }
}

