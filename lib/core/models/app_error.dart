enum AppErrorType { network, auth, database, security, unexpected, validation }

class AppError {
  final String title;
  final String message;
  final String suggestion;
  final AppErrorType type;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.title,
    required this.message,
    required this.suggestion,
    this.type = AppErrorType.unexpected,
    this.originalError,
    this.stackTrace,
  });

  factory AppError.unexpected(Object? error, [StackTrace? stack]) {
    return AppError(
      title: 'Unexpected Error',
      message: 'Something went wrong on our end.',
      suggestion: 'Please try again later or restart the app.',
      originalError: error,
      stackTrace: stack,
    );
  }

  factory AppError.network(Object? error, [StackTrace? stack]) {
    return AppError(
      title: 'Connection Issue',
      message: "We couldn't reach our servers.",
      suggestion: 'Please check your internet connection and try again.',
      type: AppErrorType.network,
      originalError: error,
      stackTrace: stack,
    );
  }

  factory AppError.auth(Object? error, [StackTrace? stack]) {
    return AppError(
      title: 'Authentication Failed',
      message: 'There was a problem verifying your identity.',
      suggestion: 'Please try logging in again.',
      type: AppErrorType.auth,
      originalError: error,
      stackTrace: stack,
    );
  }

  @override
  String toString() => 'AppError($title: $message)';
}
