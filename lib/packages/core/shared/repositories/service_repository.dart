import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/utils/mock_data.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices();
  Future<ServiceModel> createService(ServiceModel service);
}

class MockServiceRepository implements ServiceRepository {
  final List<ServiceModel> _services = List.from(MockData.services);

  @override
  Future<List<ServiceModel>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_services);
  }

  @override
  Future<ServiceModel> createService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newService = service.copyWith(id: 'srv_${_services.length + 1}');
    _services.add(newService);
    return newService;
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return MockServiceRepository();
});

final servicesListProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return await repo.getServices();
});
