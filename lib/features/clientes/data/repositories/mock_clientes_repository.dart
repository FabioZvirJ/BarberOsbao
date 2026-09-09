import 'package:barber_osbao/features/clientes/domain/models/cliente.dart';
import 'package:barber_osbao/features/clientes/domain/repositories/clientes_repository.dart';

class MockClientesRepository implements ClientesRepository {
  final List<Cliente> _clientes = [
    const Cliente(
      id: 'c_1',
      name: 'Ana Silva',
      email: 'ana@example.com',
      phone: '(11) 98888-8888',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&width=150',
      nascimento: '12/05/1995',
      plano: 'Plano Barão',
      ultimaVisita: '08/07/2026',
      totalGasto: 480.00,
      observacoes: 'Prefere corte com tesoura nas pontas.',
      status: 'active',
    ),
    const Cliente(
      id: 'c_2',
      name: 'Bruno Gomes',
      email: 'bruno@example.com',
      phone: '(11) 97777-7777',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&width=150',
      nascimento: '22/10/1988',
      plano: 'Nenhum',
      ultimaVisita: '06/07/2026',
      totalGasto: 120.00,
      observacoes: 'Gosta de café expresso.',
      status: 'active',
    ),
    const Cliente(
      id: 'c_3',
      name: 'Carlos Sousa',
      email: 'carlos@example.com',
      phone: '(11) 96666-6666',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&width=150',
      nascimento: '05/02/1992',
      plano: 'Plano Cavalheiro',
      ultimaVisita: '28/06/2026',
      totalGasto: 350.00,
      observacoes: 'Sempre faz design de sobrancelha.',
      status: 'active',
    ),
    const Cliente(
      id: 'c_4',
      name: 'Diego Lima',
      email: 'diego@example.com',
      phone: '(11) 95555-5555',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&width=150',
      nascimento: '14/07/1990',
      plano: 'Plano Imperial',
      ultimaVisita: '02/07/2026',
      totalGasto: 920.00,
      observacoes: 'Cabelo afro, corte degradê baixo.',
      status: 'active',
    ),
    const Cliente(
      id: 'c_5',
      name: 'Eduardo Rocha',
      email: 'edu@example.com',
      phone: '(11) 94444-4444',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&width=150',
      nascimento: '30/12/1985',
      plano: 'Nenhum',
      ultimaVisita: '15/06/2026',
      totalGasto: 75.00,
      observacoes: 'Não gosta de toalha quente na barba.',
      status: 'inactive',
    ),
  ];

  @override
  Future<List<Cliente>> getClientes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_clientes);
  }

  @override
  Future<Cliente> createCliente(Cliente cliente) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newCliente = cliente.copyWith(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      ultimaVisita: 'Nunca',
      totalGasto: 0.0,
    );
    _clientes.add(newCliente);
    return newCliente;
  }

  @override
  Future<Cliente> updateCliente(Cliente cliente) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index != -1) {
      _clientes[index] = cliente;
      return cliente;
    }
    throw Exception('Cliente não encontrado');
  }

  @override
  Future<void> deleteCliente(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _clientes.removeWhere((c) => c.id == id);
  }
}
