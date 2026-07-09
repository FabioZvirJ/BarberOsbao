import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/finance_entry.dart';

abstract class FinanceRepository {
  Future<List<FinanceEntry>> getEntries();
  Future<Map<String, dynamic>> getSummary();
}

class MockFinanceRepository implements FinanceRepository {
  final List<FinanceEntry> _entries = [
    const FinanceEntry(id: 'f_1', type: 'income', description: 'Corte de Cabelo - Fabio Zvir', amount: 45.0, category: 'Serviço', date: '2026-07-08', paymentMethod: 'PIX', status: 'paid'),
    const FinanceEntry(id: 'f_2', type: 'income', description: 'Combo Cabelo + Barba - João Silva', amount: 70.0, category: 'Serviço', date: '2026-07-08', paymentMethod: 'Cartão de Crédito', status: 'paid'),
    const FinanceEntry(id: 'f_3', type: 'income', description: 'Pomada Efeito Matte Premium - Venda', amount: 65.0, category: 'Produto', date: '2026-07-08', paymentMethod: 'PIX', status: 'paid'),
    const FinanceEntry(id: 'f_4', type: 'expense', description: 'Conta de Energia Elétrica', amount: 350.0, category: 'Utilidades', date: '2026-07-02', paymentMethod: 'Boleto', status: 'paid'),
    const FinanceEntry(id: 'f_5', type: 'expense', description: 'Reposição de Toalhas de Algodão', amount: 180.0, category: 'Insumos', date: '2026-07-05', paymentMethod: 'PIX', status: 'paid'),
    const FinanceEntry(id: 'f_6', type: 'income', description: 'Assinatura Plano Barão - Mensal', amount: 139.90, category: 'Assinatura', date: '2026-07-08', paymentMethod: 'PIX', status: 'paid'),
    const FinanceEntry(id: 'f_7', type: 'expense', description: 'Aluguel do Salão Comercial', amount: 2200.0, category: 'Fixa', date: '2026-07-01', paymentMethod: 'Transferência', status: 'paid'),
    const FinanceEntry(id: 'f_8', type: 'income', description: 'Barba Completa - Ricardo Souza', amount: 35.0, category: 'Serviço', date: '2026-07-08', paymentMethod: 'Dinheiro', status: 'paid'),
  ];

  @override
  Future<List<FinanceEntry>> getEntries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_entries);
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'dailyRevenue': 215.0, // 45 + 70 + 65 + 35
      'monthlyRevenue': 8450.0,
      'dailyAppointments': 12,
      'newCustomers': 3,
      'revenueHistory': [
        {'date': '02/07', 'value': 480.0},
        {'date': '03/07', 'value': 620.0},
        {'date': '04/07', 'value': 810.0},
        {'date': '05/07', 'value': 540.0},
        {'date': '06/07', 'value': 900.0},
        {'date': '07/07', 'value': 750.0},
        {'date': '08/07', 'value': 1150.0},
      ],
      'expenseHistory': [
        {'date': '02/07', 'value': 120.0},
        {'date': '03/07', 'value': 80.0},
        {'date': '04/07', 'value': 150.0},
        {'date': '05/07', 'value': 200.0},
        {'date': '06/07', 'value': 90.0},
        {'date': '07/07', 'value': 130.0},
        {'date': '08/07', 'value': 350.0},
      ],
      'commissionsDue': 1480.0,
      'totalExpenses': 2730.0,
      'servicesSold': 184,
      'productsSold': 45,
    };
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return MockFinanceRepository();
});

final financeEntriesProvider = FutureProvider<List<FinanceEntry>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return await repo.getEntries();
});

final financeSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return await repo.getSummary();
});
