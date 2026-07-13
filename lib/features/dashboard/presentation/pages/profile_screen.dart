import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:neruwallet/features/auth/presentation/pages/change_pin_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _biometricsAvailable = false;
  String _userName = 'User';
  String _userEmail = '';

  bool _limitEnabled = false;
  double _monthlyLimit = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkBiometrics();
    _loadSpendingLimit();
  }

  Future<void> _loadSpendingLimit() async {
    final prefService = ref.read(preferenceServiceProvider);
    final enabled = await prefService.getBool('monthly_limit_enabled') ?? false;
    final limit =
        await prefService.getString('monthly_spending_limit') ?? '0.0';

    if (mounted) {
      setState(() {
        _limitEnabled = enabled;
        _monthlyLimit = double.tryParse(limit) ?? 0.0;
      });
    }
  }

  Future<void> _checkBiometrics() async {
    final isEnrolled = await BiometricService.isEnrolled();
    if (mounted) setState(() => _biometricsAvailable = isEnrolled);
  }

  void _loadUserInfo() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
      });
    }
  }

  void _handleLogout() {
    GlassDialog.showConfirm(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDestructive: true,
      onConfirm: () async {
        final prefService = ref.read(preferenceServiceProvider);

        // Clear biometric preferences on sign out
        await prefService.remove('biometrics_login_enabled');
        await prefService.remove('biometrics_transaction_enabled');
        await prefService.remove('biometrics_enabled');
        await prefService.remove('biometrics_setup_prompt_shown');

        await _authService.signOut();
        if (mounted) context.go('/auth/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: isDark
            ? AppTheme.backgroundDark
            : const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text(
                "Profile Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              pinned: true,
              backgroundColor: isDark
                  ? AppTheme.backgroundDark
                  : const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Security Settings', isDark),
                    const SizedBox(height: 12),
                    _buildSecurityCard(isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Spending Controls', isDark),
                    const SizedBox(height: 12),
                    _buildSpendingLimitCard(isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Support & Legal', isDark),
                    const SizedBox(height: 12),
                    _buildSupportCard(isDark),
                    const SizedBox(height: 40),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingLimitCard(bool isDark) {
    final balanceState = ref.watch(balanceProvider);
    final currentSpending = balanceState.monthlyExpenses;
    final progress = _monthlyLimit > 0
        ? (currentSpending / _monthlyLimit).clamp(0.0, 1.0)
        : 0.0;
    final isExceeded =
        _limitEnabled && _monthlyLimit > 0 && currentSpending > _monthlyLimit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Spending Limit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Track and limit monthly expenses",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _limitEnabled,
                  onChanged: (val) async {
                    setState(() => _limitEnabled = val);
                    await ref
                        .read(preferenceServiceProvider)
                        .setBool('monthly_limit_enabled', val);
                    // Sync to cloud in background
                    ref.read(syncServiceProvider).performFullSync().catchError((
                      e,
                    ) {
                      debugPrint('Background sync failed: $e');
                    });
                  },
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ],
            ),
            if (_limitEnabled) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Current: Rs. ${currentSpending.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExceeded ? AppTheme.errorColor : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showLimitDialog,
                    child: Text(
                      "Limit: Rs. ${_monthlyLimit.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExceeded ? AppTheme.errorColor : AppTheme.primaryColor,
                  ),
                ),
              ),
              if (isExceeded)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.errorColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          "Monthly limit exceeded!",
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  void _showLimitDialog() {
    final controller = TextEditingController(
      text: _monthlyLimit.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Limit"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount (Rs.)",
            prefixText: "Rs. ",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newLimit = double.tryParse(controller.text) ?? 0.0;
              setState(() => _monthlyLimit = newLimit);
              await ref
                  .read(preferenceServiceProvider)
                  .setString('monthly_spending_limit', newLimit.toString());
              // Sync to cloud in background
              ref.read(syncServiceProvider).performFullSync().catchError((e) {
                debugPrint('Background sync failed: $e');
              });
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.radiusLarge,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              _userName[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSecurityCard(bool isDark) {
    return Card(
      child: Column(
        children: [
          if (_biometricsAvailable) ...[
            _buildSettingTile(
              Icons.fingerprint_rounded,
              "Biometric Security",
              "Manage logins & payments",
              () => context.push('/profile/biometric-settings'),
            ),
            _buildDivider(isDark),
          ],
          _buildSettingTile(
            Icons.lock_outline_rounded,
            "Change Password",
            "Update credentials",
            () => context.push('/profile/change-password'),
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            Icons.pin_rounded,
            "Transaction PIN",
            "Manage security PIN",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePinProfileScreen()),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSupportCard(bool isDark) {
    return Card(
      child: Column(
        children: [
          _buildSettingTile(
            Icons.help_outline_rounded,
            "Help & Support",
            "FAQs and direct contact",
            () => context.push('/profile/help-support'),
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            Icons.privacy_tip_outlined,
            "Privacy Policy",
            "How we protect your data",
            () => context.push('/profile/privacy-policy'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _handleLogout,
      icon: const Icon(Icons.logout_rounded),
      label: const Text("Sign Out"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.errorColor,
        side: const BorderSide(color: AppTheme.errorColor),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
}
