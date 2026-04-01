import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';

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
      GlassDialog.showError(context, 'Please enter a valid amount.');
      return;
    }

    final target = _methods[_selectedMethodIndex]['name'];

    // 1. Show Receipt Preview
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(
        title: 'Wallet Top Up',
        target: target,
        amount: amount,
        fee: 0, // Top up is usually free
        onConfirm: () {
          // 2. Trigger Security Validation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionPinScreen(
                mode: PinMode.verify,
                onSuccess: () => _executeTransaction(amount, target),
              ),
            ),
          );
        },
      ),
    );
  }

  void _executeTransaction(double amount, String target) async {
    // Close the PIN screen first
    Navigator.pop(context);
    
    GlassDialog.showLoading(context, message: 'Processing Top Up...');

    await ref.read(transactionProvider.notifier).processTransaction(
      type: 'Top Up',
      amount: amount,
      target: target,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    final state = ref.read(transactionProvider);

    if (state.isSuccess) {
      GlassDialog.showSuccess(
        context,
        'Successfully topped up Rs. ${amount.toStringAsFixed(2)}.',
        onConfirm: () => Navigator.pop(context),
      );
    } else if (state.error != null) {
      GlassDialog.showError(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Top Up Wallet',
      children: [
        const ServiceHeader(
          title: 'Add Funds',
          subtitle: 'Instantly add money to your wallet from various sources.',
          icon: Icons.account_balance_wallet_rounded,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Amount to Deposit',
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'Rs ',
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['500', '1000', '2000', '5000'].map((amt) {
                  return InkWell(
                    onTap: () => setState(() => _amountController.text = amt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Rs $amt',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Saved Sources',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSavedSource('HBL **** 8821', Icons.account_balance_rounded, isDark),
                const SizedBox(width: 12),
                _buildSavedSource('VISA **** 4490', Icons.payment_rounded, isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Select Other Payment Method',
          child: Column(
            children: List.generate(_methods.length, (i) {
// ... rest of methods
              final selected = _selectedMethodIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedMethodIndex = i),
                  borderRadius: AppTheme.radiusMedium,
                  child: AnimatedContainer(
                    duration: 300.ms,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: AppTheme.radiusMedium,
                      border: Border.all(
                        color: selected ? AppTheme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_methods[i]['icon'], color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _methods[i]['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected ? AppTheme.primaryColor : null,
                          ),
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.1, end: 0),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),
        
        ListenableBuilder(
          listenable: _amountController,
          builder: (context, _) {
            final val = _amountController.text.trim();
            if (val.isEmpty || double.tryParse(val) == 0) return const SizedBox.shrink();
            final amount = double.tryParse(val) ?? 0;
            
            return Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: AppTheme.radiusLarge,
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Service Tax', 'Rs. 0.00', isDark),
                      const Divider(height: 24),
                      _buildInfoRow('Total Payable', 'Rs. ${(amount).toStringAsFixed(2)}', isDark, isTotal: true),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],
            );
          },
        ),

        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onTopUp,
          child: const Text('Top Up Now'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppTheme.primaryColor : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedSource(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
