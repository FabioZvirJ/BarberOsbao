import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:barber_osbao/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';
import 'package:barber_osbao/features/clientes/presentation/controllers/clientes_controller.dart';
import 'package:barber_osbao/features/funcionarios/presentation/controllers/funcionarios_controller.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final agendaRepo = ref.watch(agendaRepositoryProvider);
  final financeRepo = ref.watch(financeiroRepositoryProvider);
  final clientesRepo = ref.watch(clientesRepositoryProvider);
  final funcionariosRepo = ref.watch(funcionariosRepositoryProvider);
  return MockDashboardRepository(agendaRepo, financeRepo, clientesRepo, funcionariosRepo);
});

class DashboardController extends Notifier<AppState<Map<String, dynamic>>> {
  late final DashboardRepository _repository;

  @override
  AppState<Map<String, dynamic>> build() {
    _repository = ref.watch(dashboardRepositoryProvider);
    
    // Reload dashboard stats when dependencies change
    ref.listen(agendaControllerProvider, (_, _) {
      loadStats();
    });
    ref.listen(transacoesControllerProvider, (_, _) {
      loadStats();
    });
    ref.listen(clientesControllerProvider, (_, _) {
      loadStats();
    });
    ref.listen(funcionariosControllerProvider, (_, _) {
      loadStats();
    });

    Future.microtask(() => loadStats());
    return const AppLoading();
  }

  Future<void> loadStats() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final stats = await _repository.getDashboardStats();
      state = AppSuccess(stats);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final dashboardControllerProvider = NotifierProvider<DashboardController, AppState<Map<String, dynamic>>>(
  () => DashboardController(),
);
