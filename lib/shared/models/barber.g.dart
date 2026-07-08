// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barber.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Barber _$BarberFromJson(Map<String, dynamic> json) => _Barber(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String,
  rating: (json['rating'] as num).toDouble(),
  specialties: (json['specialties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String,
  availableDays: (json['availableDays'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  availableHours: (json['availableHours'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BarberToJson(_Barber instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'rating': instance.rating,
  'specialties': instance.specialties,
  'bio': instance.bio,
  'availableDays': instance.availableDays,
  'availableHours': instance.availableHours,
};
