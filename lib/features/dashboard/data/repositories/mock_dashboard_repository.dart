import 'package:barber_osbao/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:barber_osbao/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:barber_osbao/features/financeiro/domain/repositories/financeiro_repository.dart';
import 'package:barber_osbao/features/clientes/domain/repositories/clientes_repository.dart';
import 'package:barber_osbao/features/funcionarios/domain/repositories/funcionarios_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  final AgendaRepository _agendaRepo;
  final FinanceiroRepository _financeRepo;
  final ClientesRepository _clientesRepo;
  final FuncionariosRepository _funcionariosRepo;

  MockDashboardRepository(
    this._agendaRepo,
    this._financeRepo,
    this._clientesRepo,
    this._funcionariosRepo,
  );

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final appointments = await _agendaRepo.getAgendamentos();
    final transactions = await _financeRepo.getTransacoes();
    final clients = await _clientesRepo.getClientes();
    final staff = await _funcionariosRepo.getFuncionarios();

    final today = '2026-07-09';
    final appointmentsToday = appointments.where((a) => a.date == today).toList();
    final newClients = clients.length; // total clients for overview

    double dailyRevenue = 0.0;
    for (final t in transactions) {
      if (t.type == 'income' && t.date == today) {
        dailyRevenue += t.amount;
      }
    }

    double avgRating = 4.8;
    if (staff.isNotEmpty) {
      final totalRating = staff.map((s) => s.rating).reduce((a, b) => a + b);
      avgRating = double.parse((totalRating / staff.length).toStringAsFixed(1));
    }

    return {
      'appointmentsTodayCount': appointmentsToday.length,
      'dailyRevenue': dailyRevenue,
      'newClientsCount': newClients,
      'averageRating': avgRating,
    };
  }
}
