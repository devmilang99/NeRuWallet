import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_error.dart';
import '../theme/app_theme.dart';

class GlobalErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final AppError? appError;

  const GlobalErrorScreen({
    required this.error,
    this.stackTrace,
    this.appError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fallback to generic error if appError is not provided
    final displayError = appError ?? AppError.unexpected(error, stackTrace);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(displayError.type),
                  color: AppTheme.errorColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                displayError.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayError.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Suggestion: ${displayError.suggestion}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // If it's a network error, maybe we could retry or just close
                  SystemNavigator.pop();
                },
                child: const Text('Close App'),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(fontSize: 12),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      '${displayError.originalError}\n\n${displayError.stackTrace}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return Icons.wifi_off_rounded;
      case AppErrorType.auth:
        return Icons.lock_outline_rounded;
      case AppErrorType.database:
        return Icons.storage_rounded;
      case AppErrorType.security:
        return Icons.security_rounded;
      case AppErrorType.validation:
        return Icons.rule_rounded;
      case AppErrorType.unexpected:
        return Icons.error_outline_rounded;
    }
  }
}
