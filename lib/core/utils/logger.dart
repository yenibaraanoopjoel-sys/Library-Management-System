import 'package:flutter/foundation.dart';

/// Application logging utility
class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('[ERROR DETAILS] $error');
    if (stackTrace != null) debugPrint('[STACKTRACE] $stackTrace');
  }
}
