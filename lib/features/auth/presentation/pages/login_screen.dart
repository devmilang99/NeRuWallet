import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
              const SizedBox(height: 48),
              Text(
                "Welcome Back!",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBodyColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to your account to continue.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textHintColor,
                    ),
              ),
              const SizedBox(height: 48),
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Handle Login
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.textHintColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Or", style: TextStyle(color: AppTheme.textHintColor)),
                  ),
                  Expanded(child: Divider(color: AppTheme.textHintColor)),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  // Google Sign In
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppTheme.textHintColor, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg",
                      height: 24,
                    ), // Fallback if no network
                    const SizedBox(width: 12),
                    const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBodyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: AppTheme.textHintColor),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: const Text(
                      "Sign Up",
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
