import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:barber_osbao/packages/core/storage/drift_db.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/shared/appointments/domain/appointment_repository.dart';
import 'package:barber_osbao/packages/core/shared/appointments/infrastructure/appointment_repository_impl.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';

// Drift DB provider
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository provider
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final db = ref.watch(dbProvider);
  final dioClient = ref.watch(dioClientProvider);
  return AppointmentRepositoryImpl(db, dioClient);
});

// Barbers future provider (filtered by selected branch if set)
final barbersProvider = FutureProvider<List<Barber>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final selectedBranch = ref.watch(selectedBranchProvider);
  return await repo.getBarbers(branchId: selectedBranch?.id);
});

// Services future provider (filtered by selected branch if set)
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final selectedBranch = ref.watch(selectedBranchProvider);
  return await repo.getServices(branchId: selectedBranch?.id);
});

// Appointments list state controller
class AppointmentsController extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final repo = ref.watch(appointmentRepositoryProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);
    return await repo.getAppointments(branchId: selectedBranch?.id);
  }

  Future<void> createAppointment(Appointment appointment) async {
    final previousState = await future;
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repo = ref.read(appointmentRepositoryProvider);
      final newApt = await repo.createAppointment(appointment);
      return [newApt, ...previousState];
    });
  }

  Future<void> cancelAppointment(String id) async {
    final previousState = await future;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(appointmentRepositoryProvider);
      final updated = await repo.cancelAppointment(id);
      return previousState.map((a) => a.id == id ? updated : a).toList();
    });
  }
}

final appointmentsControllerProvider = AsyncNotifierProvider<AppointmentsController, List<Appointment>>(
  () => AppointmentsController(),
);
