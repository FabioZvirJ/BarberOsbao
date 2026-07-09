import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/servicos/domain/models/servico.dart';
import 'package:barber_osbao/features/servicos/domain/repositories/servicos_repository.dart';
import 'package:barber_osbao/features/servicos/data/repositories/mock_servicos_repository.dart';

final servicosRepositoryProvider = Provider<ServicosRepository>((ref) {
  return MockServicosRepository();
});

class ServicosController extends Notifier<AppState<List<Servico>>> {
  late final ServicosRepository _repository;

  @override
  AppState<List<Servico>> build() {
    _repository = ref.watch(servicosRepositoryProvider);
    Future.microtask(() => loadServicos());
    return const AppLoading();
  }

  Future<void> loadServicos() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getServicos();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addServico(Servico servico) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createServico(servico);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editServico(Servico servico) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateServico(servico);
      state = AppSuccess(currentData.map((s) => s.id == servico.id ? updated : s).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeServico(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteServico(id);
      final updatedList = currentData.where((s) => s.id != id).toList();
      if (updatedList.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(updatedList);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> updateOrder(List<Servico> reordered) async {
    try {
      state = AppSuccess(reordered);
      await _repository.reorderServicos(reordered);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final servicosControllerProvider = NotifierProvider<ServicosController, AppState<List<Servico>>>(
  () => ServicosController(),
);
