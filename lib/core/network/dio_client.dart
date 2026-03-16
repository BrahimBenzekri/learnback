import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learnback/core/constants/api_constants.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient({Dio? dioOverride, FlutterSecureStorage? secureStorage})
    : _dio =
          dioOverride ??
          Dio(
            BaseOptions(
              baseUrl:
                  dotenv.env['API_BASE_URL'] ?? ApiConstants.defaultBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          ),
      _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initInterceptors();
  }

  void _initInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token if available
          final token = await _secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // TODO: centralized error handling, navigation on 401
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
