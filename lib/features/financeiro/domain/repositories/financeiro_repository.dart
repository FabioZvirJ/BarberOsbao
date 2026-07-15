import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/models/comanda.dart';
import 'package:barber_osbao/features/financeiro/domain/models/caixa_turno.dart';

abstract class FinanceiroRepository {
  Future<List<TransacaoFinanceira>> getTransacoes();
  Future<TransacaoFinanceira> createTransacao(TransacaoFinanceira transacao);
  Future<Map<String, dynamic>> getFinanceSummary();

  // Comanda Operations
  Future<List<Comanda>> getComandas();
  Future<Comanda> saveComanda(Comanda comanda);

  // Caixa Operations
  Future<CaixaTurno?> getActiveCaixa();
  Future<CaixaTurno> abrirCaixa(double saldoInicial);
  Future<CaixaTurno> fecharCaixa(double saldoFinal, double dinheiroInformado);
  Future<MovimentoCaixa> addMovimentoCaixa(MovimentoCaixa movimento);
  Future<List<MovimentoCaixa>> getMovimentosCaixa(String caixaId);
}
