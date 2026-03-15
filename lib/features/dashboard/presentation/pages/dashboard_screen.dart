import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  bool _balanceVisible = true;
  bool _biometricsEnabled = false;
  late AnimationController _pulseController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Check for biometrics after a short delay to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptBiometrics();
    });
  }

  Future<void> _checkAndPromptBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;

    if (_biometricsEnabled) return; // Already enabled, don't show prompt

    // Determine if the device is capable of biometric auth
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    
    if (canAuthenticate) {
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      if (availableBiometrics.isNotEmpty) {
        if (mounted) {
          _showBiometricBottomSheet(availableBiometrics);
        }
      }
    }
  }

  void _showBiometricBottomSheet(List<BiometricType> biometrics) {
    final bool hasFace = biometrics.contains(BiometricType.face);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFace ? Icons.face_unlock_rounded : Icons.fingerprint_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                "Enable Biometric Login",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Use your ${hasFace ? 'Face ID' : 'fingerprint'} for faster and more secure access to your wallet next time.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final bool didAuthenticate = await _auth.authenticate(
                        localizedReason: 'Please authenticate to enable biometric login',
                        options: const AuthenticationOptions(
                          stickyAuth: true,
                          biometricOnly: true,
                        ),
                      );
                      if (didAuthenticate) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('biometrics_enabled', true);
                        
                        setState(() => _biometricsEnabled = true);
                        if (mounted) Navigator.pop(context);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Biometric login enabled successfully!"),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusLarge,
                    ),
                  ),
                  child: const Text("Enroll Now", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Maybe Later",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  final List<_Transaction> _transactions = [
    _Transaction(
      'Merchant Payment',
      'Pizza Palace',
      -1250.00,
      Icons.restaurant_rounded,
      Color(0xffFF6B6B),
      '10:32 AM',
    ),
    _Transaction(
      'Money Received',
      'Rajan Sharma',
      5000.00,
      Icons.arrow_downward_rounded,
      Color(0xFF10B981),
      'Yesterday',
    ),
    _Transaction(
      'Utility Bill',
      'NEA Electricity',
      -850.00,
      Icons.bolt_rounded,
      Color(0xFFF59E0B),
      'Feb 28',
    ),
    _Transaction(
      'QR Transfer',
      'Suraj Tamang',
      -2000.00,
      Icons.qr_code_rounded,
      Color(0xFF6366F1),
      'Feb 27',
    ),
    _Transaction(
      'Top-up ',
      'eSewa Wallet',
      10000.00,
      Icons.account_balance_wallet_rounded,
      Color(0xFF10B981),
      'Feb 26',
    ),
    _Transaction(
      'Mobile Recharge',
      'Ncell Postpaid',
      -500.00,
      Icons.phone_android_rounded,
      Color(0xFF8B5CF6),
      'Feb 25',
    ),
    _Transaction(
      'Internet Bill',
      'WorldLink ISP',
      -999.00,
      Icons.wifi_rounded,
      Color(0xFF0EA5E9),
      'Feb 24',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF1F5F9),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildHomeTab(isDark),
          _buildPayTab(isDark),
          _buildHistoryTab(isDark),
          _buildProfileTab(isDark), // Kept as hidden tab 3
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // ─────────────── HOME TAB ───────────────
  Widget _buildHomeTab(bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(isDark)),
        SliverToBoxAdapter(child: _buildBalanceCard(isDark)),
        SliverToBoxAdapter(child: _buildQuickActions(isDark)),
        SliverToBoxAdapter(child: _buildPromoCard(isDark)),
        SliverToBoxAdapter(
          child: _buildSectionHeader('Recent Transactions', isDark),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _buildTransactionTile(_transactions[i], isDark, i),
            childCount: _transactions.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Raju Ghimire',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          Row(
            children: [
              _buildIconButton(isDark, Icons.notifications_outlined, () {}),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 3),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryColor.withValues(
                    alpha: 0.15,
                  ),
                  child: const Text(
                    'RG',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildIconButton(bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppTheme.textBodyDark : AppTheme.textBodyColor,
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child:
          Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFF4F46E5),
                    ],
                  ),
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // decorative circles
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      right: 60,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                () => _balanceVisible = !_balanceVisible,
                              ),
                              child: Icon(
                                _balanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _balanceVisible
                              ? Text(
                                  'NPR 47,250.00',
                                  key: const ValueKey('visible'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                )
                              : const Text(
                                  'NPR ••••••••',
                                  key: ValueKey('hidden'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFF34D399),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '+12.5% this month',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCardStat(
                              'Income',
                              'NPR 55,000',
                              Icons.arrow_downward_rounded,
                              const Color(0xFF34D399),
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _buildCardStat(
                              'Expense',
                              'NPR 7,750',
                              Icons.arrow_upward_rounded,
                              const Color(0xFFFC8181),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }

  Widget _buildCardStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      _QuickAction('Send', Icons.arrow_upward_rounded, const Color(0xFF6366F1)),
      _QuickAction(
        'Receive',
        Icons.arrow_downward_rounded,
        const Color(0xFF10B981),
      ),
      _QuickAction(
        'Scan QR',
        Icons.qr_code_scanner_rounded,
        const Color(0xFFF59E0B),
      ),
      _QuickAction(
        'Top Up',
        Icons.account_balance_wallet_rounded,
        const Color(0xFF8B5CF6),
      ),
      _QuickAction(
        'Pay Bill',
        Icons.receipt_long_rounded,
        const Color(0xFFEC4899),
      ),
      _QuickAction('Pay Bill', Icons.receipt_long_rounded, const Color(0xFFEC4899)),
      _QuickAction('Exchange', Icons.currency_exchange_rounded, const Color(0xFF0EA5E9)),
      _QuickAction('History', Icons.history_rounded, const Color(0xFF6366F1)),
      _QuickAction(
        'More',
        Icons.grid_view_rounded,
        AppTheme.textSecondaryColor,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: actions.length,
              itemBuilder: (ctx, i) =>
                  _buildQuickActionItem(actions[i], i, isDark),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildQuickActionItem(_QuickAction action, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (action.label == 'Exchange') {
          context.push('/exchange-rates');
        }
      },
      child:
          Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
              .animate(delay: (50 * index).ms)
              .fadeIn()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              ),
    );
  }

  Widget _buildPromoCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppTheme.radiusLarge,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✨ LIMITED OFFER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Zero fees on all\ntransfers this week!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Text(
                        'Claim Now',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.celebration_rounded,
              size: 80,
              color: Colors.white24,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See All',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_Transaction tx, bool isDark, int index) {
    final isCredit = tx.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tx.color.withValues(alpha: 0.12),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(tx.icon, color: tx.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tx.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : ''}NPR ${tx.amount.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isCredit
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tx.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.textHintDark
                        : AppTheme.textHintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: (60 * index).ms).fadeIn().slideX(begin: 0.05, end: 0),
    );
  }

  // ─────────────── PAY TAB ───────────────
  Widget _buildPayTab(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 64, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pay & Transfer',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSearchBar(isDark),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),
          _buildSectionHeader('Recent Contacts', isDark),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildContactAvatar('+', null, 'Add'),
                _buildContactAvatar('RS', const Color(0xFF6366F1), 'Rajan'),
                _buildContactAvatar('ST', const Color(0xFF10B981), 'Suraj'),
                _buildContactAvatar('PK', const Color(0xFFF59E0B), 'Pratik'),
                _buildContactAvatar('AK', const Color(0xFFEC4899), 'Anisha'),
                _buildContactAvatar('BS', const Color(0xFF0EA5E9), 'Bishal'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Payment Methods', isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildPaymentMethod(
                  isDark,
                  Icons.account_balance_rounded,
                  'Bank Transfer',
                  'NABIL Bank • ••••4512',
                  const Color(0xFF6366F1),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethod(
                  isDark,
                  Icons.qr_code_rounded,
                  'Scan QR Code',
                  'Merchant & P2P Payments',
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethod(
                  isDark,
                  Icons.nfc_rounded,
                  'NFC Tap Pay',
                  'Contactless Payments',
                  const Color(0xFF10B981),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search name or number...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.primaryColor,
          ),
          border: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildContactAvatar(String initials, Color? color, String label) {
    final isAdd = initials == '+';
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child:
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAdd ? null : color?.withValues(alpha: 0.15),
                  border: isAdd
                      ? Border.all(
                          color: AppTheme.textHintColor.withValues(alpha: 0.4),
                          width: 1.5,
                          style: BorderStyle.solid,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: isAdd ? AppTheme.textHintColor : color,
                      fontWeight: FontWeight.bold,
                      fontSize: isAdd ? 22 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).animate().fadeIn().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
          ),
    );
  }

  Widget _buildPaymentMethod(
    bool isDark,
    IconData icon,
    String title,
    String sub,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.radiusMedium,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
          ),
        ],
      ),
    );
  }

  // ─────────────── HISTORY TAB ───────────────
  Widget _buildHistoryTab(bool isDark) {
    final months = ['All', 'Mar', 'Feb', 'Jan'];
    return Column(
      children: [
        SizedBox(height: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: months.length,
            separatorBuilder: (context, idx) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final isActive = i == 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : (isDark ? AppTheme.surfaceDark : Colors.white),
                  borderRadius: AppTheme.radiusFull,
                ),
                child: Text(
                  months[i],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark
                              ? AppTheme.textBodyDark
                              : AppTheme.textBodyColor),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _transactions.length,
            itemBuilder: (ctx, i) =>
                _buildTransactionTile(_transactions[i], isDark, i),
          ),
        ),
      ],
    );
  }

  // ─────────────── PROFILE TAB ───────────────
  Widget _buildProfileTab(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 64, bottom: 100),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppTheme.radiusLarge,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Text(
                    'RG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raju Ghimire',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'raju@neruwallet.com',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KYC Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.account_circle_outlined,
            'Edit Profile',
            'Update your info',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.security_rounded,
            'Security',
            'PIN, biometrics & 2FA',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.lock_reset_rounded,
            'Change Password',
            'Update your login password',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.pin_rounded,
            'Change Transaction PIN',
            'Secure your transactions',
          ),
          _buildBiometricToggle(isDark),
          _buildProfileMenuItem(
            isDark,
            Icons.no_encryption_gmailerrorred_rounded,
            'Remove Biometrics',
            'Delete saved biometric data',
            color: AppTheme.errorColor,
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.help_outline_rounded,
            'Help & Support',
            'FAQ, live chat',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Read our policies',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppTheme.errorColor),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    bool isDark,
    IconData icon,
    String title,
    String sub, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color ?? AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── BOTTOM NAV ───────────────
  Widget _buildBottomNav(bool isDark) {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      _NavItem(Icons.send_rounded, Icons.send_outlined, 'Pay'),
      _NavItem(
        Icons.receipt_long_rounded,
        Icons.receipt_long_outlined,
        'History',
      ),
    ];

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
            items.length,
            (i) => _buildNavItem(items[i], i, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Login',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Use fingerprint or face ID',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _biometricsEnabled,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() => _biometricsEnabled = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int i, bool isDark) {
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

// ─────────────── DATA MODELS ───────────────
class _Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;
  final String time;
  _Transaction(
    this.title,
    this.subtitle,
    this.amount,
    this.icon,
    this.color,
    this.time,
  );
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  _QuickAction(this.label, this.icon, this.color);
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}
