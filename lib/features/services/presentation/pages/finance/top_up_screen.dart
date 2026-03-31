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
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: 'Rs ',
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Select Payment Method',
          child: Column(
            children: List.generate(_methods.length, (i) {
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
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onTopUp,
          child: const Text('Top Up Now'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }
}
