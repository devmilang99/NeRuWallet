import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/theme/app_theme.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isRequesting = false;
  // State for each: 0=Initial, 1=Granted, 2=Denied, 3=PermanentlyDenied
  List<int> _permissionStates = [];

  List<PermissionStep> _steps = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSteps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("PermissionScreen Resumed: Re-checking state to avoid hang.");
    }
  }

  Future<void> _initializeSteps() async {
    final List<PermissionStep> allSteps = [
      PermissionStep(
        title: "Camera Access",
        subtitle: "Required for scanning QR codes and ID verification.",
        icon: Icons.camera_alt_rounded,
        permission: Permission.camera,
        color: const Color(0xFF6366F1),
      ),
      PermissionStep(
        title: "Smart Notifications",
        subtitle: "Stay notified about transactions and secure logins.",
        icon: Icons.notifications_active_rounded,
        permission: Permission.notification,
        color: const Color(0xFF10B981),
      ),
      PermissionStep(
        title: "Media Storage",
        subtitle: "Needed to save receipts and documents to your device.",
        icon: Icons.storage_rounded,
        permission: Permission.storage, // We'll adjust below
        color: const Color(0xFFF59E0B),
      ),
      PermissionStep(
        title: "Contacts Access",
        subtitle: "Easily find and send money to your friends.",
        icon: Icons.contacts_rounded,
        permission: Permission.contacts,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    List<PermissionStep> ungrantedSteps = [];
    
    int androidVersion = 0;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      androidVersion = deviceInfo.version.sdkInt;
    }

    for (final step in allSteps) {
      final targetPerm = step.permission;
      // Handle Storage Permission correctly for Android 33+
      if (step.title == "Media Storage" && Platform.isAndroid) {
        if (androidVersion >= 33) {
          // On Android 13+, we check for specific media permissions
          final photosStatus = await Permission.photos.status;
          final videosStatus = await Permission.videos.status;
          if (photosStatus.isGranted && videosStatus.isGranted) {
            continue; // Already granted
          }
          ungrantedSteps.add(step.copyWith(permission: Permission.photos));
        } else {
          // On Android 12 and below, use standard storage permission
          final status = await Permission.storage.status;
          if (status.isGranted) continue;
          ungrantedSteps.add(step.copyWith(permission: Permission.storage));
        }
      } else {
        final status = await targetPerm.status;
        if (!status.isGranted) {
          ungrantedSteps.add(step.copyWith(permission: targetPerm));
        }
      }
    }

    if (mounted) {
      setState(() {
        _steps = ungrantedSteps;
        _permissionStates = List.filled(_steps.length, 0);
      });
      
      // If all granted, go to onboarding directly
      if (_steps.isEmpty) {
        context.go('/onboarding');
      }
    }
  }

  Future<void> _handlePermissionRequest() async {
    if (_isRequesting) return;
    
    setState(() => _isRequesting = true);
    
    try {
      final step = _steps[_currentStep];
      
      // Special handling for storage on modern Android
      Permission targetPermission = step.permission;
      
      if (step.title == "Media Storage" && Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt >= 33) {
          // Request photos and videos for Android 13+
          final results = await [Permission.photos, Permission.videos].request();
          if (results[Permission.photos]!.isGranted && results[Permission.videos]!.isGranted) {
             _updateState(1);
             _nextPage();
          } else {
             _handleDenied(results[Permission.photos]!, step);
          }
          return;
        }
      }

      final status = await targetPermission.request();
      _handleDenied(status, step);
    } catch (e) {
      debugPrint("Permission Error: $e");
      _showErrorSnackBar("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  void _handleDenied(PermissionStatus status, PermissionStep step) {
    if (status.isGranted || status.isLimited) {
      _updateState(1);
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      _updateState(3);
      _showErrorSnackBar("Permission permanently denied. Please enable it in settings.", isPermanent: true);
    } else {
      _updateState(2);
      _showErrorSnackBar("${step.title} is necessary for specific features.");
    }
  }

  void _updateState(int state) {
    if (mounted) {
      setState(() {
        _permissionStates[_currentStep] = state;
      });
    }
  }

  void _nextPage() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Check if Camera was in our steps and if it was granted
    bool cameraInSteps = _steps.any((s) => s.permission == Permission.camera);
    bool cameraGrantedLocally = false;
    
    if (cameraInSteps) {
      int index = _steps.indexWhere((s) => s.permission == Permission.camera);
      cameraGrantedLocally = _permissionStates[index] == 1;
    }

    // Double check with actual system status
    bool isCameraGranted = await Permission.camera.isGranted;
    
    if (!isCameraGranted && !cameraGrantedLocally) {
      _showErrorSnackBar("Camera access is mandatory for security verification.");
      if (cameraInSteps) {
        int index = _steps.indexWhere((s) => s.permission == Permission.camera);
        _pageController.animateToPage(index, duration: 600.ms, curve: Curves.easeInOut);
      }
      return;
    }
    
    if (mounted) context.go('/onboarding');
  }

  void _showErrorSnackBar(String message, {bool isPermanent = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        action: isPermanent 
            ? SnackBarAction(
                label: "Settings", 
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildPermissionPage(_steps[index], _permissionStates[index], isDark);
                },
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: _steps.isEmpty 
                    ? const SizedBox.shrink() 
                    : FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_currentStep + 1) / _steps.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
              ),
              Text(
                _steps.isEmpty ? "" : "${_currentStep + 1} of ${_steps.length}",
                style: TextStyle(
                  color: isDark ? Colors.white38 : AppTheme.textHintColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Quick Setup",
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textBodyColor,
              fontWeight: FontWeight.w900,
              fontSize: 32,
            ),
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPermissionPage(PermissionStep step, int state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 100,
              color: step.color,
            ).animate(key: ValueKey(step.title)).scale(duration: 600.ms, curve: Curves.elasticOut),
          ),
          const SizedBox(height: 48),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textBodyColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppTheme.textSecondaryColor,
              fontSize: 16,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          _buildStatusIndicator(state, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(int state, bool isDark) {
    if (state == 0) return const SizedBox.shrink();

    String text;
    Color color;
    IconData icon;

    switch (state) {
      case 1:
        text = "Access Granted";
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      case 2:
        text = "Access Denied";
        color = AppTheme.errorColor;
        icon = Icons.error_rounded;
        break;
      case 3:
        text = "Permanently Denied";
        color = AppTheme.errorColor;
        icon = Icons.settings_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    ).animate().scale();
  }

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _handlePermissionRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
              child: _isRequesting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentStep == _steps.length - 1 && _permissionStates[_currentStep] == 1 
                        ? "Get Started" 
                        : "Grant Access",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _nextPage(), // Moves to the next slider when skipping
            child: Text(
              _currentStep == _steps.length - 1 ? "Finish Setup" : "Skip this",
              style: TextStyle(
                color: isDark ? Colors.white38 : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Permission permission;
  final Color color;

  PermissionStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.permission,
    required this.color,
  });

  PermissionStep copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
    Permission? permission,
    Color? color,
  }) {
    return PermissionStep(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      permission: permission ?? this.permission,
      color: color ?? this.color,
    );
  }
}


