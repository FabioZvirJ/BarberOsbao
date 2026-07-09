import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/coupon.dart';

abstract class ClubRepository {
  Future<List<Coupon>> getCoupons();
  Future<Map<String, dynamic>> getClubSettings();
}

class MockClubRepository implements ClubRepository {
  final List<Coupon> _coupons = [
    const Coupon(id: 'cp_1', code: 'OSBAO10', discountPercentage: 10.0, maxDiscount: 20.0, expirationDate: '2026-12-31', active: true),
    const Coupon(id: 'cp_2', code: 'CORTEGRATIS', discountPercentage: 100.0, maxDiscount: 50.0, expirationDate: '2026-08-30', active: true),
    const Coupon(id: 'cp_3', code: 'BEER5', discountPercentage: 5.0, maxDiscount: 5.0, expirationDate: '2026-10-15', active: true),
  ];

  @override
  Future<List<Coupon>> getCoupons() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_coupons);
  }

  @override
  Future<Map<String, dynamic>> getClubSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'pointsPerReal': 1,
      'rules': [
        'Cada R\$ 1,00 gasto equivale a 1 ponto.',
        'Com 100 pontos você ganha um Chopp grátis.',
        'Com 500 pontos você ganha 50% de desconto no próximo corte.',
        'Com 800 pontos você ganha um serviço completo de Cabelo e Barba.',
      ],
      'activeMembersCount': 148,
    };
  }
}

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return MockClubRepository();
});

final clubCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final repo = ref.watch(clubRepositoryProvider);
  return await repo.getCoupons();
});

final clubSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(clubRepositoryProvider);
  return await repo.getClubSettings();
});
