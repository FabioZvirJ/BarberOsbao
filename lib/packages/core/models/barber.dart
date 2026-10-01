import 'package:freezed_annotation/freezed_annotation.dart';

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

extension BarberLocationExtension on Barber {
  String get shopName {
    switch (id) {
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

  String get address {
    switch (id) {
      case 'barb_1':
        return 'Rua Oscar Freire, 1020 - Jardins, São Paulo';
      case 'barb_2':
        return 'Rua dos Pinheiros, 450 - Pinheiros, São Paulo';
      case 'barb_3':
        return 'Rua Direita, 88 - Centro Histórico, São Paulo';
      case 'barb_4':
        return 'Av. Moema, 312 - Moema, São Paulo';
      case 'barb_5':
        return 'Av. Paulista, 1578 - Bela Vista, São Paulo';
      case 'barb_6':
        return 'Rua Aspicuelta, 260 - Vila Madalena, São Paulo';
      default:
        return 'Rua Oscar Freire, 1020 - Jardins, São Paulo';
    }
  }

  String get neighborhood {
    switch (id) {
      case 'barb_1':
        return 'Jardins';
      case 'barb_2':
        return 'Pinheiros';
      case 'barb_3':
        return 'Centro';
      case 'barb_4':
        return 'Moema';
      case 'barb_5':
        return 'Paulista';
      case 'barb_6':
        return 'Vila Madalena';
      default:
        return 'Jardins';
    }
  }

  String get phone {
    switch (id) {
      case 'barb_1':
        return '(11) 98765-4321';
      case 'barb_2':
        return '(11) 97654-3210';
      case 'barb_3':
        return '(11) 96543-2109';
      case 'barb_4':
        return '(11) 95432-1098';
      case 'barb_5':
        return '(11) 94321-0987';
      case 'barb_6':
        return '(11) 93210-9876';
      default:
        return '(11) 98765-4321';
    }
  }

  String get workingHours => 'Segunda a Sábado: 09:00 - 20:00';
}
