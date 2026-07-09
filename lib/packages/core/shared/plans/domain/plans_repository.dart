import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/models/membership.dart';

abstract class PlansRepository {
  Future<List<Plan>> getPlans();
  Future<Membership?> getActiveMembership();
  Future<Membership> subscribeToPlan(String planId);
  Future<void> cancelMembership();
}
