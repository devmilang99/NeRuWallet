import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/nav_item_model.dart';
import '../widgets/biometric_prompt_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'tabs/home_tab.dart';
import 'tabs/history_tab.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {

  int _selectedTab = 0;
  bool _balanceVisible = true;
  bool _hasPromptedThisSession = false;
  bool _isKycVerified = false;
  String _userName = 'User';
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
    _loadKycStatus();
    _loadUserName();
    _markOnboardingComplete();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndPromptBiometrics();
      }
    });
  }

  Future<void> _initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Unique session ID for voucher management
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString('voucher_session_id', sessionId);
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userName = user.displayName ?? 'User';
      });
    }
  }

  Future<void> _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_time', false);
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadKycStatus();
    }
  }

  Future<void> _loadKycStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isKycVerified = prefs.getBool('is_kyc_verified') ?? false;
      });
    }
  }

  Future<void> _checkAndPromptBiometrics() async {
    if (_hasPromptedThisSession) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isEnrolled = prefs.getBool('biometrics_enabled') ?? false;
      final bool onboardingCompleted =
          prefs.getBool('biometric_onboarding_completed') ?? false;

      // Just load the preferences, we don't need to store _biometricsEnabled in state anymore

      // If already enrolled or if we've already shown the onboarding prompt, don't prompt again
      if (isEnrolled || onboardingCompleted) return;

      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (canAuthenticate && mounted) {
        final List<BiometricType> availableBiometrics = await _auth
            .getAvailableBiometrics();

        if (availableBiometrics.isNotEmpty && mounted) {
          // Strictly mark onboarding as completed the first time we show it (or attempt to)
          await prefs.setBool('biometric_onboarding_completed', true);
          _hasPromptedThisSession = true;

          if (!mounted) return;

          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            useRootNavigator: true,
            builder: (context) => BiometricPromptSheet(
              biometrics: availableBiometrics,
              auth: _auth,
              onEnrolled: () {
                // Biometrics enrolled successfully
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Biometric Check Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final balanceState = ref.watch(balanceProvider);
    final transactions = balanceState.transactions;

    return PopScope(
      // Prevent the default pop — we handle it ourselves with a dialog.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Show exit confirmation instead of immediately closing the app.
        GlassDialog.showConfirm(
          context,
          title: 'Exit App',
          message: 'Are you sure you want to exit NeRuWallet?',
          confirmText: 'Exit',
          isDestructive: true,
          onConfirm: () => SystemNavigator.pop(),
        );
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedTab,
              children: [
                HomeTab(
                  isDark: isDark,
                  userName: _userName,
                  balanceVisible: _balanceVisible,
                  isKycVerified: _isKycVerified,
                  onToggleBalance: () =>
                      setState(() => _balanceVisible = !_balanceVisible),
                  onProfileTap: () {
                    context.push('/profile');
                  },
                  transactions: transactions,
                  totalBalance: balanceState.totalBalance,
                  totalExpenses: balanceState.totalExpenses,
                ),
                _selectedTab == 1
                    ? HistoryTab(isDark: isDark, transactions: transactions)
                    : const SizedBox.shrink(), // Lazy load HistoryTab
              ],
            ),
            // Floating Bottom Nav
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomNav(isDark),
            ),
            // Floating Scan Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25), // Adjusted position
                child: _buildScanButton(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<NavItemModel> _navItems = [
    NavItemModel(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    NavItemModel(
      activeIcon: Icons.receipt_long_rounded,
      inactiveIcon: Icons.receipt_long_outlined,
      label: 'History',
    ),
  ];

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      height: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.surfaceDark : Colors.white).withValues(
                alpha: 0.7,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.1,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(_navItems[0], 0, isDark),
                const SizedBox(width: 40), // Gap for the FAB
                _buildNavItem(_navItems[1], 1, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/qr-pay'),
              borderRadius: BorderRadius.circular(20),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    ).animate().scale(
      delay: 500.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildNavItem(NavItemModel item, int i, bool isDark) {
    final isActive = _selectedTab == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.inactiveIcon,
                key: ValueKey(isActive),
                color: isActive
                    ? AppTheme.primaryColor
                    : (isDark ? AppTheme.textHintDark : AppTheme.textHintColor),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? AppTheme.primaryColor
                    : (isDark ? AppTheme.textHintDark : AppTheme.textHintColor),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
