import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/bill.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/cash_controller.dart';

class BillController extends Notifier<AppState<List<Bill>>> {
  @override
  AppState<List<Bill>> build() {
    Future.microtask(() => loadBills());
    return const AppLoading();
  }

  Future<void> loadBills() async {
    final repository = ref.read(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final list = await repository.getBills();
      state = AppSuccess(list);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addBill(Bill bill) async {
    final repository = ref.read(financeiroRepositoryProvider);
    try {
      final newBill = await repository.saveBill(bill);
      final currentList = state.data ?? [];
      state = AppSuccess([...currentList, newBill]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> updateBill(Bill bill) async {
    final repository = ref.read(financeiroRepositoryProvider);
    try {
      final updated = await repository.saveBill(bill);
      final currentList = state.data ?? [];
      final idx = currentList.indexWhere((c) => c.id == bill.id);
      if (idx != -1) {
        final newList = List<Bill>.from(currentList);
        newList[idx] = updated;
        state = AppSuccess(newList);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> checkoutBill(Bill bill, List<PaymentSplit> payments, double discount) async {
    final repository = ref.read(financeiroRepositoryProvider);
    try {
      // 1. Mark bill as paid
      final updatedBill = bill.copyWith(
        payments: payments,
        discount: discount,
        status: 'paid',
      );
      await repository.saveBill(updatedBill);

      // 2. Register transactions in transactions history for each payment split
      for (final payment in payments) {
        final tx = TransacaoFinanceira(
          id: '',
          type: 'income',
          description: 'Checkout Comanda - ${bill.clientName} (${payment.method.toUpperCase()})',
          amount: payment.amount,
          category: 'Serviço',
          date: bill.date,
          paymentMethod: payment.method == 'pix' ? 'PIX' : (payment.method == 'credit' ? 'Cartão de Crédito' : 'Dinheiro'),
          status: 'paid',
        );
        await ref.read(transacoesControllerProvider.notifier).addTransacao(tx);

        // 3. Register cash movement if paid in cash (money)
        if (payment.method == 'money') {
          await ref.read(cashControllerProvider.notifier).registerMovement(
            'input',
            payment.amount,
            'Fechamento comanda: ${bill.clientName}',
          );
        }
      }

      // Reload bills and financial stats
      await loadBills();
      await ref.read(financeSummaryControllerProvider.notifier).loadSummary();
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final billControllerProvider = NotifierProvider<BillController, AppState<List<Bill>>>(
  () => BillController(),
);
