import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/categorias/domain/models/categoria.dart';
import 'package:barber_osbao/features/categorias/domain/repositories/categorias_repository.dart';
import 'package:barber_osbao/features/categorias/data/repositories/mock_categorias_repository.dart';

final categoriasRepositoryProvider = Provider<CategoriasRepository>((ref) {
  return MockCategoriasRepository();
});

class CategoriasController extends Notifier<AppState<List<Categoria>>> {
  late final CategoriasRepository _repository;

  @override
  AppState<List<Categoria>> build() {
    _repository = ref.watch(categoriasRepositoryProvider);
    Future.microtask(() => loadCategorias());
    return const AppLoading();
  }

  Future<void> loadCategorias() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getCategorias();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addCategoria(String nome, String tipo) async {
    try {
      final currentData = state.data ?? [];
      final newCat = Categoria(id: '', nome: nome, tipo: tipo);
      final created = await _repository.createCategoria(newCat);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editCategoria(Categoria cat) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateCategoria(cat);
      state = AppSuccess(currentData.map((c) => c.id == cat.id ? updated : c).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeCategoria(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteCategoria(id);
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

final categoriasControllerProvider = NotifierProvider<CategoriasController, AppState<List<Categoria>>>(
  () => CategoriasController(),
);
