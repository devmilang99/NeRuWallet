import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textBodyColor),
              ),
              const SizedBox(height: 24),
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBodyColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join NeRuWallet and manage your financial life efficiently.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textHintColor,
                    ),
              ),
              const SizedBox(height: 36),
              // Full Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email address",
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textHintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  hintText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Handle Signup
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: AppTheme.textHintColor),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
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
}
