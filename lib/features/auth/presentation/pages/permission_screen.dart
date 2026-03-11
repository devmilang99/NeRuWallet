import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  int _currentStep = 0;
  bool _isHandled = false;

  final List<PermissionStep> _steps = [
    PermissionStep(
      title: "Camera Access",
      subtitle:
          "Required for scanning QR codes and ID verification during KYC.",
      icon: Icons.camera_alt_rounded,
      permission: Permission.camera,
    ),
    PermissionStep(
      title: "Smart Notifications",
      subtitle: "Stay notified about your transactions and secure logins.",
      icon: Icons.notifications_active_rounded,
      permission: Permission.notification,
    ),
    PermissionStep(
      title: "Secure Storage",
      subtitle:
          "Needed to save transaction receipts and encrypted data locally.",
      icon: Icons.storage_rounded,
      permission: Permission.storage,
    ),
  ];

  Future<void> _requestNext() async {
    if (_currentStep < _steps.length) {
      final status = await _steps[_currentStep].permission.request();
      if (status.isGranted || status.isLimited || status.isPermanentlyDenied) {
        if (_currentStep == _steps.length - 1) {
          setState(() => _isHandled = true);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) context.go('/onboarding');
          });
        } else {
          setState(() => _currentStep++);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_currentStep];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppTheme.primaryColor
                          : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ).animate().fadeIn(),
              const Spacer(),
              _buildPermissionCard(isDark, step)
                  .animate(key: ValueKey(_currentStep))
                  .fadeIn()
                  .scale(begin: const Offset(0.9, 0.9)),
              const Spacer(),
              _buildPermissionInfoLine(
                context,
                isDark,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isHandled ? null : _requestNext,
                child: Text(
                  _currentStep == _steps.length - 1
                      ? "Get Started"
                      : "Allow Access",
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/onboarding'),
                child: Text(
                  "Skip for now",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(bool isDark, PermissionStep step) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 64, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionInfoLine(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 20,
          color: isDark ? Colors.white38 : Colors.black26,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            "You can manage these permissions in system settings.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ),
      ],
    );
  }
}

class PermissionStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Permission permission;

  PermissionStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.permission,
  });
}
