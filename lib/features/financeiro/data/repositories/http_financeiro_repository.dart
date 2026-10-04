import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/domain/models/bill.dart';
import 'package:barber_osbao/features/financeiro/domain/models/cash_shift.dart';
import 'package:barber_osbao/features/financeiro/domain/repositories/financeiro_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpFinanceiroRepository implements FinanceiroRepository {
  final DioClient _dioClient;

  HttpFinanceiroRepository(this._dioClient);

  @override
  Future<List<TransacaoFinanceira>> getTransacoes() async {
    final response = await _dioClient.dio.get('/financial/transactions');
    final data = response.data as List;
    return data.map((json) => TransacaoFinanceira.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<TransacaoFinanceira> createTransacao(TransacaoFinanceira transacao) async {
    final response = await _dioClient.dio.post('/financial/transactions', data: transacao.toJson());
    return TransacaoFinanceira.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getFinanceSummary() async {
    final response = await _dioClient.dio.get('/financial/summary');
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<List<Bill>> getBills() async {
    final response = await _dioClient.dio.get('/financial/bills');
    final data = response.data as List;
    return data.map((json) => Bill.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Bill> saveBill(Bill bill) async {
    if (bill.id.isNotEmpty && !bill.id.startsWith('c_')) {
      final response = await _dioClient.dio.put('/financial/bills/${bill.id}', data: bill.toJson());
      return Bill.fromJson(response.data as Map<String, dynamic>);
    } else {
      final response = await _dioClient.dio.post('/financial/bills', data: bill.toJson());
      return Bill.fromJson(response.data as Map<String, dynamic>);
    }
  }

  @override
  Future<CashShift?> getActiveCashShift() async {
    final response = await _dioClient.dio.get('/financial/cash-shifts/active');
    if (response.data == null) return null;
    return CashShift.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CashShift> openCashShift(double initialBalance) async {
    final response = await _dioClient.dio.post(
      '/financial/cash-shifts/open',
      data: {'initialBalance': initialBalance},
    );
    return CashShift.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CashShift> closeCashShift(double finalBalance, double reportedCash) async {
    final response = await _dioClient.dio.post(
      '/financial/cash-shifts/close',
      data: {
        'finalBalance': finalBalance,
        'reportedCash': reportedCash,
      },
    );
    return CashShift.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CashMovement> addCashMovement(CashMovement movement) async {
    final response = await _dioClient.dio.post(
      '/financial/cash-shifts/movements',
      data: movement.toJson(),
    );
    return CashMovement.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CashMovement>> getCashMovements(String cashShiftId) async {
    final response = await _dioClient.dio.get('/financial/cash-shifts/$cashShiftId/movements');
    final data = response.data as List;
    return data.map((json) => CashMovement.fromJson(json as Map<String, dynamic>)).toList();
  }
}

