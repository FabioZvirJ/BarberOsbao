import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/comanda.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';

class ComandaController extends Notifier<AppState<List<Comanda>>> {
  @override
  AppState<List<Comanda>> build() {
    Future.microtask(() => loadComandas());
    return const AppLoading();
  }

  Future<void> loadComandas() async {
    final repository = ref.watch(financeiroRepositoryProvider);
    state = const AppLoading();
    try {
      final list = await repository.getComandas();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addComanda(Comanda comanda) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    final currentList = state.data ?? [];
    try {
      final saved = await repository.saveComanda(comanda);
      state = AppSuccess([...currentList, saved]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> updateComanda(Comanda comanda) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    final currentList = state.data ?? [];
    try {
      final saved = await repository.saveComanda(comanda);
      state = AppSuccess(currentList.map((c) => c.id == saved.id ? saved : c).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> checkoutComanda(Comanda comanda, List<PagamentoSplit> splitPayments, double discount) async {
    final repository = ref.watch(financeiroRepositoryProvider);
    
    // Update comanda status and payments
    final updated = comanda.copyWith(
      status: 'paid',
      discount: discount,
      pagamentos: splitPayments,
    );

    await updateComanda(updated);

    // Register financial transaction(s)
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    for (final payment in splitPayments) {
      final tx = TransacaoFinanceira(
        id: '',
        type: 'income',
        description: 'Venda Comanda #${updated.id} - ${updated.clienteNome}',
        amount: payment.amount,
        category: 'Serviço',
        date: todayStr,
        paymentMethod: _translatePaymentMethod(payment.method),
        status: 'paid',
      );
      await ref.read(transacoesControllerProvider.notifier).addTransacao(tx);
    }
  }

  String _translatePaymentMethod(String method) {
    switch (method) {
      case 'pix':
        return 'PIX';
      case 'credit':
        return 'Cartão de Crédito';
      case 'debit':
        return 'Cartão de Débito';
      case 'money':
      default:
        return 'Dinheiro';
    }
  }
}

final comandaControllerProvider = NotifierProvider<ComandaController, AppState<List<Comanda>>>(
  () => ComandaController(),
);
