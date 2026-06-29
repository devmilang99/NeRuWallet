import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/change_password_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/permission_screen.dart';
import '../../features/auth/presentation/pages/security_setup_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/transaction_pin_screen.dart';
import '../../features/dashboard/presentation/pages/biometric_settings_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/dashboard/presentation/pages/help_support_screen.dart';
import '../../features/dashboard/presentation/pages/notification_screen.dart';
import '../../features/dashboard/presentation/pages/personal_info_screen.dart';
import '../../features/dashboard/presentation/pages/privacy_policy_screen.dart';
import '../../features/dashboard/presentation/pages/profile_screen.dart';
import '../../features/dashboard/presentation/pages/qr_scanner_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/theme_selection_screen.dart';
import '../../features/services/presentation/pages/all_services_screen.dart'; // Service Screens
import '../../features/services/presentation/pages/bills/bill_payment_screen.dart';
import '../../features/services/presentation/pages/finance/exchange_rate_screen.dart';
import '../../features/services/presentation/pages/finance/send_money_screen.dart';
import '../../features/services/presentation/pages/finance/top_up_screen.dart';
import '../../features/services/presentation/pages/finance/withdraw_screen.dart';
import '../../features/services/presentation/pages/government/fine_payment_screen.dart';
import '../../features/services/presentation/pages/merchant/food_delivery_screen.dart';
import '../../features/services/presentation/pages/merchant/shopping_screen.dart';
import '../../features/services/presentation/pages/merchant/tickets_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/permissions',
      name: 'permissions',
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
    // Removed /biometric-enrollment route as it is now handled via Dashboard prompt
    GoRoute(
      path: '/auth/login',
      name: 'login',
      pageBuilder: (context, state) =>
          _buildPageWithFadeTransition(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/auth/signup',
      pageBuilder: (context, state) =>
          _buildPageWithFadeTransition(child: const SignupScreen()),
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
          final mode =
              data['mode'] as PinMode? ??
              (data.containsKey('signupData') ? PinMode.set : PinMode.verify);

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
      pageBuilder: (context, state) =>
          _buildPageWithFadeTransition(child: const DashboardScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const NotificationScreen()),
    ),

    // Finance Routes
    GoRoute(
      path: '/top-up',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const TopUpScreen()),
    ),
    GoRoute(
      path: '/withdraw',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const WithdrawScreen()),
    ),
    GoRoute(
      path: '/exchange-rates',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const ExchangeRateScreen()),
    ),
    GoRoute(
      path: '/qr-pay',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const QrScannerScreen()),
    ),
    GoRoute(
      path: '/send-money',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const SendMoneyScreen()),
    ),

    // Bills Routes
    GoRoute(
      path: '/electricity',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const BillPaymentScreen(
          billType: 'Electricity',
          icon: Icons.bolt_rounded,
          color: Colors.orange,
          label: 'SC Number',
        ),
      ),
    ),
    GoRoute(
      path: '/water',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const BillPaymentScreen(
          billType: 'Water',
          icon: Icons.water_drop_rounded,
          color: Colors.blue,
          label: 'Customer',
        ),
      ),
    ),
    GoRoute(
      path: '/internet',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const BillPaymentScreen(
          billType: 'Internet',
          icon: Icons.wifi_rounded,
          color: Colors.blue,
          label: 'Username',
        ),
      ),
    ),

    // Government Routes
    GoRoute(
      path: '/fine-payment',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const FinePaymentScreen()),
    ),

    // Merchant Routes
    GoRoute(
      path: '/tickets',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const TicketsScreen()),
    ),
    GoRoute(
      path: '/food',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const FoodDeliveryScreen()),
    ),
    GoRoute(
      path: '/shopping',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const ShoppingScreen()),
    ),
    GoRoute(
      path: '/all-services',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const AllServicesScreen()),
    ),

    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          _buildPageWithSlideTransition(child: const ProfileScreen()),
      routes: [
        GoRoute(
          path: 'personal-info',
          builder: (context, state) => const PersonalInformationScreen(),
        ),
        GoRoute(
          path: 'help-support',
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: 'privacy-policy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: 'biometric-settings',
          builder: (context, state) => const BiometricSettingsScreen(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    ),
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
