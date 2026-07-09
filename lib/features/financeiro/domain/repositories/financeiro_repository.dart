import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';

abstract class FinanceiroRepository {
  Future<List<TransacaoFinanceira>> getTransacoes();
  Future<TransacaoFinanceira> createTransacao(TransacaoFinanceira transacao);
  Future<Map<String, dynamic>> getFinanceSummary();
}
