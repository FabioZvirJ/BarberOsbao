// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Appointment _$AppointmentFromJson(Map<String, dynamic> json) => _Appointment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  barberId: json['barberId'] as String,
  barberName: json['barberName'] as String,
  barberAvatar: json['barberAvatar'] as String,
  services: (json['services'] as List<dynamic>)
      .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  date: json['date'] as String,
  time: json['time'] as String,
  totalValue: (json['totalValue'] as num).toDouble(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AppointmentToJson(_Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'barberId': instance.barberId,
      'barberName': instance.barberName,
      'barberAvatar': instance.barberAvatar,
      'services': instance.services,
      'date': instance.date,
      'time': instance.time,
      'totalValue': instance.totalValue,
      'status': instance.status,
      'notes': instance.notes,
    };
