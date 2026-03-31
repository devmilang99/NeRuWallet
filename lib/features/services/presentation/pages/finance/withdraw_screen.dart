import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final List<Map<String, dynamic>> _methods = [
    {'name': 'Bank Account', 'icon': Icons.account_balance_rounded, 'color': AppTheme.primaryColor},
    {'name': 'ATM QR Cash', 'icon': Icons.qr_code_rounded, 'color': Colors.orange},
    {'name': 'Agent Network', 'icon': Icons.storefront_rounded, 'color': Colors.green},
  ];
  int _selectedMethodIndex = 0;

  void _onWithdraw() {
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
        title: 'Withdrawal',
        target: target,
        amount: amount,
        fee: 10.0, // Withdrawal often has higher fee
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

  void _executeWithdrawal(double amount, String target) {
    // Close PIN screen
    Navigator.pop(context);

    GlassDialog.showLoading(context, message: 'Processing Withdrawal...');
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      
      GlassDialog.showSuccess(
        context, 
        'Rs. ${amount.toStringAsFixed(2)} successfully withdrawn via $target.',
        onConfirm: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Withdraw Money',
      children: [
        const ServiceHeader(
          title: 'Withdraw Funds',
          subtitle: 'Transfer money from your wallet to bank or cash agent.',
          icon: Icons.file_download_outlined,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Amount to Withdraw',
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
                        color: selected ? AppTheme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
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
                          child: Icon(_methods[i]['icon'], color: _methods[i]['color']),
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
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onWithdraw,
          child: const Text('Withdraw Now'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }
}
