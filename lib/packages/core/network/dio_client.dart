import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/storage/pref_helper.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final helper = ref.watch(prefHelperProvider);
  return DioClient(prefHelper: helper);
});

class DioClient {
  final Dio _dio;
  final PrefHelper? _prefHelper;

  DioClient({PrefHelper? prefHelper})
      : _prefHelper = prefHelper,
        _dio = Dio(
          BaseOptions(
            baseUrl: const String.fromEnvironment(
              'API_URL',
              defaultValue: 'http://localhost:3000',
            ),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefHelper?.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
