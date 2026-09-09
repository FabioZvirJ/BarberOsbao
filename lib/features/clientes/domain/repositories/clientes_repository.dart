import 'package:barber_osbao/features/clientes/domain/models/cliente.dart';

abstract class ClientesRepository {
  Future<List<Cliente>> getClientes();
  Future<Cliente> createCliente(Cliente cliente);
  Future<Cliente> updateCliente(Cliente cliente);
  Future<void> deleteCliente(String id);
}
