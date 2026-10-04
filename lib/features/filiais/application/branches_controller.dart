import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/branch.dart';
import 'package:barber_osbao/packages/core/shared/repositories/branch_repository.dart';

final branchesProvider = AsyncNotifierProvider<BranchesController, List<Branch>>(
  () => BranchesController(),
);

class CurrentBranchSlugNotifier extends Notifier<String?> {
  @override
  String? build() {
    try {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('unidade')) {
        return uri.queryParameters['unidade'];
      }
      if (uri.fragment.contains('unidade=')) {
        final frag = uri.fragment;
        final qIndex = frag.indexOf('?');
        if (qIndex != -1) {
          final queryPart = frag.substring(qIndex + 1);
          final params = Uri.splitQueryString(queryPart);
          if (params.containsKey('unidade')) {
            return params['unidade'];
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void setSlug(String? slug) => state = slug;
}

final currentBranchSlugProvider =
    NotifierProvider<CurrentBranchSlugNotifier, String?>(
  () => CurrentBranchSlugNotifier(),
);

final selectedBranchProvider = Provider<Branch?>((ref) {
  final branchesAsync = ref.watch(branchesProvider);
  final branches = branchesAsync.value ?? [];
  if (branches.isEmpty) return null;

  final slug = ref.watch(currentBranchSlugProvider);
  if (slug != null && slug.isNotEmpty) {
    try {
      return branches.firstWhere(
        (b) => b.slug.toLowerCase() == slug.toLowerCase() || b.id == slug,
      );
    } catch (_) {}
  }
  return branches.first;
});

class BranchesController extends AsyncNotifier<List<Branch>> {
  @override
  Future<List<Branch>> build() async {
    final repo = ref.watch(branchRepositoryProvider);
    try {
      return await repo.getBranches();
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(branchRepositoryProvider);
      return await repo.getBranches();
    });
  }

  Future<void> createBranch({
    required String name,
    required String address,
    String? slug,
    String? neighborhood,
    String? city,
    String? state,
    String? phone,
  }) async {
    final repo = ref.read(branchRepositoryProvider);
    await repo.createBranch(
      name: name,
      address: address,
      slug: slug,
      neighborhood: neighborhood,
      city: city,
      state: state,
      phone: phone,
    );
    await refresh();
  }

  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    final repo = ref.read(branchRepositoryProvider);
    await repo.updateBranch(id, data);
    await refresh();
  }

  Future<void> deleteBranch(String id) async {
    final repo = ref.read(branchRepositoryProvider);
    await repo.deleteBranch(id);
    await refresh();
  }
}
