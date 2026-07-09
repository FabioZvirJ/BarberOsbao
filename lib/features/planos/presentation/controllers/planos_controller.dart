import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/planos/domain/models/plano.dart';
import 'package:barber_osbao/features/planos/domain/repositories/planos_repository.dart';
import 'package:barber_osbao/features/planos/data/repositories/mock_planos_repository.dart';

final planosRepositoryProvider = Provider<PlanosRepository>((ref) {
  return MockPlanosRepository();
});

class PlanosController extends Notifier<AppState<List<Plano>>> {
  late final PlanosRepository _repository;

  @override
  AppState<List<Plano>> build() {
    _repository = ref.watch(planosRepositoryProvider);
    Future.microtask(() => loadPlanos());
    return const AppLoading();
  }

  Future<void> loadPlanos() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getPlanos();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addPlano(Plano plano) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createPlano(plano);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editPlano(Plano plano) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updatePlano(plano);
      state = AppSuccess(currentData.map((p) => p.id == plano.id ? updated : p).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removePlano(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deletePlano(id);
      final updatedList = currentData.where((p) => p.id != id).toList();
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

final planosControllerProvider = NotifierProvider<PlanosController, AppState<List<Plano>>>(
  () => PlanosController(),
);
