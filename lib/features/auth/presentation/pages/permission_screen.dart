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
  bool _isNavigating = false;
  // State for each: 0=Initial, 1=Granted, 2=Denied
  final List<int> _permissionStates = [0, 0, 0, 0];

  final List<PermissionStep> _steps = [
    PermissionStep(
      title: "Camera Access",
      subtitle: "Required for scanning QR codes and ID verification.",
      icon: Icons.camera_alt_rounded,
      permission: Permission.camera,
    ),
    PermissionStep(
      title: "Smart Notifications",
      subtitle: "Stay notified about transactions and secure logins.",
      icon: Icons.notifications_active_rounded,
      permission: Permission.notification,
    ),
    PermissionStep(
      title: "Secure Storage",
      subtitle: "Needed to save receipts and encrypted data locally.",
      icon: Icons.storage_rounded,
      permission: Permission.storage,
    ),
    PermissionStep(
      title: "Contacts Access",
      subtitle: "Easily find and send money to your friends.",
      icon: Icons.contacts_rounded,
      permission: Permission.contacts,
    ),
  ];

  Future<void> _requestPermission() async {
    if (_currentStep < _steps.length) {
      final status = await _steps[_currentStep].permission.request();
      if (status.isGranted || status.isLimited) {
        setState(() {
          _permissionStates[_currentStep] = 1; // Granted
          _currentStep++;
        });

        if (_currentStep == _steps.length) {
          setState(() => _isNavigating = true);
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) context.go('/onboarding');
          });
        } else {
          // Automatically ask for the next permission
          Future.delayed(const Duration(milliseconds: 300), () {
            _requestPermission();
          });
        }
      } else {
        setState(() {
          _permissionStates[_currentStep] = 2; // Denied
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${_steps[_currentStep].title} is required for a better experience."),
              backgroundColor: AppTheme.errorColor,
              action: status.isPermanentlyDenied 
                  ? SnackBarAction(
                      label: "Settings", 
                      textColor: Colors.white,
                      onPressed: () => openAppSettings(),
                    )
                  : null,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Security & \nPermissions",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: isDark ? Colors.white : AppTheme.textBodyColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 40,
                      height: 1.1,
                    ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                "To ensure the highest level of security and provide a professional experience, NeRuWallet requires the following access.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.separated(
                  itemCount: _steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    final state = _permissionStates[index];
                    final isActive = _currentStep == index;

                    return _buildPermissionTile(step, state, isActive, index, isDark);
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_currentStep < _steps.length && !_isNavigating) ? _requestPermission : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusLarge,
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    _currentStep == _steps.length ? "All Set!" : "Grant Access",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding'),
                  child: Text(
                    "Skip for now",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppTheme.textSecondaryColor,
                      fontSize: 16
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(PermissionStep step, int state, bool isActive, int index, bool isDark) {
    // state: 0=Initial, 1=Granted, 2=Denied
    final bool isGranted = state == 1;
    final bool isDenied = state == 2;

    Color tileColor;
    Color borderColor;
    Color iconBgColor;
    Color iconColor;

    if (isGranted) {
      tileColor = Colors.green.withOpacity(isDark ? 0.1 : 0.05);
      borderColor = Colors.green.withOpacity(0.3);
      iconBgColor = Colors.green.withOpacity(0.2);
      iconColor = isDark ? Colors.greenAccent : Colors.green[700]!;
    } else if (isDenied) {
      tileColor = AppTheme.errorColor.withOpacity(isDark ? 0.1 : 0.05);
      borderColor = AppTheme.errorColor.withOpacity(0.3);
      iconBgColor = AppTheme.errorColor.withOpacity(0.2);
      iconColor = AppTheme.errorColor;
    } else if (isActive) {
      tileColor = AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.05);
      borderColor = AppTheme.primaryColor.withOpacity(0.5);
      iconBgColor = AppTheme.primaryColor.withOpacity(0.1);
      iconColor = AppTheme.primaryColor;
    } else {
      tileColor = isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50]!;
      borderColor = isDark ? Colors.white12 : Colors.grey[200]!;
      iconBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!;
      iconColor = isDark ? Colors.white38 : Colors.grey[400]!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check_rounded : (isDenied ? Icons.close_rounded : step.icon),
              color: iconColor,
              size: 28,
            ).animate(target: (isGranted || isDenied) ? 1 : 0).scale(duration: 400.ms, curve: Curves.elasticOut),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textBodyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 30)
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0, 0), curve: Curves.elasticOut)
          else if (isDenied)
            const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 30)
                .animate()
                .fadeIn()
                .shake()
          else if (isActive)
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryColor.withOpacity(0.5), size: 20)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds)
        ],
      ),
    ).animate(delay: (150 * index).ms).fadeIn().slideX(begin: 0.1, end: 0);
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
