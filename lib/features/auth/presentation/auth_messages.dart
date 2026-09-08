import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';

class AuthMessages {
  static String forException(ApiException exception) {
    return switch (exception.code) {
      ApiErrorCode.invalidCredentials => AppStrings.invalidCredentials,
      ApiErrorCode.tooManyRequests => AppStrings.tooManyRequests,
      ApiErrorCode.network => AppStrings.noConnection,
      ApiErrorCode.timeout => AppStrings.timeout,
      ApiErrorCode.unauthenticated => AppStrings.unauthenticated,
      ApiErrorCode.validationError => AppStrings.emailInvalid,
      _ => AppStrings.serverError,
    };
  }
}
