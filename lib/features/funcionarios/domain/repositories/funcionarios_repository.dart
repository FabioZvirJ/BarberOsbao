import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';

abstract class FuncionariosRepository {
  Future<List<Funcionario>> getFuncionarios();
  Future<Funcionario> createFuncionario(Funcionario funcionario);
  Future<Funcionario> updateFuncionario(Funcionario funcionario);
  Future<void> deleteFuncionario(String id);
}
