import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
abstract class Appointment with _$Appointment {
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

extension AppointmentLocationExtension on Appointment {
  String get locationName {
    switch (barberId) {
      case 'barb_1':
        return 'Barber Osbão - Unidade Jardins';
      case 'barb_2':
        return 'Barber Osbão - Unidade Pinheiros';
      case 'barb_3':
        return 'Barber Osbão - Unidade Centro Histórico';
      case 'barb_4':
        return 'Barber Osbão - Unidade Moema';
      case 'barb_5':
        return 'Barber Osbão - Unidade Paulista';
      case 'barb_6':
        return 'Barber Osbão - Unidade Vila Madalena';
      default:
        return 'Barber Osbão - Unidade Jardins';
    }
  }

  String get locationAddress {
    switch (barberId) {
      case 'barb_1':
        return 'Rua Oscar Freire, 1020 - Jardins, SP';
      case 'barb_2':
        return 'Rua dos Pinheiros, 450 - Pinheiros, SP';
      case 'barb_3':
        return 'Rua Direita, 88 - Centro Histórico, SP';
      case 'barb_4':
        return 'Av. Moema, 312 - Moema, SP';
      case 'barb_5':
        return 'Av. Paulista, 1578 - Bela Vista, SP';
      case 'barb_6':
        return 'Rua Aspicuelta, 260 - Vila Madalena, SP';
      default:
        return 'Rua Oscar Freire, 1020 - Jardins, SP';
    }
  }
}
