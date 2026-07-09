import 'dart:convert';
import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/models/membership.dart';
import 'package:barber_osbao/packages/core/utils/mock_data.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';
import 'package:barber_osbao/packages/core/shared/plans/domain/plans_repository.dart';

class PlansRepositoryImpl implements PlansRepository {
  final PrefHelper _prefHelper;

  static const String _keyMembership = 'active_membership';

  PlansRepositoryImpl(this._prefHelper);

  @override
  Future<List<Plan>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.plans;
  }

  @override
  Future<Membership?> getActiveMembership() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cached = _prefHelper.getUserJson(); // Retrieve from storage helper
    if (cached == null) return null;
    
    // We can also store/retrieve membership JSON specifically
    final memJson = _prefHelper.getUserJson(); // For mock simplicity, we keep a separate field in Prefs if we want
    // Let's check if we have a membership stored, if not return active mock
    return MockData.activeMembership;
  }

  @override
  Future<Membership> subscribeToPlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final plan = MockData.plans.firstWhere((p) => p.id == planId);
    
    final newMem = Membership(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_1',
      planId: planId,
      planName: plan.name,
      startDate: DateTime.now().toIso8601String().split('T')[0],
      endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      status: 'active',
      remainingBenefits: plan.benefits,
      discountsUsed: 0,
      nextRenewalDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
    );

    return newMem;
  }

  @override
  Future<void> cancelMembership() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
