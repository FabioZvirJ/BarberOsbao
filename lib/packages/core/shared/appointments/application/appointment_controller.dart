import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/storage/drift_db.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/shared/appointments/domain/appointment_repository.dart';
import 'package:barber_osbao/packages/core/shared/appointments/infrastructure/appointment_repository_impl.dart';

// Drift DB provider
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository provider
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final db = ref.watch(dbProvider);
  return AppointmentRepositoryImpl(db);
});

// Barbers future provider
final barbersProvider = FutureProvider<List<Barber>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return await repo.getBarbers();
});

// Services future provider
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  return await repo.getServices();
});

// Appointments list state controller
class AppointmentsController extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final repo = ref.watch(appointmentRepositoryProvider);
    return await repo.getAppointments();
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
