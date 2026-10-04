import 'package:barber_osbao/features/clientes/domain/models/cliente.dart';
import 'package:barber_osbao/features/clientes/domain/repositories/clientes_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpClientesRepository implements ClientesRepository {
  final DioClient _dioClient;

  HttpClientesRepository(this._dioClient);

  @override
  Future<List<Cliente>> getClientes() async {
    final response = await _dioClient.dio.get('/clients');
    final data = response.data as List;
    return data.map((json) => Cliente.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Cliente> createCliente(Cliente cliente) async {
    final response = await _dioClient.dio.post('/clients', data: cliente.toJson());
    return Cliente.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Cliente> updateCliente(Cliente cliente) async {
    final response = await _dioClient.dio.put('/clients/${cliente.id}', data: cliente.toJson());
    return Cliente.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCliente(String id) async {
    await _dioClient.dio.delete('/clients/$id');
  }
}

