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
import '../../features/onboarding/presentation/pages/theme_selection_screen.dart';
import '../../features/exchange/presentation/pages/exchange_rate_screen.dart';

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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/exchange-rates',
      builder: (context, state) => const ExchangeRateScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    ...kyc.kycRoutes,
  ],
);
