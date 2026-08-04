import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/transaction_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amountController = TextEditingController();
  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'Bank Account',
      'icon': Icons.account_balance_rounded,
      'color': AppTheme.primaryColor,
    },
    {
      'name': 'ATM QR Cash',
      'icon': Icons.qr_code_rounded,
      'color': Colors.orange,
    },
    {
      'name': 'Agent Network',
      'icon': Icons.storefront_rounded,
      'color': Colors.green,
    },
  ];
  int _selectedMethodIndex = 0;

  void _onWithdraw() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      GlassDialog.showError(context, 'Please enter a valid amount.');
      return;
    }

    final fee = TransactionService.getServiceCharge(
      TransactionType.withdraw,
      amount,
    );
    final tax = TransactionService.getTax(TransactionType.withdraw, amount);
    final totalPayable = amount + fee + tax;
    final currentBalance = ref.read(balanceProvider).totalBalance;

    if (totalPayable > currentBalance) {
      GlassDialog.showError(
        context,
        'Insufficient balance for withdrawal.\n\nRequired: Rs. ${totalPayable.toStringAsFixed(2)}\nAvailable: Rs. ${currentBalance.toStringAsFixed(2)}',
      );
      return;
    }

    final target = _methods[_selectedMethodIndex]['name'];

    // 1. Show Receipt Preview
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(
        title: 'Withdrawal',
        target: target,
        amount: amount,
        fee: fee,
        tax: tax,
        onConfirm: () {
          // 2. Trigger Security Validation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionPinScreen(
                mode: PinMode.verify,
                onSuccess: () => _executeWithdrawal(amount, target),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _executeWithdrawal(double amount, String target) async {
    // Deduct balance here upon successful PIN verification
    await ref
        .read(balanceProvider.notifier)
        .deductQuickAction(
          title: 'Withdrawal',
          amount: amount,
          fee: TransactionService.getServiceCharge(
            TransactionType.withdraw,
            amount,
          ),
          tax: TransactionService.getTax(TransactionType.withdraw, amount),
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.redAccent,
          category: 'Withdraw',
          type: TransactionType.withdraw,
          metadata: {'method': target},
        );

    // Close PIN screen
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (!mounted) return;
    GlassDialog.showLoading(context, message: 'Processing Withdrawal...');

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading

      TransactionReceiptSheet.showSuccess(
        context: context,
        title: 'Withdrawal',
        target: target,
        amount: amount,
        fee: TransactionService.getServiceCharge(
          TransactionType.withdraw,
          amount,
        ),
        tax: TransactionService.getTax(TransactionType.withdraw, amount),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Withdraw Money',
      children: [
        const SizedBox(height: 8),
        ServiceInputSection(
          label: 'Withdrawal Information',
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radiusMedium,
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Daily Limit: Rs. 50,000.00 | Remaining: Rs. 42,500.00',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.orange[200]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'Rs ',
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (_selectedMethodIndex == 0) ...[
          ServiceInputSection(
            label: 'Bank Account Details',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Account Number',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                    fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Bank Name',
                    prefixIcon: const Icon(Icons.account_balance_rounded),
                    fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
        ServiceInputSection(
          label: 'Select Withdrawal Method',
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
                        color: selected
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
                            color: _methods[i]['color'].withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _methods[i]['icon'],
                            color: _methods[i]['color'],
                          ),
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
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),

        ListenableBuilder(
          listenable: _amountController,
          builder: (context, _) {
            final val = _amountController.text.trim();
            if (val.isEmpty || double.tryParse(val) == 0) {
              return const SizedBox.shrink();
            }
            final amount = double.tryParse(val) ?? 0;

            return Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: AppTheme.radiusLarge,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Service Charge',
                        'Rs. ${TransactionService.getServiceCharge(TransactionType.withdraw, amount).toStringAsFixed(2)}',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Processing Fee',
                        'Rs. ${TransactionService.getTax(TransactionType.withdraw, amount).toStringAsFixed(2)}',
                        isDark,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Total Payable',
                        'Rs. ${TransactionService.getTotalPayable(TransactionType.withdraw, amount).toStringAsFixed(2)}',
                        isDark,
                        isTotal: true,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],
            );
          },
        ),

        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onWithdraw,
          child: const Text('Withdraw Now'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
  }) {
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
            color: isTotal
                ? AppTheme.primaryColor
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
