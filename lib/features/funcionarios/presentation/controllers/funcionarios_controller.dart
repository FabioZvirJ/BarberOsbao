import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';
import 'package:barber_osbao/features/funcionarios/domain/repositories/funcionarios_repository.dart';
import 'package:barber_osbao/features/funcionarios/data/repositories/mock_funcionarios_repository.dart';

final funcionariosRepositoryProvider = Provider<FuncionariosRepository>((ref) {
  return MockFuncionariosRepository();
});

class FuncionariosController extends Notifier<AppState<List<Funcionario>>> {
  late final FuncionariosRepository _repository;

  @override
  AppState<List<Funcionario>> build() {
    _repository = ref.watch(funcionariosRepositoryProvider);
    Future.microtask(() => loadFuncionarios());
    return const AppLoading();
  }

  Future<void> loadFuncionarios() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getFuncionarios();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addFuncionario(Funcionario funcionario) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createFuncionario(funcionario);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editFuncionario(Funcionario funcionario) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateFuncionario(funcionario);
      state = AppSuccess(currentData.map((f) => f.id == funcionario.id ? updated : f).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeFuncionario(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteFuncionario(id);
      final updatedList = currentData.where((f) => f.id != id).toList();
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

final funcionariosControllerProvider = NotifierProvider<FuncionariosController, AppState<List<Funcionario>>>(
  () => FuncionariosController(),
);
