import 'package:freezed_annotation/freezed_annotation.dart';

part 'barber.freezed.dart';
part 'barber.g.dart';

@freezed
class Barber with _$Barber {
  const factory Barber({
    required String id,
    required String name,
    required String avatarUrl,
    required double rating,
    required List<String> specialties,
    required String bio,
    required List<String> availableDays, // "YYYY-MM-DD"
    required List<String> availableHours, // "HH:MM"
  }) = _Barber;

  factory Barber.fromJson(Map<String, dynamic> json) => _$BarberFromJson(json);
}
