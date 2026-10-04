import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/models/membership.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/shared/plans/domain/plans_repository.dart';

class PlansRepositoryImpl implements PlansRepository {
  final PrefHelper _prefHelper;
  final DioClient _dioClient;

  PlansRepositoryImpl(this._prefHelper, this._dioClient);

  @override
  Future<List<Plan>> getPlans() async {
    try {
      final response = await _dioClient.dio.get('/plans');
      final data = response.data as List;
      return data.map((json) {
        final p = json as Map<String, dynamic>;
        final bList = (p['benefits'] is List)
            ? List<String>.from(p['benefits'])
            : <String>[];
        return Plan(
          id: p['id'] ?? '',
          name: p['name'] ?? '',
          price: (p['price'] as num?)?.toDouble() ?? 0.0,
          period: p['period'] ?? 'mensal',
          benefits: bList,
          recommended: p['recommended'] == true,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Membership?> getActiveMembership() async {
    final cached = _prefHelper.getUserJson();
    if (cached == null) return null;
    return null;
  }

  @override
  Future<Membership> subscribeToPlan(String planId) async {
    final newMem = Membership(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_current',
      planId: planId,
      planName: 'Plano Assinado',
      startDate: DateTime.now().toIso8601String().split('T')[0],
      endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      status: 'active',
      remainingBenefits: const [],
      discountsUsed: 0,
      nextRenewalDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
    );

    return newMem;
  }

  @override
  Future<void> cancelMembership() async {}
}
