import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/models/comanda.dart';
import 'package:barber_osbao/features/financeiro/domain/models/caixa_turno.dart';
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

  final List<Comanda> _comandas = [
    const Comanda(
      id: 'c_1',
      clienteNome: 'Gustavo Santos',
      status: 'open',
      itens: [
        ItemComanda(id: 's_1', name: 'Corte Degradê', type: 'service', price: 45.0, professionalName: 'Marcos Silva'),
      ],
      pagamentos: [],
      date: '2026-07-09',
      time: '14:30',
    ),
    const Comanda(
      id: 'c_2',
      clienteNome: 'Bruno Lima',
      status: 'open',
      itens: [
        ItemComanda(id: 's_2', name: 'Barba Completa', type: 'service', price: 35.0, professionalName: 'Arthur Santos'),
        ItemComanda(id: 'p_1', name: 'Pomada Matte', type: 'product', price: 65.0),
      ],
      pagamentos: [],
      date: '2026-07-09',
      time: '15:15',
    ),
  ];

  final List<CaixaTurno> _caixas = [];
  final List<MovimentoCaixa> _movimentos = [];

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

  // Comanda Operations implementation
  @override
  Future<List<Comanda>> getComandas() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_comandas);
  }

  @override
  Future<Comanda> saveComanda(Comanda comanda) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _comandas.indexWhere((c) => c.id == comanda.id);
    if (idx != -1) {
      _comandas[idx] = comanda;
      return comanda;
    } else {
      final newComanda = comanda.copyWith(
        id: comanda.id.isEmpty ? 'c_${DateTime.now().millisecondsSinceEpoch}' : comanda.id,
      );
      _comandas.add(newComanda);
      return newComanda;
    }
  }

  // Caixa Operations implementation
  @override
  Future<CaixaTurno?> getActiveCaixa() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final openCaixas = _caixas.where((c) => c.status == 'open').toList();
    return openCaixas.isNotEmpty ? openCaixas.first : null;
  }

  @override
  Future<CaixaTurno> abrirCaixa(double saldoInicial) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final newCaixa = CaixaTurno(
      id: 'cx_${now.millisecondsSinceEpoch}',
      operatorName: 'Fábio Zvir',
      openDate: todayStr,
      openTime: timeStr,
      initialBalance: saldoInicial,
      status: 'open',
    );
    _caixas.add(newCaixa);
    return newCaixa;
  }

  @override
  Future<CaixaTurno> fecharCaixa(double saldoFinal, double dinheiroInformado) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final active = await getActiveCaixa();
    if (active == null) {
      throw Exception('Nenhum caixa ativo encontrado para fechamento.');
    }

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Calculate expected balance: initialBalance + all cash entries - all cash exits
    double moneyEntries = 0.0;
    final activeMovements = _movimentos.where((m) => m.caixaId == active.id).toList();
    for (final mv in activeMovements) {
      if (mv.type == 'entrada' || mv.type == 'suprimento') {
        moneyEntries += mv.amount;
      } else if (mv.type == 'saida' || mv.type == 'sangria') {
        moneyEntries -= mv.amount;
      }
    }

    final moneyExpected = active.initialBalance + moneyEntries;

    final closed = active.copyWith(
      closeDate: todayStr,
      closeTime: timeStr,
      finalBalance: saldoFinal,
      moneyExpected: moneyExpected,
      moneyReported: dinheiroInformado,
      status: 'closed',
    );

    final idx = _caixas.indexWhere((c) => c.id == active.id);
    if (idx != -1) {
      _caixas[idx] = closed;
    }

    return closed;
  }

  @override
  Future<MovimentoCaixa> addMovimentoCaixa(MovimentoCaixa movimento) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newM = movimento.copyWith(
      id: 'mv_${DateTime.now().millisecondsSinceEpoch}',
    );
    _movimentos.add(newM);
    return newM;
  }

  @override
  Future<List<MovimentoCaixa>> getMovimentosCaixa(String caixaId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _movimentos.where((m) => m.caixaId == caixaId).toList();
  }
}
