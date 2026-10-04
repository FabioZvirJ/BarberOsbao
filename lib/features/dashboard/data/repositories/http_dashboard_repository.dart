import 'package:barber_osbao/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpDashboardRepository implements DashboardRepository {
  final DioClient _dioClient;

  HttpDashboardRepository(this._dioClient);

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dioClient.dio.get('/dashboard/metrics');
    return Map<String, dynamic>.from(response.data as Map);
  }
}

