import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/caixa_turno.dart';
import 'package:barber_osbao/features/financeiro/domain/repositories/financeiro_repository.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';

class CaixaController extends Notifier<AppState<CaixaTurno?>> {
  @override
  AppState<CaixaTurno?> build() {
    Future.microtask(() => loadActiveCaixa());
    return const AppLoading();
  }

  Future<void> loadActiveCaixa() async {
    final repository = ref.watch(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final active = await repository.getActiveCaixa();
      state = AppSuccess(active);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> abrir(double saldoInicial) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final active = await repository.abrirCaixa(saldoInicial);
      state = AppSuccess(active);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> fechar(double saldoFinal, double dinheiroInformado) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      await repository.fecharCaixa(saldoFinal, dinheiroInformado);
      state = const AppSuccess(null); // No active caixa after closing
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> registrarMovimentacao(String type, double amount, String description) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    final active = state.data;
    if (active == null) {
      throw Exception('Caixa fechado. Abra o caixa primeiro.');
    }

    try {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final movimento = MovimentoCaixa(
        id: '',
        caixaId: active.id,
        type: type,
        amount: amount,
        description: description,
        time: timeStr,
        user: 'Fábio Zvir',
      );

      await repository.addMovimentoCaixa(movimento);
      // Trigger update to refresh cache/UI if needed
      ref.read(movimentosCaixaControllerProvider.notifier).loadMovimentos(active.id);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final caixaControllerProvider = NotifierProvider<CaixaController, AppState<CaixaTurno?>>(
  () => CaixaController(),
);

// Controller for shifts history / movements
class MovimentosCaixaController extends Notifier<AppState<List<MovimentoCaixa>>> {
  @override
  AppState<List<MovimentoCaixa>> build() {
    final caixaState = ref.watch(caixaControllerProvider);
    final activeCaixa = caixaState.data;

    if (activeCaixa == null) {
      return const AppSuccess([]);
    }

    Future.microtask(() => loadMovimentos(activeCaixa.id));
    return const AppLoading();
  }

  Future<void> loadMovimentos(String caixaId) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    try {
      final list = await repository.getMovimentosCaixa(caixaId);
      state = AppSuccess(list);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final movimentosCaixaControllerProvider = NotifierProvider<MovimentosCaixaController, AppState<List<MovimentoCaixa>>>(
  () => MovimentosCaixaController(),
);
