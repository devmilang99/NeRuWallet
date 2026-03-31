import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';

class BillPaymentScreen extends StatefulWidget {
  final String billType;
  final IconData icon;
  final Color color;
  final String label;

  const BillPaymentScreen({
    super.key,
    required this.billType,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _customerIdController = TextEditingController();
  final _amountController = TextEditingController();

  void _onPay() {
    final customerId = _customerIdController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;

    if (customerId.isEmpty) {
      GlassDialog.showError(context, 'Please enter your ${widget.label} ID.');
      return;
    }
    if (amount <= 0) {
      GlassDialog.showError(context, 'Please enter a valid amount.');
      return;
    }

    // 1. Show Receipt Preview
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(
        title: '${widget.billType} Payment',
        target: customerId,
        amount: amount,
        fee: 5.0, // Bill payment fixed fee
        onConfirm: () {
          // 2. Trigger Security Validation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionPinScreen(
                mode: PinMode.verify,
                onSuccess: () => _executePayment(amount, customerId),
              ),
            ),
          );
        },
      ),
    );
  }

  void _executePayment(double amount, String customerId) {
    // Close PIN screen
    Navigator.pop(context);

    GlassDialog.showLoading(context, message: 'Processing Bill Payment...');
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      
      GlassDialog.showSuccess(
        context, 
        '${widget.billType} bill of Rs. ${amount.toStringAsFixed(2)} for ID $customerId successfully paid!',
        onConfirm: () => Navigator.pop(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: '${widget.billType} Payment',
      children: [
        ServiceHeader(
          title: widget.billType,
          subtitle: 'Securely pay your ${widget.billType.toLowerCase()} bills anywhere, anytime.',
          icon: widget.icon,
          color: widget.color,
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: '${widget.label} ID / Consumer Number',
          child: TextField(
            controller: _customerIdController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter your ID',
              prefixIcon: const Icon(Icons.person_rounded),
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ServiceInputSection(
          label: 'Amount to Pay',
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: 'Rs ',
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.05),
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildInfoRow('Service Tax', 'Rs. 0.00'),
              const Divider(height: 24),
              _buildInfoRow('Total Payable', 'Rs. ${_amountController.text.isEmpty ? '0.00' : _amountController.text}', isTotal: true),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onPay,
          style: ElevatedButton.styleFrom(backgroundColor: widget.color),
          child: Text('Pay ${widget.billType} Bill'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? widget.color : null,
          ),
        ),
      ],
    );
  }
}
