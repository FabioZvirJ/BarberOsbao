import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/clientes/domain/models/cliente.dart';
import 'package:barber_osbao/features/clientes/domain/repositories/clientes_repository.dart';
import 'package:barber_osbao/features/clientes/data/repositories/mock_clientes_repository.dart';

final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  return MockClientesRepository();
});

class ClientesController extends Notifier<AppState<List<Cliente>>> {
  late final ClientesRepository _repository;

  @override
  AppState<List<Cliente>> build() {
    _repository = ref.watch(clientesRepositoryProvider);
    Future.microtask(() => loadClientes());
    return const AppLoading();
  }

  Future<void> loadClientes() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getClientes();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addCliente(Cliente cliente) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createCliente(cliente);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editCliente(Cliente cliente) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateCliente(cliente);
      state = AppSuccess(currentData.map((c) => c.id == cliente.id ? updated : c).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeCliente(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteCliente(id);
      final updatedList = currentData.where((c) => c.id != id).toList();
      if (updatedList.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(updatedList);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final clientesControllerProvider = NotifierProvider<ClientesController, AppState<List<Cliente>>>(
  () => ClientesController(),
);
