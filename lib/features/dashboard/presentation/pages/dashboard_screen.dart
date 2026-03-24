import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/quick_action_model.dart';
import '../../data/models/nav_item_model.dart';
import '../widgets/biometric_prompt_sheet.dart';
import 'tabs/home_tab.dart';
import 'tabs/pay_tab.dart';
import 'tabs/history_tab.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  static const List<TransactionModel> _transactions = [
    TransactionModel(
      title: 'Merchant Payment',
      subtitle: 'Pizza Palace',
      amount: -1250.00,
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6B6B),
      time: '10:32 AM',
    ),
    TransactionModel(
      title: 'Money Received',
      subtitle: 'Rajan Sharma',
      amount: 5000.00,
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFF10B981),
      time: 'Yesterday',
    ),
    TransactionModel(
      title: 'Utility Bill',
      subtitle: 'NEA Electricity',
      amount: -850.00,
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B),
      time: 'Feb 28',
    ),
    TransactionModel(
      title: 'QR Transfer',
      subtitle: 'Suraj Tamang',
      amount: -2000.00,
      icon: Icons.qr_code_rounded,
      color: Color(0xFF6366F1),
      time: 'Feb 27',
    ),
    TransactionModel(
      title: 'Top-up ',
      subtitle: 'eSewa Wallet',
      amount: 10000.00,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
      time: 'Feb 26',
    ),
    TransactionModel(
      title: 'Mobile Recharge',
      subtitle: 'Ncell Postpaid',
      amount: -500.00,
      icon: Icons.phone_android_rounded,
      color: Color(0xFF8B5CF6),
      time: 'Feb 25',
    ),
    TransactionModel(
      title: 'Internet Bill',
      subtitle: 'WorldLink ISP',
      amount: -999.00,
      icon: Icons.wifi_rounded,
      color: Color(0xFF0EA5E9),
      time: 'Feb 24',
    ),
  ];

  static const List<QuickActionModel> _quickActions = [
    QuickActionModel(
      label: 'Send',
      icon: Icons.arrow_upward_rounded,
      color: Color(0xFF6366F1),
    ),
    QuickActionModel(
      label: 'Receive',
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFF10B981),
    ),
    QuickActionModel(
      label: 'Scan QR',
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFFF59E0B),
    ),
    QuickActionModel(
      label: 'Top Up',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF8B5CF6),
    ),
    QuickActionModel(
      label: 'Pay Bill',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFEC4899),
    ),
    QuickActionModel(
      label: 'Exchange',
      icon: Icons.currency_exchange_rounded,
      color: Color(0xFF0EA5E9),
    ),
  ];

  int _selectedTab = 0;
  bool _balanceVisible = true;
  bool _hasPromptedThisSession = false;
  bool _isKycVerified = false;
  final LocalAuthentication _auth = LocalAuthentication();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadKycStatus();
    _markOnboardingComplete();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndPromptBiometrics();
      }
    });
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
          _hasPromptedThisSession = true;
          // Mark onboarding as completed so we don't prompt every time
          await prefs.setBool('biometric_onboarding_completed', true);

          if (!mounted) return;

          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
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
        body: IndexedStack(
          index: _selectedTab,
          children: [
            HomeTab(
              isDark: isDark,
              balanceVisible: _balanceVisible,
              isKycVerified: _isKycVerified,
              onToggleBalance: () =>
                  setState(() => _balanceVisible = !_balanceVisible),
              onProfileTap: () {
                context.push('/profile');
              },
              transactions: _transactions,
              quickActions: _quickActions,
            ),
            PayTab(isDark: isDark),
            HistoryTab(isDark: isDark, transactions: _transactions),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(isDark),
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
      activeIcon: Icons.send_rounded,
      inactiveIcon: Icons.send_outlined,
      label: 'Pay',
    ),
    NavItemModel(
      activeIcon: Icons.receipt_long_rounded,
      inactiveIcon: Icons.receipt_long_outlined,
      label: 'History',
    ),
  ];

  Widget _buildBottomNav(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
            (i) => _buildNavItem(_navItems[i], i, isDark),
          ),
        ),
      ),
    );
  }


  Widget _buildNavItem(NavItemModel item, int i, bool isDark) {
    final isActive = _selectedTab == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
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
