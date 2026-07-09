import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/utils/mock_data.dart';

abstract class BarberRepository {
  Future<List<Barber>> getBarbers();
  Future<Barber> updateBarberStatus(String id, String status);
  Future<Barber> updateBarberCommission(String id, double commissionRate);
}

class MockBarberRepository implements BarberRepository {
  final List<Barber> _barbers = List.from(MockData.barbers);

  @override
  Future<List<Barber>> getBarbers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_barbers);
  }

  @override
  Future<Barber> updateBarberStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _barbers.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = _barbers[index].copyWith(status: status);
      _barbers[index] = updated;
      return updated;
    }
    throw Exception('Barber not found');
  }

  @override
  Future<Barber> updateBarberCommission(String id, double commissionRate) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _barbers.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = _barbers[index].copyWith(commissionRate: commissionRate);
      _barbers[index] = updated;
      return updated;
    }
    throw Exception('Barber not found');
  }
}

final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  return MockBarberRepository();
});

final barbersListProvider = FutureProvider<List<Barber>>((ref) async {
  final repo = ref.watch(barberRepositoryProvider);
  return await repo.getBarbers();
});
