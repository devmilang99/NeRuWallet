import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/providers/kyc_provider.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

import '../../data/models/nav_item_model.dart';
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
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
    _loadUserName();
    _markOnboardingComplete();

    // Start background sync with Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).startPeriodicSync();
      _checkBiometricSetup();
    });
  }

  Future<void> _checkBiometricSetup() async {
    final prefService = ref.read(preferenceServiceProvider);

    // Check if we've already shown the prompt
    final promptShown =
        await prefService.getBool('biometrics_setup_prompt_shown') ?? false;
    if (promptShown) return;

    // Check if biometrics are enrolled on the device level
    final isEnrolled = await BiometricService.isEnrolled();
    if (!isEnrolled) return;

    // Check if either login or transaction biometrics are enabled
    final loginEnabled =
        await prefService.getBool('biometrics_login_enabled') ?? false;
    final transEnabled =
        await prefService.getBool('biometrics_transaction_enabled') ?? false;

    if (!loginEnabled && !transEnabled) {
      if (!mounted) return;
      _showInitialBiometricPrompt();
    }
  }

  void _showInitialBiometricPrompt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: isDark
              ? AppTheme.surfaceDark
              : Colors.white,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: PopScope(
          canPop: false,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              32,
              24,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  "Biometric Authentication",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Would you like to enable biometric authentication for a more secure and convenient experience?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    final authenticated = await BiometricService.authenticate(
                      title: 'Enable Biometrics',
                      reason:
                          'Please authenticate to confirm you want to enable biometric security.',
                    );

                    if (authenticated && context.mounted) {
                      Navigator.pop(context);
                      _showBiometricSetupDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                  ),
                  child: const Text(
                    "Enable Biometrics",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final prefService = ref.read(preferenceServiceProvider);
                    await prefService.setBool(
                      'biometrics_setup_prompt_shown',
                      true,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "You can also manage these settings later in your Profile.",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Skip for now",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBiometricSetupDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool enableLogin = false;
    bool enableTrans = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      // Prevent closing by tapping outside
      enableDrag: false,
      // Prevent closing by dragging
      backgroundColor: Colors.transparent,
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: isDark
              ? AppTheme.surfaceDark
              : Colors.white,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: PopScope(
          canPop: false, // Prevent closing via back button
          child: StatefulBuilder(
            builder: (context, setDialogState) => Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                32 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fingerprint_rounded,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ).animate().scale(),
                  const SizedBox(height: 16),
                  Text(
                    "Secure your wallet",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enable biometrics for a faster and more secure experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSetupToggle(
                    "App Login",
                    "Unlock wallet with biometrics",
                    enableLogin,
                    (v) => setDialogState(() => enableLogin = v),
                  ),
                  const SizedBox(height: 12),
                  _buildSetupToggle(
                    "Transactions",
                    "Authorize payments securely",
                    enableTrans,
                    (v) => setDialogState(() => enableTrans = v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You can also manage these settings later in your Profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final prefService = ref.read(
                              preferenceServiceProvider,
                            );
                            // Mark as shown so it doesn't prompt again this session
                            await prefService.setBool(
                              'biometrics_setup_prompt_shown',
                              true,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!enableLogin && !enableTrans) {
                              // If nothing selected, just treat as skip/done
                              final prefService = ref.read(
                                preferenceServiceProvider,
                              );
                              await prefService.setBool(
                                'biometrics_setup_prompt_shown',
                                true,
                              );
                              if (context.mounted) Navigator.pop(context);
                              return;
                            }

                            final prefService = ref.read(
                              preferenceServiceProvider,
                            );
                            await prefService.setBool(
                              'biometrics_login_enabled',
                              enableLogin,
                            );
                            await prefService.setBool(
                              'biometrics_transaction_enabled',
                              enableTrans,
                            );
                            await prefService.setBool(
                              'biometrics_enabled',
                              enableLogin,
                            );
                            await prefService.setBool(
                              'biometrics_setup_prompt_shown',
                              true,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              GlassDialog.showSuccess(
                                context,
                                "Biometrics setup successfully!",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusMedium,
                            ),
                          ),
                          child: const Text("Enable"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _initializeSession() async {
    final prefService = ref.read(preferenceServiceProvider);
    // Unique session ID for voucher management
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefService.setString('voucher_session_id', sessionId);
  }

  void _loadUserName() {
    final authService = AuthService();
    final user = authService.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
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
      ref.invalidate(kycStateProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kycState = ref.watch(kycStateProvider);
    final isKycVerified = kycState.valueOrNull ?? false;

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
                  isKycVerified: isKycVerified,
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
