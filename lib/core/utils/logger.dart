import 'package:flutter/foundation.dart';

/// Centralized logger for the application.
/// In production, this can be easily connected to Sentry or a log management service.
class AppLogger {
  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _printLog('DEBUG', message, error, stackTrace);
    }
  }

  static void i(String message) {
    _printLog('INFO', message);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    _printLog('WARN', message, error, stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _printLog('ERROR', message, error, stackTrace);
    // TODO: Add Crashlytics recordError here for production
  }

  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _printLog('FATAL', message, error, stackTrace);
    // This could trigger a crash report immediately
  }

  static void _printLog(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final timestamp = DateTime.now().toIso8601String().split('T').last;
    debugPrint('[$timestamp] [$level] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}
