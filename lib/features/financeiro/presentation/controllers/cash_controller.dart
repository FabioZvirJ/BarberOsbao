import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/cash_shift.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';

class CashController extends Notifier<AppState<CashShift?>> {
  @override
  AppState<CashShift?> build() {
    Future.microtask(() => loadActiveCashShift());
    return const AppLoading();
  }

  Future<void> loadActiveCashShift() async {
    final repository = ref.read(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final active = await repository.getActiveCashShift();
      state = AppSuccess(active);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> open(double initialBalance) async {
    final repository = ref.read(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final active = await repository.openCashShift(initialBalance);
      state = AppSuccess(active);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> close(double finalBalance, double reportedCash) async {
    final repository = ref.read(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final closed = await repository.closeCashShift(finalBalance, reportedCash);
      state = AppSuccess(null); // No active shift after close
      
      // Also register this close transaction on general finance history
      final tx = TransacaoFinanceira(
        id: '',
        type: 'income',
        description: 'Fechamento de Caixa - Turno Concluído',
        amount: finalBalance,
        category: 'Outros',
        date: closed.closeDate ?? '',
        paymentMethod: 'Dinheiro',
        status: 'paid',
      );
      await ref.read(transacoesControllerProvider.notifier).addTransacao(tx);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> registerMovement(String type, double amount, String description) async {
    final repository = ref.read(financeiroRepositoryProvider);
    final active = state.data;

    if (active == null) {
      throw Exception('Caixa fechado. Abra o caixa primeiro.');
    }

    try {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final movement = CashMovement(
        id: '',
        cashShiftId: active.id,
        type: type,
        amount: amount,
        description: description,
        time: timeStr,
        user: 'Fábio Zvir',
      );

      await repository.addCashMovement(movement);
      // Trigger update to refresh movements list
      ref.read(cashMovementsControllerProvider.notifier).loadMovements(active.id);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final cashControllerProvider = NotifierProvider<CashController, AppState<CashShift?>>(
  () => CashController(),
);

// Controller for shifts history / movements
class CashMovementsController extends Notifier<AppState<List<CashMovement>>> {
  @override
  AppState<List<CashMovement>> build() {
    final cashState = ref.watch(cashControllerProvider);
    final activeCash = cashState.data;

    if (activeCash == null) {
      return const AppSuccess([]);
    }

    Future.microtask(() => loadMovements(activeCash.id));
    return const AppLoading();
  }

  Future<void> loadMovements(String cashShiftId) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    try {
      final list = await repository.getCashMovements(cashShiftId);
      state = AppSuccess(list);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final cashMovementsControllerProvider = NotifierProvider<CashMovementsController, AppState<List<CashMovement>>>(
  () => CashMovementsController(),
);
