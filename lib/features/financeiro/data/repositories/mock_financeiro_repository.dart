import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/models/bill.dart';
import 'package:barber_osbao/features/financeiro/domain/models/cash_shift.dart';
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

  final List<Bill> _bills = [
    const Bill(
      id: 'c_1',
      clientName: 'Gustavo Santos',
      status: 'open',
      items: [
        BillItem(id: 's_1', name: 'Corte Degradê', type: 'service', price: 45.0, professionalName: 'Marcos Silva'),
      ],
      payments: [],
      date: '2026-07-09',
      time: '14:30',
    ),
    const Bill(
      id: 'c_2',
      clientName: 'Bruno Lima',
      status: 'open',
      items: [
        BillItem(id: 's_2', name: 'Barba Completa', type: 'service', price: 35.0, professionalName: 'Arthur Santos'),
        BillItem(id: 'p_1', name: 'Pomada Matte', type: 'product', price: 65.0),
      ],
      payments: [],
      date: '2026-07-09',
      time: '15:15',
    ),
  ];

  final List<CashShift> _cashShifts = [];
  final List<CashMovement> _cashMovements = [];

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

  // Bill Operations implementation
  @override
  Future<List<Bill>> getBills() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_bills);
  }

  @override
  Future<Bill> saveBill(Bill bill) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _bills.indexWhere((c) => c.id == bill.id);
    if (idx != -1) {
      _bills[idx] = bill;
      return bill;
    } else {
      final newBill = bill.copyWith(
        id: bill.id.isEmpty ? 'c_${DateTime.now().millisecondsSinceEpoch}' : bill.id,
      );
      _bills.add(newBill);
      return newBill;
    }
  }

  // Cash Register Operations implementation
  @override
  Future<CashShift?> getActiveCashShift() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final openShifts = _cashShifts.where((c) => c.status == 'open').toList();
    return openShifts.isNotEmpty ? openShifts.first : null;
  }

  @override
  Future<CashShift> openCashShift(double initialBalance) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final newShift = CashShift(
      id: 'cx_${now.millisecondsSinceEpoch}',
      operatorName: 'Fábio Zvir',
      openDate: todayStr,
      openTime: timeStr,
      initialBalance: initialBalance,
      status: 'open',
    );
    _cashShifts.add(newShift);
    return newShift;
  }

  @override
  Future<CashShift> closeCashShift(double finalBalance, double reportedCash) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final active = await getActiveCashShift();
    if (active == null) {
      throw Exception('Nenhum caixa ativo encontrado para fechamento.');
    }

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Calculate expected balance: initialBalance + all cash entries - all cash exits
    double moneyEntries = 0.0;
    final activeMovements = _cashMovements.where((m) => m.cashShiftId == active.id).toList();
    for (final mv in activeMovements) {
      if (mv.type == 'input' || mv.type == 'supply') {
        moneyEntries += mv.amount;
      } else if (mv.type == 'output' || mv.type == 'withdraw') {
        moneyEntries -= mv.amount;
      }
    }

    final totalExpected = active.initialBalance + moneyEntries;

    final closed = active.copyWith(
      closeDate: todayStr,
      closeTime: timeStr,
      totalExpected: totalExpected,
      totalReported: reportedCash,
      status: 'closed',
    );

    final idx = _cashShifts.indexWhere((c) => c.id == active.id);
    if (idx != -1) {
      _cashShifts[idx] = closed;
    }

    return closed;
  }

  @override
  Future<CashMovement> addCashMovement(CashMovement movement) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newM = movement.copyWith(
      id: 'mv_${DateTime.now().millisecondsSinceEpoch}',
    );
    _cashMovements.add(newM);
    return newM;
  }

  @override
  Future<List<CashMovement>> getCashMovements(String cashShiftId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _cashMovements.where((m) => m.cashShiftId == cashShiftId).toList();
  }
}
