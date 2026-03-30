import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_dialog.dart';
import '../providers/transaction_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _amountController = TextEditingController();
  final List<Map<String, dynamic>> _methods = [
    {'name': 'Bank Connect', 'icon': Icons.account_balance_rounded},
    {'name': 'Debit/Credit Card', 'icon': Icons.payment_rounded},
    {'name': 'eSewa Wallet', 'icon': Icons.account_balance_wallet_rounded},
  ];

  int _selectedMethodIndex = 0;

  void _onTopUp() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      GlassDialog.showError(context, 'Please enter a valid amount to top up.');
      return;
    }

    GlassDialog.showLoading(context, message: 'Processing Payment...');

    await ref.read(transactionProvider.notifier).processTransaction(
      type: 'Top Up',
      amount: amount,
      target: _methods[_selectedMethodIndex]['name'],
    );

    if (!mounted) return;

    // Remove loading dialog
    Navigator.pop(context);

    final state = ref.read(transactionProvider);

    if (state.isSuccess) {
      GlassDialog.showSuccess(
        context,
        'Successfully topped up Rs. ${amount.toStringAsFixed(2)} using ${_methods[_selectedMethodIndex]['name']}.',
        onConfirm: () => Navigator.pop(context),
      );
    } else if (state.error != null) {
      GlassDialog.showError(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Top Up Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Amount to Deposit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: 'Rs ',
                          prefixStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.95, 0.95),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            const SizedBox(height: 32),
            const Text(
              'Favorite Contacts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFavoriteItem('Add', Icons.add_rounded, AppTheme.primaryColor),
                  _buildFavoriteItem('Rajan', Icons.person_rounded, const Color(0xFF6366F1)),
                  _buildFavoriteItem('Suraj', Icons.person_rounded, const Color(0xFF10B981)),
                  _buildFavoriteItem('Pratik', Icons.person_rounded, const Color(0xFFF59E0B)),
                  _buildFavoriteItem('Anisha', Icons.person_rounded, const Color(0xFFEC4899)),
                ],
              ),
            ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            const Text(
              'Select Top Up Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 16),
            ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _methods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final selected = _selectedMethodIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethodIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                selected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (selected)
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (selected
                                        ? AppTheme.primaryColor
                                        : Colors.grey)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _methods[i]['icon'],
                                color:
                                    selected ? AppTheme.primaryColor : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _methods[i]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: selected ? AppTheme.primaryColor : null,
                              ),
                            ),
                            const Spacer(),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                .animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Top Up Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(String name, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
