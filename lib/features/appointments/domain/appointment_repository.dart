import '../../../shared/models/appointment.dart';
import '../../../shared/models/barber.dart';
import '../../../shared/models/service_model.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> cancelAppointment(String id);
  Future<List<Barber>> getBarbers();
  Future<List<ServiceModel>> getServices();
}
