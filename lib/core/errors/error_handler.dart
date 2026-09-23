import 'app_exception.dart';

/// Centralized error handling utility
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // TODO: Connect to remote crash reporting or local logger
  }
}
