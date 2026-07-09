import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/repositories/financeiro_repository.dart';

class MockFinanceiroRepository implements FinanceiroRepository {
  final List<TransacaoFinanceira> _transacoes = [
    const TransacaoFinanceira(id: 'f_1', type: 'income', description: 'Corte de Cabelo - Fabio Zvir', amount: 45.0, category: 'Serviço', date: '2026-07-09', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_2', type: 'income', description: 'Combo Cabelo + Barba - João Silva', amount: 70.0, category: 'Serviço', date: '2026-07-09', paymentMethod: 'Cartão de Crédito', status: 'paid'),
    const TransacaoFinanceira(id: 'f_3', type: 'income', description: 'Pomada Efeito Matte Premium - Venda', amount: 65.0, category: 'Produto', date: '2026-07-09', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_4', type: 'expense', description: 'Conta de Energia Elétrica', amount: 350.0, category: 'Utilidades', date: '2026-07-02', paymentMethod: 'Boleto', status: 'paid'),
    const TransacaoFinanceira(id: 'f_5', type: 'expense', description: 'Reposição de Toalhas de Algodão', amount: 180.0, category: 'Insumos', date: '2026-07-05', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_6', type: 'income', description: 'Assinatura Plano Barão - Mensal', amount: 139.90, category: 'Assinatura', date: '2026-07-09', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_7', type: 'expense', description: 'Aluguel do Salão Comercial', amount: 2200.0, category: 'Fixa', date: '2026-07-01', paymentMethod: 'Transferência', status: 'paid'),
    const TransacaoFinanceira(id: 'f_8', type: 'income', description: 'Barba Completa - Ricardo Souza', amount: 35.0, category: 'Serviço', date: '2026-07-09', paymentMethod: 'Dinheiro', status: 'paid'),
    const TransacaoFinanceira(id: 'f_9', type: 'income', description: 'Corte Degradê - Carlos Oliveira', amount: 45.0, category: 'Serviço', date: '2026-07-09', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_10', type: 'expense', description: 'Comissão - Arthur Santos (Semana 27)', amount: 450.0, category: 'Comissão', date: '2026-07-07', paymentMethod: 'PIX', status: 'paid'),
    const TransacaoFinanceira(id: 'f_11', type: 'expense', description: 'Comissão - Marcos Silva (Semana 27)', amount: 620.0, category: 'Comissão', date: '2026-07-07', paymentMethod: 'PIX', status: 'paid'),
  ];

  @override
  Future<List<TransacaoFinanceira>> getTransacoes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_transacoes);
  }

  @override
  Future<TransacaoFinanceira> createTransacao(TransacaoFinanceira transacao) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newT = transacao.copyWith(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
    );
    _transacoes.add(newT);
    return newT;
  }

  @override
  Future<Map<String, dynamic>> getFinanceSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    double dailyRev = 0.0;
    double weeklyRev = 0.0;
    double monthlyRev = 8450.0; // Seed baseline
    double expenses = 0.0;
    double commissions = 0.0;

    final today = '2026-07-09';
    for (final t in _transacoes) {
      if (t.type == 'income') {
        if (t.date == today) {
          dailyRev += t.amount;
        }
        weeklyRev += t.amount;
        // Seed baseline starts with older items, let's add any new incomes
        if (t.date == today) {
          monthlyRev += t.amount;
        }
      } else {
        if (t.category == 'Comissão') {
          commissions += t.amount;
        } else {
          expenses += t.amount;
        }
      }
    }

    return {
      'dailyRevenue': dailyRev,
      'weeklyRevenue': weeklyRev + 1200.0, // baseline + current week
      'monthlyRevenue': monthlyRev,
      'totalExpenses': expenses,
      'commissionsDue': commissions,
      'netProfit': monthlyRev - expenses - commissions,
      'revenueHistory': [
        {'date': '03/07', 'value': 620.0},
        {'date': '04/07', 'value': 810.0},
        {'date': '05/07', 'value': 540.0},
        {'date': '06/07', 'value': 900.0},
        {'date': '07/07', 'value': 750.0},
        {'date': '08/07', 'value': 1150.0},
        {'date': '09/07', 'value': dailyRev},
      ],
      'expenseHistory': [
        {'date': '03/07', 'value': 80.0},
        {'date': '04/07', 'value': 150.0},
        {'date': '05/07', 'value': 200.0},
        {'date': '06/07', 'value': 90.0},
        {'date': '07/07', 'value': 130.0},
        {'date': '08/07', 'value': 350.0},
        {'date': '09/07', 'value': expenses > 0 ? expenses / 10 : 120.0},
      ],
    };
  }
}
