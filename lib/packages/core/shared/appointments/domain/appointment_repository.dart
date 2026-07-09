import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> cancelAppointment(String id);
  Future<List<Barber>> getBarbers();
  Future<List<ServiceModel>> getServices();
}
