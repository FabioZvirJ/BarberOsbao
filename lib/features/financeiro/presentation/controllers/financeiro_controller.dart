import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/repositories/financeiro_repository.dart';
import 'package:barber_osbao/features/financeiro/data/repositories/mock_financeiro_repository.dart';

final financeiroRepositoryProvider = Provider<FinanceiroRepository>((ref) {
  return MockFinanceiroRepository();
});

class TransacoesController extends Notifier<AppState<List<TransacaoFinanceira>>> {
  late final FinanceiroRepository _repository;

  @override
  AppState<List<TransacaoFinanceira>> build() {
    _repository = ref.watch(financeiroRepositoryProvider);
    Future.microtask(() => loadTransacoes());
    return const AppLoading();
  }

  Future<void> loadTransacoes() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getTransacoes();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list.reversed.toList()); // newest first
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addTransacao(TransacaoFinanceira transacao) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createTransacao(transacao);
      state = AppSuccess([created, ...currentData]);
      
      // Recalculate summary metrics
      ref.read(financeSummaryControllerProvider.notifier).loadSummary();
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final transacoesControllerProvider = NotifierProvider<TransacoesController, AppState<List<TransacaoFinanceira>>>(
  () => TransacoesController(),
);

// Summary controller
class FinanceSummaryController extends Notifier<AppState<Map<String, dynamic>>> {
  late final FinanceiroRepository _repository;

  @override
  AppState<Map<String, dynamic>> build() {
    _repository = ref.watch(financeiroRepositoryProvider);
    Future.microtask(() => loadSummary());
    return const AppLoading();
  }

  Future<void> loadSummary() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final summary = await _repository.getFinanceSummary();
      state = AppSuccess(summary);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final financeSummaryControllerProvider = NotifierProvider<FinanceSummaryController, AppState<Map<String, dynamic>>>(
  () => FinanceSummaryController(),
);
