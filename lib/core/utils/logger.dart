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

    // ANSI Color Codes
    const reset = '\x1B[0m';
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const cyan = '\x1B[36m';
    const magenta = '\x1B[35m';

    String color;
    switch (level) {
      case 'DEBUG':
        color = cyan;
        break;
      case 'INFO':
        color = green;
        break;
      case 'WARN':
        color = yellow;
        break;
      case 'ERROR':
        color = red;
        break;
      case 'FATAL':
        color = magenta;
        break;
      default:
        color = reset;
    }

    debugPrint('$color[$timestamp] [$level] $message$reset');
    if (error != null) debugPrint('$red Error: $error$reset');
    if (stackTrace != null)
      debugPrint('$magenta StackTrace: $stackTrace$reset');
  }
}
