import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  // Override at build time: --dart-define=API_BASE_URL=http://10.0.2.2:3000
  static const _envBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.barberosbao.com.br/v1');

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _envBase,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add JWT authorization token placeholder here
          // final token = ...
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
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
