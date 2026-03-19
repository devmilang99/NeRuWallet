import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BiometricPromptSheet extends StatelessWidget {
  final List<BiometricType> biometrics;
  final LocalAuthentication auth;
  final VoidCallback onEnrolled;

  const BiometricPromptSheet({
    super.key,
    required this.biometrics,
    required this.auth,
    required this.onEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFace = biometrics.contains(BiometricType.face);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFace ? Icons.face_unlock_rounded : Icons.fingerprint_rounded,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            "Enable Biometric Login",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Use your ${hasFace ? 'Face ID' : 'fingerprint'} for faster and more secure access to your wallet next time.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final bool didAuthenticate = await auth.authenticate(
                    localizedReason: 'Please authenticate to enable biometric login',
                    options: const AuthenticationOptions(
                      stickyAuth: true,
                      biometricOnly: true,
                    ),
                  );
                  if (didAuthenticate) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('biometrics_enabled', true);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      onEnrolled();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Biometric login enabled successfully!"),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusLarge,
                ),
              ),
              child: const Text("Enroll Now", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Maybe Later",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
