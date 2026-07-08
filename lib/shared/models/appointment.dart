import 'package:freezed_annotation/freezed_annotation.dart';
import 'service_model.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String userId,
    required String barberId,
    required String barberName,
    required String barberAvatar,
    required List<ServiceModel> services,
    required String date, // "YYYY-MM-DD"
    required String time, // "HH:MM"
    required double totalValue,
    required String status, // 'pending', 'confirmed', 'completed', 'cancelled'
    String? notes,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
}
