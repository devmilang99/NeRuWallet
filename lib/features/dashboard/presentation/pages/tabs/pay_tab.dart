import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class PayTab extends StatelessWidget {
  final bool isDark;

  const PayTab({required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          stretch: true,
          backgroundColor: isDark
              ? AppTheme.backgroundDark
              : const Color(0xFFF1F5F9),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.blurBackground,
              StretchMode.zoomBackground,
            ],
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Pay & Transfer',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBar(isDark),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Recent Contacts', isDark),
              SizedBox(
                height: 104,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildContactAvatar('+', null, 'Add'),
                    _buildContactAvatar('RS', const Color(0xFF6366F1), 'Rajan'),
                    _buildContactAvatar('ST', const Color(0xFF10B981), 'Suraj'),
                    _buildContactAvatar(
                      'PK',
                      const Color(0xFFF59E0B),
                      'Pratik',
                    ),
                    _buildContactAvatar(
                      'AK',
                      const Color(0xFFEC4899),
                      'Anisha',
                    ),
                    _buildContactAvatar(
                      'BS',
                      const Color(0xFF0EA5E9),
                      'Bishal',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Payment Methods', isDark),
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
              SizedBox(height: 110 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search name or number...',
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
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
                  color: isAdd ? null : color?.withOpacity(0.15),
                  border: isAdd
                      ? Border.all(
                          color: AppTheme.textHintColor.withOpacity(0.4),
                          width: 1.5,
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
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
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
}
