enum ApiErrorCode {
  invalidCredentials,
  validationError,
  unauthenticated,
  forbidden,
  notFound,
  tooManyRequests,
  attendanceNotEditable,
  serverError,
  network,
  timeout,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fields,
  });

  final ApiErrorCode code;
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fields;

  bool get isUnauthorized =>
      code == ApiErrorCode.unauthenticated ||
      code == ApiErrorCode.invalidCredentials;

  bool get isTransient =>
      code == ApiErrorCode.network || code == ApiErrorCode.timeout;

  static ApiErrorCode fromApiCode(String? raw) {
    return switch (raw) {
      'invalid_credentials' => ApiErrorCode.invalidCredentials,
      'validation_error' => ApiErrorCode.validationError,
      'unauthenticated' => ApiErrorCode.unauthenticated,
      'forbidden' => ApiErrorCode.forbidden,
      'not_found' => ApiErrorCode.notFound,
      'too_many_requests' => ApiErrorCode.tooManyRequests,
      'attendance_not_editable' => ApiErrorCode.attendanceNotEditable,
      'server_error' => ApiErrorCode.serverError,
      _ => ApiErrorCode.unknown,
    };
  }
}
