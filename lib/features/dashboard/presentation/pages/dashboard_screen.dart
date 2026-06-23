import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

import '../../data/models/nav_item_model.dart';
import '../widgets/biometric_prompt_sheet.dart';
import 'tabs/history_tab.dart';
import 'tabs/home_tab.dart';

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
  bool _isAuthenticating = false;

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
        _handleBiometricSecurity();
      }
    });
  }

  Future<void> _handleBiometricSecurity() async {
    if (_isAuthenticating) return;

    final prefService = ref.read(preferenceServiceProvider);
    final bool isEnabled =
        await prefService.getBool('biometrics_login_enabled') ?? false;

    if (isEnabled) {
      setState(() => _isAuthenticating = true);
      final bool authenticated = await BiometricService.authenticate(
        localizedReason: 'Unlock NeRuWallet',
      );
      if (mounted) {
        setState(() => _isAuthenticating = false);
        if (!authenticated) {
          context.go('/auth/login');
        }
      }
    } else {
      _checkAndPromptBiometrics();
    }
  }

  Future<void> _checkAndPromptBiometrics() async {
    if (_hasPromptedThisSession) return;

    try {
      final prefService = ref.read(preferenceServiceProvider);
      final bool onboardingCompleted =
          await prefService.getBool('biometric_onboarding_completed') ?? false;

      // If we've already shown the onboarding prompt, don't prompt again
      if (onboardingCompleted) return;

      final bool hasHardware = await BiometricService.hasHardwareSupport();

      if (hasHardware && mounted) {
        final List<BiometricType> availableBiometrics =
            await BiometricService.getAvailableBiometrics();

        // Only mark that we've prompted in this session; persistent onboarding
        // completion is handled by the bottom sheet actions (Confirm or Skip).
        _hasPromptedThisSession = true;

        if (availableBiometrics.isNotEmpty && mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            useRootNavigator: true,
            builder: (context) => BiometricPromptSheet(
              biometrics: availableBiometrics,
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

  Future<void> _initializeSession() async {
    final prefService = ref.read(preferenceServiceProvider);
    // Unique session ID for voucher management
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefService.setString('voucher_session_id', sessionId);
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
      final prefService = ref.read(preferenceServiceProvider);
      await prefService.setBool('is_first_time', false);
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
      _handleBiometricSecurity();
    }
  }

  Future<void> _loadKycStatus() async {
    final prefService = ref.read(preferenceServiceProvider);
    final isVerified = await prefService.getBool('is_kyc_verified') ?? false;
    if (mounted) {
      setState(() {
        _isKycVerified = isVerified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final balanceState = ref.watch(balanceProvider);
    final List<Transaction> transactions = balanceState.transactions;

    final bottomInset = MediaQuery.of(context).padding.bottom;

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
                  totalIncome: balanceState.totalIncome,
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
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomInset > 0 ? bottomInset + 12 : 24,
                ),
                child: _buildBottomNav(isDark),
              ),
            ),
            // Floating Scan Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomInset > 0 ? bottomInset + 11 : 23,
                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 32),
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
