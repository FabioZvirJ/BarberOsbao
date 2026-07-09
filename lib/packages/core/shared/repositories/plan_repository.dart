import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/utils/mock_data.dart';

abstract class PlanRepository {
  Future<List<Plan>> getPlans();
  Future<void> createPlan(Plan plan);
  Future<void> updatePlan(Plan plan);
  Future<void> deletePlan(String id);
}

class MockPlanRepository implements PlanRepository {
  final List<Plan> _plans = List.from(MockData.plans);

  @override
  Future<List<Plan>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_plans);
  }

  @override
  Future<void> createPlan(Plan plan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _plans.add(plan);
  }

  @override
  Future<void> updatePlan(Plan plan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _plans.removeWhere((p) => p.id == id);
  }
}

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return MockPlanRepository();
});

class PlansListNotifier extends AsyncNotifier<List<Plan>> {
  late final PlanRepository _repository;

  @override
  Future<List<Plan>> build() async {
    _repository = ref.watch(planRepositoryProvider);
    return await _repository.getPlans();
  }

  Future<void> addPlan(Plan plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createPlan(plan);
      return await _repository.getPlans();
    });
  }

  Future<void> updatePlan(Plan plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updatePlan(plan);
      return await _repository.getPlans();
    });
  }

  Future<void> deletePlan(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deletePlan(id);
      return await _repository.getPlans();
    });
  }
}

final plansListProvider = AsyncNotifierProvider<PlansListNotifier, List<Plan>>(() {
  return PlansListNotifier();
});
