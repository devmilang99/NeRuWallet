import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_error.dart';
import '../utils/logger.dart';

final scaffoldMessengerKeyProvider = Provider(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);

final errorHandlerProvider = Provider((ref) {
  return ErrorHandlerService(ref);
});

class ErrorHandlerService {
  final Ref _ref;

  ErrorHandlerService(this._ref);

  AppError mapError(Object error, [StackTrace? stackTrace]) {
    if (error is SocketException || error is TimeoutException) {
      return AppError.network(error, stackTrace);
    }

    if (error is AuthException) {
      return AppError(
        title: 'Access Denied',
        message: error.message,
        suggestion: 'Please try signing in again.',
        type: AppErrorType.auth,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PostgrestException) {
      return AppError(
        title: 'Database Error',
        message: 'We had trouble retrieving your data.',
        suggestion: 'Please pull to refresh or try again later.',
        type: AppErrorType.database,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppError.unexpected(error, stackTrace);
  }

  void handleError(
    Object error, {
    StackTrace? stackTrace,
    bool showSnackbar = false,
  }) {
    final appError = mapError(error, stackTrace);

    AppLogger.e(appError.toString(), error, stackTrace);

    if (showSnackbar) {
      showErrorSnackbar(appError);
    }
  }

  void showErrorSnackbar(AppError error) {
    final messenger = _ref.read(scaffoldMessengerKeyProvider).currentState;
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                error.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(error.message, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'Tip: ${error.suggestion}',
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
  }
}
