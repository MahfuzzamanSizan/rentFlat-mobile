import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor());
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> postFormData(String path, FormData formData) =>
      _dio.post(path, data: formData);
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken != null) {
          final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
          final response = await dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );
          final newToken = response.data['accessToken'];
          await StorageService.saveTokens(
            accessToken: newToken,
            refreshToken: response.data['refreshToken'] ?? refreshToken,
          );
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        await StorageService.clearAll();
      }
    }
    handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String message = (data is Map ? data['message'] as String? : null) ??
        (data is Map ? data['error'] as String? : null) ??
        error.message ??
        'An error occurred';
    if (data is Map && data['errors'] is Map) {
      final fieldErrors = (data['errors'] as Map)
          .entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
      message = '$message\n$fieldErrors';
    }
    return ApiException(message, statusCode: status);
  }

  @override
  String toString() => message;
}
