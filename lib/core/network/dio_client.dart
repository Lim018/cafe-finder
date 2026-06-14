import 'package:dio/dio.dart';
import '../config/env.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient({required AuthInterceptor authInterceptor})
      : dio = Dio(
          BaseOptions(
            baseUrl: '${Env.baseUrl}/api/v1',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(authInterceptor);
    // Add logging interceptor for development
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }
}
