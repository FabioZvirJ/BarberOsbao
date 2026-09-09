import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/clube/domain/models/beneficio_clube.dart';
import 'package:barber_osbao/features/clube/domain/repositories/clube_repository.dart';
import 'package:barber_osbao/features/clube/data/repositories/mock_clube_repository.dart';

final clubeRepositoryProvider = Provider<ClubeRepository>((ref) {
  return MockClubeRepository();
});

class ClubeController extends Notifier<AppState<List<BeneficioClube>>> {
  late final ClubeRepository _repository;

  @override
  AppState<List<BeneficioClube>> build() {
    _repository = ref.watch(clubeRepositoryProvider);
    Future.microtask(() => loadBeneficios());
    return const AppLoading();
  }

  Future<void> loadBeneficios() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getBeneficios();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addBeneficio(BeneficioClube beneficio) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createBeneficio(beneficio);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editBeneficio(BeneficioClube beneficio) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateBeneficio(beneficio);
      state = AppSuccess(currentData.map((b) => b.id == beneficio.id ? updated : b).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeBeneficio(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteBeneficio(id);
      final updatedList = currentData.where((b) => b.id != id).toList();
      if (updatedList.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(updatedList);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> updateOrder(List<BeneficioClube> reordered) async {
    try {
      state = AppSuccess(reordered);
      await _repository.reorderBeneficios(reordered);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final clubeControllerProvider = NotifierProvider<ClubeController, AppState<List<BeneficioClube>>>(
  () => ClubeController(),
);
