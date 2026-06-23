import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

class PromoCard extends ConsumerStatefulWidget {
  final bool isDark;

  const PromoCard({super.key, required this.isDark});

  @override
  ConsumerState<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends ConsumerState<PromoCard> {
  bool _isClaimed = false;

  @override
  void initState() {
    super.initState();
    _checkClaimStatus();
  }

  Future<void> _checkClaimStatus() async {
    final prefService = ref.read(preferenceServiceProvider);
    final isClaimed = await prefService.getBool('voucher_active') ?? false;
    setState(() {
      _isClaimed = isClaimed;
    });
  }

  Future<void> _handleClaim() async {
    if (_isClaimed) return;

    final prefService = ref.read(preferenceServiceProvider);
    await prefService.setBool('voucher_active', true);
    await prefService.setInt('voucher_limit', 3);

    // Success Dialog
    if (mounted) {
      GlassDialog.showSuccess(
        context,
        'Voucher Active! Your next 3 transactions are free of service charges.',
        onConfirm: () => setState(() => _isClaimed = true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isClaimed) return const SizedBox.shrink();

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
                  Text(
                    _isClaimed
                        ? 'Enjoy your free\ntransfers today!'
                        : 'Zero fees on all\ntransfers this week!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _handleClaim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isClaimed
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: Text(
                        _isClaimed ? 'Claimed' : 'Claim Now',
                        style: TextStyle(
                          color: _isClaimed
                              ? Colors.white
                              : const Color(0xFF10B981),
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
}
