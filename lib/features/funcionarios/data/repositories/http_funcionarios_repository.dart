import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';
import 'package:barber_osbao/features/funcionarios/domain/repositories/funcionarios_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpFuncionariosRepository implements FuncionariosRepository {
  final DioClient _dioClient;

  HttpFuncionariosRepository(this._dioClient);

  @override
  Future<List<Funcionario>> getFuncionarios() async {
    final response = await _dioClient.dio.get('/employees');
    final data = response.data as List;
    return data.map((json) => Funcionario.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Funcionario> createFuncionario(Funcionario funcionario) async {
    final response = await _dioClient.dio.post('/employees', data: funcionario.toJson());
    return Funcionario.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Funcionario> updateFuncionario(Funcionario funcionario) async {
    final response = await _dioClient.dio.put('/employees/${funcionario.id}', data: funcionario.toJson());
    return Funcionario.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFuncionario(String id) async {
    await _dioClient.dio.delete('/employees/$id');
  }
}

