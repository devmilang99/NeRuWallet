import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Centralized logger for the application with high visibility.
class AppLogger {
  // ANSI Escape Codes
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _cyan = '\x1B[36m';
  static const _magenta = '\x1B[35m';

  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) _log('DEBUG', message, error, stackTrace);
  }

  static void i(String message) => _log('INFO', message);

  static void w(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('WARN', message, error, stackTrace);

  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('ERROR', message, error, stackTrace);

  static void fatal(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('FATAL', message, error, stackTrace);

  static void _log(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final (emoji, color, logLevel) = switch (level) {
      'DEBUG' => ('🐛', _cyan, 500),
      'INFO' => ('ℹ️ ', _green, 800),
      'WARN' => ('⚠️ ', _yellow, 900),
      'ERROR' => ('🚨', _red, 1000),
      'FATAL' => ('💀', _magenta, 1200),
      _ => ('📝', _reset, 0),
    };

    final timestamp = DateTime.now()
        .toIso8601String()
        .split('T')
        .last
        .substring(0, 8);

    // Construct the highly visible message
    final fullMessage = '$color[$timestamp] $emoji [$level] $message$_reset';

    dev.log(
      fullMessage,
      name: 'NeRu',
      level: logLevel,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    // Also use debugPrint for standard console support
    if (kDebugMode && level != 'DEBUG') {
      debugPrint(fullMessage);
    }
  }
}
