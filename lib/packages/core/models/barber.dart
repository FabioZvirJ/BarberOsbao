import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:barber_osbao/packages/core/models/branch.dart';

part 'barber.freezed.dart';
part 'barber.g.dart';

@freezed
abstract class Barber with _$Barber {
  const factory Barber({
    required String id,
    required String name,
    required String avatarUrl,
    required double rating,
    required List<String> specialties,
    required String bio,
    required List<String> availableDays, // "YYYY-MM-DD"
    required List<String> availableHours, // "HH:MM"
    @Default(0.3) double commissionRate,
    @Default('active') String status,
  }) = _Barber;

  factory Barber.fromJson(Map<String, dynamic> json) => _$BarberFromJson(json);
}

class BarberBranchRegistry {
  static final Map<String, Branch> _registry = {};

  static void register(String key, Branch branch) {
    if (key.isNotEmpty) {
      _registry[key] = branch;
    }
  }

  static Branch? getBranch(String key) => _registry[key];

  static void clear() => _registry.clear();
}

extension BarberLocationExtension on Barber {
  Branch? get branch =>
      BarberBranchRegistry.getBranch(id) ??
      BarberBranchRegistry.getBranch(name);

  String get shopName {
    final b = branch;
    if (b != null) return b.name;
    return 'Barber Osbão';
  }

  String get address {
    final b = branch;
    if (b != null) {
      return '${b.address}, ${b.neighborhood} - ${b.city}, ${b.state}';
    }
    return '';
  }

  String get neighborhood {
    final b = branch;
    if (b != null && b.neighborhood != null) return b.neighborhood!;
    return '';
  }

  String get phone {
    final b = branch;
    if (b != null && b.phone != null && b.phone!.isNotEmpty) return b.phone!;
    return '';
  }

  String get workingHours => 'Segunda a Sábado: 09:00 - 20:00';
}
