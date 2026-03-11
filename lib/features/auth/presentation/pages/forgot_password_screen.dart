import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ).animate().fadeIn().slideX(begin: -0.5, end: 0),
              const SizedBox(height: 32),
              Text(
                "Recover Password",
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceDark.withOpacity(0.6)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: AppTheme.radiusLarge,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email address",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "example@domain.com",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            // Handle Recovery
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusMedium,
                            ),
                          ),
                          child: const Text("Send Reset Link"),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
