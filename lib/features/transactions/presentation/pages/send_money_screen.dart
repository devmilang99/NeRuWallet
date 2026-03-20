import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';
import 'package:neruwallet/features/transactions/presentation/providers/transaction_provider.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _receiverController = TextEditingController();

  final List<Map<String, String>> _recentPeople = [
    {'name': 'Arun Sharma', 'id': '9841234567', 'init': 'AS'},
    {'name': 'Sita Rai', 'id': '9808765432', 'init': 'SR'},
    {'name': 'Kabin Tamang', 'id': '9812345678', 'init': 'KT'},
    {'name': 'Priya Jha', 'id': 'priya.jha@gmail.com', 'init': 'PJ'},
  ];

  String _amountInWords = "";

  void _updateAmountInWords(String value) {
    if (value.isEmpty) {
      setState(() {
        _amountInWords = "";
      });
      return;
    }
    final amount = double.tryParse(value) ?? 0;
    setState(() {
      _amountInWords = _convertToWords(amount);
    });
  }

  String _convertToWords(double amount) {
    if (amount <= 0) return "";
    // Simplified version for demo
    int intAmount = amount.toInt();
    if (intAmount == 0) return "Zero Rupees";

    final units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen",
    ];
    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety",
    ];

    String res = "";
    if (intAmount >= 1000) {
      res += "${units[intAmount ~/ 1000]} Thousand ";
      intAmount %= 1000;
    }
    if (intAmount >= 100) {
      res += "${units[intAmount ~/ 100]} Hundred ";
      intAmount %= 100;
    }
    if (intAmount >= 20) {
      res += "${tens[intAmount ~/ 10]} ";
      intAmount %= 10;
    }
    if (intAmount > 0) {
      res += units[intAmount];
    }

    return "$res Rupees Only";
  }

  void _onSend() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0 || _receiverController.text.isEmpty) {
      GlassDialog.showError(
        context,
        'Please enter a valid amount and recipient identifier.',
      );
      return;
    }

    _showConfirmationBottomSheet(amount, _receiverController.text);
  }

  void _showConfirmationBottomSheet(double amount, String recipient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirm Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // Receipt Canvas
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rs. ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Divider(height: 40),
                  _buildReceiptRow('Recipient', recipient),
                  const SizedBox(height: 12),
                  _buildReceiptRow('Date & Time', '22 Mar 2026, 17:45'),
                  const SizedBox(height: 12),
                  _buildReceiptRow('Transaction Type', 'Mobile Transfer'),
                  const SizedBox(height: 12),
                  _buildReceiptRow('In Words', _amountInWords),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPinVerification(amount, recipient);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
              ),
              child: const Text('Confirm & Pay'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPinVerification(double amount, String recipient) {
    context.push('/auth/pin-setup', extra: PinMode.verify).then((result) {
      if (result == true) {
        _processFinalTransaction(amount, recipient);
      }
    });
  }

  Future<void> _processFinalTransaction(double amount, String recipient) async {
    GlassDialog.showLoading(context, message: 'Transferring Funds...');

    await ref
        .read(transactionProvider.notifier)
        .processTransaction(
          type: 'Transfer',
          amount: amount,
          target: recipient,
        );

    if (!mounted) return;

    // Remove loading dialog
    Navigator.pop(context);

    final state = ref.read(transactionProvider);

    if (state.isSuccess) {
      GlassDialog.showSuccess(
        context,
        'Rs. ${amount.toStringAsFixed(2)} has been successfully transferred to $recipient.',
        onConfirm: () => Navigator.pop(context),
      );
    } else if (state.error != null) {
      GlassDialog.showError(context, state.error!);
    }
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Send Money',
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
            const Text(
              'Recent Recipients',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentPeople.length,
                itemBuilder: (context, index) {
                  final person = _recentPeople[index];
                  return GestureDetector(
                    onTap: () {
                      _receiverController.text = person['id']!;
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              person['init']!,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            person['name']!.split(' ')[0],
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
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
                      _buildTextField(
                        controller: _receiverController,
                        label: 'Phone Number',
                        hint: '+977 XXXXXXXXX',
                        icon: Icons.phone,
                        isNumber: true,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount to Send',
                        hint: '0.00',
                        icon: Icons.currency_rupee_rounded,
                        isNumber: true,
                        autoFocus: true,
                        onChanged: _updateAmountInWords,
                      ),
                      if (_amountInWords.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _amountInWords,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Transfer Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool autoFocus = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: onChanged,
          autofocus: autoFocus,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
