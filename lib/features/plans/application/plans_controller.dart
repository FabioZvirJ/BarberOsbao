import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/plan.dart';
import '../../../shared/models/membership.dart';
import '../../authentication/application/auth_controller.dart';
import '../domain/plans_repository.dart';
import '../infrastructure/plans_repository_impl.dart';

// Plans Repository Provider
final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  final helper = ref.watch(prefHelperProvider);
  return PlansRepositoryImpl(helper);
});

// Plans Future Provider
final plansProvider = FutureProvider<List<Plan>>((ref) async {
  final repo = ref.watch(plansRepositoryProvider);
  return await repo.getPlans();
});

// Membership controller notifier
class MembershipController extends AsyncNotifier<Membership?> {
  @override
  Future<Membership?> build() async {
    final repo = ref.watch(plansRepositoryProvider);
    return await repo.getActiveMembership();
  }

  Future<void> subscribe(String planId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(plansRepositoryProvider);
      return await repo.subscribeToPlan(planId);
    });
  }

  Future<void> cancel() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(plansRepositoryProvider);
      await repo.cancelMembership();
      return null;
    });
  }
}

final membershipControllerProvider = AsyncNotifierProvider<MembershipController, Membership?>(
  () => MembershipController(),
);
