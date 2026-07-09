import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/domain/models/movimentacao.dart';
import 'package:barber_osbao/features/produtos/domain/repositories/produtos_repository.dart';
import 'package:barber_osbao/features/produtos/data/repositories/mock_produtos_repository.dart';

final produtosRepositoryProvider = Provider<ProdutosRepository>((ref) {
  return MockProdutosRepository();
});

class ProdutosController extends Notifier<AppState<List<Produto>>> {
  late final ProdutosRepository _repository;

  @override
  AppState<List<Produto>> build() {
    _repository = ref.watch(produtosRepositoryProvider);
    Future.microtask(() => loadProdutos());
    return const AppLoading();
  }

  Future<void> loadProdutos() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getProdutos();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addProduto(Produto produto) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createProduto(produto);
      state = AppSuccess([...currentData, created]);
      
      // Refresh stock movements
      ref.read(movimentacoesControllerProvider.notifier).loadMovimentacoes();
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editProduto(Produto produto) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateProduto(produto);
      state = AppSuccess(currentData.map((p) => p.id == produto.id ? updated : p).toList());
      
      // Refresh stock movements
      ref.read(movimentacoesControllerProvider.notifier).loadMovimentacoes();
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeProduto(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteProduto(id);
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

final produtosControllerProvider = NotifierProvider<ProdutosController, AppState<List<Produto>>>(
  () => ProdutosController(),
);

// Stock movements controller
class MovimentacoesController extends Notifier<AppState<List<MovimentacaoEstoque>>> {
  late final ProdutosRepository _repository;

  @override
  AppState<List<MovimentacaoEstoque>> build() {
    _repository = ref.watch(produtosRepositoryProvider);
    Future.microtask(() => loadMovimentacoes());
    return const AppLoading();
  }

  Future<void> loadMovimentacoes() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getMovimentacoes();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list.reversed.toList()); // show newest first
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addMovimentacao(String productId, String productName, String type, int qty, String reason) async {
    try {
      final newMovement = MovimentacaoEstoque(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        productName: productName,
        type: type,
        qty: qty,
        reason: reason,
        date: '09/07/2026',
        user: 'Fábio Zvir',
      );
      await _repository.recordMovement(newMovement);
      
      // Reload both products & movements
      await loadMovimentacoes();
      await ref.read(produtosControllerProvider.notifier).loadProdutos();
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final movimentacoesControllerProvider = NotifierProvider<MovimentacoesController, AppState<List<MovimentacaoEstoque>>>(
  () => MovimentacoesController(),
);
