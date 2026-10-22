import 'package:dio/dio.dart';
import '../../includes/Storage.dart';
import 'ApiResponse.dart';

/// Global HTTP Network Request Client
/// Follows MVC pattern to centralize all low-level networking, headers,
/// token injection, timeouts, and Laravel response parsing.
class GlobalRequest {
  static final GlobalRequest _instance = GlobalRequest._internal();
  factory GlobalRequest() => _instance;

  late Dio dio;

  GlobalRequest._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: currentBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 25),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    // Request & Response Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            LocalStorage.clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }

  static String get defaultBaseUrl => 'https://moneyararesearch.in/';

  static String get currentBaseUrl {
    final custom = LocalStorage.read(LocalStorage.customBaseUrlKey);
    if (custom != null && custom.trim().isNotEmpty) {
      final trimmed = custom.trim();
      // Automatically fallback to live server if stale localhost/emulator URL was previously cached
      if (trimmed.contains('10.0.2.2:8000') ||
          trimmed.contains('localhost:8000') ||
          trimmed.contains('127.0.0.1:8000')) {
        return defaultBaseUrl;
      }
      return trimmed.endsWith('/')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    }
    return defaultBaseUrl;
  }

  static String get baseUrl => currentBaseUrl;

  static void resetToDefaultUrl() {
    LocalStorage.remove(LocalStorage.customBaseUrlKey);
    GlobalRequest().dio.options.baseUrl = defaultBaseUrl;
  }

  static void updateBaseUrl(String newBaseUrl) {
    String cleanUrl = newBaseUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    LocalStorage.write(LocalStorage.customBaseUrlKey, cleanUrl);
    GlobalRequest().dio.options.baseUrl = cleanUrl;
  }

  // =========================================================================
  // GENERIC HTTP METHODS
  // =========================================================================

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _parseSuccessResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseSuccessResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseSuccessResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Generic Multipart POST request (for file uploads)
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required FormData formData,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: formData,
      );
      return _parseSuccessResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'File upload error: $e',
      );
    }
  }

  // =========================================================================
  // RESPONSE & ERROR PARSING
  // =========================================================================

  ApiResponse<T> _parseSuccessResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final body = response.data;
    if (body is Map) {
      final message = body['message']?.toString() ?? 'Operation completed successfully.';
      final rawData = body['data'] ?? body;

      T? parsedData;
      if (fromJson != null) {
        parsedData = fromJson(rawData);
      } else if (rawData is T) {
        parsedData = rawData;
      }

      return ApiResponse<T>(
        success: true,
        message: message,
        data: parsedData,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<T>(
      success: true,
      message: 'Success',
      data: fromJson != null ? fromJson(body) : (body is T ? body : null),
      statusCode: response.statusCode,
    );
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiResponse<T>(
        success: false,
        message: 'Network connection timed out. Please verify server is responding.',
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiResponse<T>(
        success: false,
        message:
            'Cannot reach Laravel server at $currentBaseUrl.\nPlease ensure "php artisan serve" is running.',
        statusCode: 503,
      );
    }

    final response = error.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map) {
        final message = data['message']?.toString() ??
            data['error']?.toString() ??
            'Server responded with status ${response.statusCode}';
        final errors = data['errors'] is Map
            ? Map<String, dynamic>.from(data['errors'])
            : null;

        return ApiResponse<T>(
          success: false,
          message: message,
          errors: errors,
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponse<T>(
      success: false,
      message: error.message ?? 'Network request failed (${error.type.name}).',
      statusCode: response?.statusCode,
    );
  }
}
