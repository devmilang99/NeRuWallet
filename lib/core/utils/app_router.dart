import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekyc_shared/router.dart' as kyc;
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/permission_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/dashboard/presentation/pages/profile_screen.dart';
import '../../features/dashboard/presentation/pages/qr_scanner_screen.dart';
import '../../features/transactions/presentation/pages/send_money_screen.dart';
import '../../features/transactions/presentation/pages/receive_money_screen.dart';
import '../../features/transactions/presentation/pages/top_up_screen.dart';
import '../../features/transactions/presentation/pages/pay_bill_screen.dart';
import '../../features/onboarding/presentation/pages/theme_selection_screen.dart';
import '../../features/exchange/presentation/pages/exchange_rate_screen.dart';

import '../../features/auth/presentation/pages/security_setup_screen.dart';
import '../../features/auth/presentation/pages/transaction_pin_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/theme-selection',
      builder: (context, state) => const ThemeSelectionScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/signup',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/security-setup',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SecuritySetupScreen(
          isSocialLogin: extra?['isSocial'] ?? false,
          signupData: extra,
        );
      },
    ),
    GoRoute(
      path: '/auth/pin-setup',
      builder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          final mode = data['mode'] as PinMode? ?? (data.containsKey('signupData') ? PinMode.set : PinMode.verify);
          
          return TransactionPinScreen(
            mode: mode,
            signupData: data['signupData'],
            onSuccess: data['onSuccess'] as VoidCallback?,
          );
        }
        
        final mode = state.extra as PinMode? ?? PinMode.verify;
        return TransactionPinScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        child: const DashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/qr-pay',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const QrScannerScreen(),
      ),
    ),
    GoRoute(
      path: '/transfer',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const SendMoneyScreen(),
      ),
    ),
    GoRoute(
      path: '/receive',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const ReceiveMoneyScreen(),
      ),
    ),
    GoRoute(
      path: '/top-up',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const TopUpScreen(),
      ),
    ),
    GoRoute(
      path: '/pay-bill',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const PayBillScreen(),
      ),
    ),
    GoRoute(
      path: '/exchange-rates',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const ExchangeRateScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const ProfileScreen(),
      ),
    ),
    ...kyc.kycRoutes,
  ],
);

CustomTransitionPage _buildPageWithSlideTransition({required Widget child}) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeOutQuart;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

CustomTransitionPage _buildPageWithFadeTransition({required Widget child}) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}



