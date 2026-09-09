import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/models/bill.dart';
import 'package:barber_osbao/features/financeiro/domain/models/cash_shift.dart';

abstract class FinanceiroRepository {
  Future<List<TransacaoFinanceira>> getTransacoes();
  Future<TransacaoFinanceira> createTransacao(TransacaoFinanceira transacao);
  Future<Map<String, dynamic>> getFinanceSummary();

  // Bill Operations
  Future<List<Bill>> getBills();
  Future<Bill> saveBill(Bill bill);

  // Cash Register Operations
  Future<CashShift?> getActiveCashShift();
  Future<CashShift> openCashShift(double initialBalance);
  Future<CashShift> closeCashShift(double finalBalance, double reportedCash);
  Future<CashMovement> addCashMovement(CashMovement movement);
  Future<List<CashMovement>> getCashMovements(String cashShiftId);
}
