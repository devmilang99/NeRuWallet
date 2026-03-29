import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassDialog {
  static void showLoading(
    BuildContext context, {
    String message = 'Processing...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Fully handled by BackdropFilter
      builder:
          (context) => _GlassDialogBase(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 6,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => _GlassDialogBase(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.errorColor,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Action Failed',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 60),
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) => _GlassDialogBase(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.successColor,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Success!',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onConfirm != null) onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 60),
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  static void showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => _GlassDialogBase(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onCancel != null) onCancel();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDestructive
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

class _GlassDialogBase extends StatelessWidget {
  final Widget child;
  const _GlassDialogBase({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Full-screen backdrop blur
          Positioned.fill(
            child: GestureDetector(
              // Prevent closing on tap if you want, or handle it
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: (isDark ? Colors.black : Colors.white).withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
            ),
          ),
          // Dialog Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: (isDark ? colorScheme.surface : Colors.white)
                        .withValues(alpha: isDark ? 0.85 : 0.9),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: child,
                ).animate().scale(
                  duration: 400.ms,
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOutBack,
                ).fadeIn(duration: 300.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
