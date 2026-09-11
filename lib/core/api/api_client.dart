import 'dart:io';

import 'package:dio/dio.dart';
import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_exception.dart';

typedef UnauthorizedHandler = void Function();

class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? dio,
    this.onUnauthorized,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken;
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  UnauthorizedHandler? onUnauthorized;
  String? _accessToken;
  bool _notifyingUnauthorized = false;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send(() => _dio.get<dynamic>(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool skipAuth = false,
  }) {
    return _send(
      () => _dio.post<dynamic>(
        path,
        data: body,
        options: Options(extra: {'skipAuth': skipAuth}),
      ),
      skipUnauthorizedHandler: skipAuth,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send(() => _dio.put<dynamic>(path, data: body));
  }

  Future<Map<String, dynamic>> delete(String path) {
    return _send(() => _dio.delete<dynamic>(path));
  }

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request, {
    bool skipUnauthorizedHandler = false,
  }) async {
    try {
      final response = await request();
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error, skipUnauthorizedHandler);
    }
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is! Map) {
      throw const ApiException(
        code: ApiErrorCode.serverError,
        message: 'Unexpected response.',
      );
    }
    final map = Map<String, dynamic>.from(data);
    if (map['success'] == false) {
      throw _fromErrorPayload(map, null);
    }
    final payload = map['data'];
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return map;
  }

  ApiException _mapDioException(
    DioException error,
    bool skipUnauthorizedHandler,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          code: ApiErrorCode.timeout,
          message: 'Request timed out.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          code: ApiErrorCode.network,
          message: 'Connection unavailable.',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final exception = _fromErrorPayload(error.response?.data, status);
        if (!skipUnauthorizedHandler &&
            status == 401 &&
            exception.code == ApiErrorCode.unauthenticated) {
          _notifyUnauthorized();
        }
        return exception;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const ApiException(
            code: ApiErrorCode.network,
            message: 'Connection unavailable.',
          );
        }
        return const ApiException(
          code: ApiErrorCode.unknown,
          message: 'Unexpected error.',
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return const ApiException(
          code: ApiErrorCode.network,
          message: 'Connection unavailable.',
        );
    }
  }

  ApiException _fromErrorPayload(dynamic data, int? statusCode) {
    Map<String, dynamic> map = const {};
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }
    final error = map['error'];
    Map<String, dynamic> errorMap = const {};
    if (error is Map) {
      errorMap = Map<String, dynamic>.from(error);
    }

    final rawCode = errorMap['code'] as String?;
    var code = ApiException.fromApiCode(rawCode);
    if (rawCode == null) {
      code = switch (statusCode) {
        401 => ApiErrorCode.unauthenticated,
        403 => ApiErrorCode.forbidden,
        404 => ApiErrorCode.notFound,
        422 => ApiErrorCode.validationError,
        429 => ApiErrorCode.tooManyRequests,
        409 => ApiErrorCode.attendanceNotEditable,
        _ => ApiErrorCode.serverError,
      };
    }

    Map<String, List<String>>? fields;
    final rawFields = errorMap['fields'];
    if (rawFields is Map) {
      fields = rawFields.map((key, value) {
        final list = value is List
            ? value.map((item) => item.toString()).toList()
            : <String>[value.toString()];
        return MapEntry(key.toString(), list);
      });
    }

    return ApiException(
      code: code,
      message: (errorMap['message'] as String?) ?? 'Request failed.',
      statusCode: statusCode,
      fields: fields,
    );
  }

  void _notifyUnauthorized() {
    if (_notifyingUnauthorized) {
      return;
    }
    _notifyingUnauthorized = true;
    try {
      onUnauthorized?.call();
    } finally {
      _notifyingUnauthorized = false;
    }
  }
}
