import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';

class BusinessSettings {
  final String name;
  final String logoUrl;
  final String phone;
  final String address;
  final String instagram;
  final String facebook;
  final String pixKey;
  final String slotInterval; // '15', '30', '45', '60'
  final Map<String, String> workingHours; // e.g. {'Segunda': '09:00 - 18:00'}
  final List<String> workingDays;

  const BusinessSettings({
    required this.name,
    required this.logoUrl,
    required this.phone,
    required this.address,
    required this.instagram,
    required this.facebook,
    required this.pixKey,
    required this.slotInterval,
    required this.workingHours,
    required this.workingDays,
  });

  BusinessSettings copyWith({
    String? name,
    String? logoUrl,
    String? phone,
    String? address,
    String? instagram,
    String? facebook,
    String? pixKey,
    String? slotInterval,
    Map<String, String>? workingHours,
    List<String>? workingDays,
  }) {
    return BusinessSettings(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      pixKey: pixKey ?? this.pixKey,
      slotInterval: slotInterval ?? this.slotInterval,
      workingHours: workingHours ?? this.workingHours,
      workingDays: workingDays ?? this.workingDays,
    );
  }
}

class BusinessSettingsController extends Notifier<AppState<BusinessSettings>> {
  @override
  AppState<BusinessSettings> build() {
    return const AppSuccess(
      BusinessSettings(
        name: 'Barbearia Osbão Matriz',
        logoUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&width=150',
        phone: '(11) 99999-9999',
        address: 'Av. Paulista, 1000 - São Paulo, SP',
        instagram: '@barber_osbao',
        facebook: 'barberosbao.oficial',
        pixKey: 'pix@barberosbao.com.br',
        slotInterval: '30',
        workingHours: {
          'Segunda a Sexta': '09:00 - 20:00',
          'Sábado': '09:00 - 18:00',
          'Domingo': 'Fechado',
        },
        workingDays: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
      ),
    );
  }

  void updateSettings(BusinessSettings settings) {
    state = AppSuccess(settings);
  }
}

final businessSettingsControllerProvider = NotifierProvider<BusinessSettingsController, AppState<BusinessSettings>>(
  () => BusinessSettingsController(),
);
