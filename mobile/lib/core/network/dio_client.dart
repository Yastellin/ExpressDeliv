import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/storage_service.dart'; // On va le créer après

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Refresh Token Logic
            try {
              final refreshToken = await StorageService.getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
                final newAccessToken = response.data['accessToken'];
                await StorageService.saveTokens(newAccessToken, refreshToken);
                // Retry original request
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Refresh failed => logout
              await StorageService.clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
    // Retry logic for network errors
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      retries: 2,
      retryDelays: const [Duration(seconds: 1), Duration(seconds: 2)],
    ));
    return _dio;
  }
}