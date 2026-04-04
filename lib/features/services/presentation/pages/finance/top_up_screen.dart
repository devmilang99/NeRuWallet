import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/transaction_service.dart';
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

  final int _selectedMethodIndex = 0;
  Map<String, String>? _selectedSavedSource;

  final List<Map<String, String>> _savedPaymentMethods = [
    {
      'type': 'Bank Connect',
      'display': 'HBL **** 8821',
      'accountNumber': '1234567890',
    },
    {
      'type': 'Debit/Credit Card',
      'display': 'VISA **** 4490',
      'cardNumber': '1234567890124490',
    },
  ];

  void _showBankConnectDialog({Map<String, String>? savedMethod}) {
    final bankController = TextEditingController(
      text: savedMethod?['bankName'] ?? '',
    );
    final branchController = TextEditingController(
      text: savedMethod?['branch'] ?? '',
    );
    final accountController = TextEditingController(
      text: savedMethod?['accountNumber'] ?? '',
    );
    final holderController = TextEditingController(
      text: savedMethod?['holder'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  savedMethod != null
                      ? 'View Bank Account'
                      : 'Add Bank Account',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bankController,
                      enabled: savedMethod == null,
                      decoration: InputDecoration(
                        labelText: 'Bank Name',
                        hintText: 'e.g., Nepal Bank Limited',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: branchController,
                      enabled: savedMethod == null,
                      decoration: InputDecoration(
                        labelText: 'Branch Name',
                        hintText: 'e.g., Kathmandu Main',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: accountController,
                      enabled: savedMethod == null,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Account Number',
                        hintText: 'e.g., 1234567890',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: holderController,
                      enabled: savedMethod == null,
                      decoration: InputDecoration(
                        labelText: 'Account Holder Name',
                        hintText: 'Your Name',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (savedMethod == null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final bank = bankController.text.trim();
                            final branch = branchController.text.trim();
                            final account = accountController.text.trim();
                            final holder = holderController.text.trim();

                            if (bank.isNotEmpty &&
                                account.isNotEmpty &&
                                holder.isNotEmpty) {
                              setState(() {
                                _savedPaymentMethods.add({
                                  'type': 'Bank Connect',
                                  'display':
                                      '$bank **** ${account.substring(account.length - 4)}',
                                  'accountNumber': account,
                                  'bankName': bank,
                                  'branch': branch,
                                  'holder': holder,
                                });
                              });
                              Navigator.pop(context);
                              GlassDialog.showSuccess(
                                context,
                                'Bank account saved successfully!',
                              );
                            } else {
                              GlassDialog.showError(
                                context,
                                'Please fill all required fields',
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    if (savedMethod != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardDialog({Map<String, String>? savedMethod}) {
    final cardController = TextEditingController(
      text: savedMethod?['cardNumber'] ?? '',
    );
    final holderController = TextEditingController(
      text: savedMethod?['holder'] ?? '',
    );
    final expiryController = TextEditingController(
      text: savedMethod?['expiry'] ?? '',
    );
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  savedMethod != null
                      ? 'View Debit/Credit Card'
                      : 'Add Debit/Credit Card',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cardController,
                      enabled: savedMethod == null,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: '1234567890123456',
                        border: const OutlineInputBorder(),
                        counterText: '',
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: holderController,
                      enabled: savedMethod == null,
                      decoration: InputDecoration(
                        labelText: 'Cardholder Name',
                        hintText: 'Your Name',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            enabled: savedMethod == null,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: InputDecoration(
                              labelText: 'Expiry (MM/YY)',
                              hintText: '12/25',
                              border: const OutlineInputBorder(),
                              counterText: '',
                              suffixIcon: savedMethod != null
                                  ? const Icon(Icons.lock, size: 18)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            enabled: savedMethod == null,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: const OutlineInputBorder(),
                              counterText: '',
                              suffixIcon: savedMethod != null
                                  ? const Icon(Icons.lock, size: 18)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (savedMethod == null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final card = cardController.text.trim();
                            final holder = holderController.text.trim();
                            final expiry = expiryController.text.trim();
                            final cvv = cvvController.text.trim();

                            if (card.length == 16 &&
                                holder.isNotEmpty &&
                                expiry.isNotEmpty &&
                                cvv.length == 3) {
                              final cardType = int.parse(card[0]) == 4
                                  ? 'VISA'
                                  : 'MASTERCARD';
                              setState(() {
                                _savedPaymentMethods.add({
                                  'type': 'Debit/Credit Card',
                                  'display':
                                      '$cardType **** ${card.substring(card.length - 4)}',
                                  'cardNumber': card,
                                  'holder': holder,
                                  'expiry': expiry,
                                });
                              });
                              Navigator.pop(context);
                              GlassDialog.showSuccess(
                                context,
                                'Card saved successfully!',
                              );
                            } else {
                              GlassDialog.showError(
                                context,
                                'Please fill all fields correctly',
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    if (savedMethod != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEsewaDialog({Map<String, String>? savedMethod}) {
    final emailController = TextEditingController(
      text: savedMethod?['email'] ?? '',
    );
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  savedMethod != null
                      ? 'View eSewa Wallet'
                      : 'Add eSewa Wallet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      enabled: savedMethod == null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'eSewa Email/Phone',
                        hintText: 'your@email.com or 98XXXXXXXX',
                        border: const OutlineInputBorder(),
                        suffixIcon: savedMethod != null
                            ? const Icon(Icons.lock, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      enabled: savedMethod == null,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'eSewa PIN',
                        hintText: 'Your eSewa PIN',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Your eSewa PIN will be securely stored for authentication only.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (savedMethod == null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final email = emailController.text.trim();
                            final pin = passwordController.text.trim();

                            if (email.isNotEmpty && pin.isNotEmpty) {
                              setState(() {
                                _savedPaymentMethods.add({
                                  'type': 'eSewa Wallet',
                                  'display': email,
                                  'email': email,
                                });
                              });
                              Navigator.pop(context);
                              GlassDialog.showSuccess(
                                context,
                                'eSewa wallet linked successfully!',
                              );
                            } else {
                              GlassDialog.showError(
                                context,
                                'Please fill all fields',
                              );
                            }
                          },
                          child: const Text('Link'),
                        ),
                      ),
                    if (savedMethod != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(int index) {
    final methodName = _methods[index]['name'];
    if (methodName == 'Bank Connect') {
      _showBankConnectDialog();
    } else if (methodName == 'Debit/Credit Card') {
      _showCardDialog();
    } else if (methodName == 'eSewa Wallet') {
      _showEsewaDialog();
    }
  }

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
        fee: TransactionService.getServiceCharge(TransactionType.topUp, amount),
        tax: TransactionService.getTax(TransactionType.topUp, amount),
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
    // Add funds here upon successful PIN verification
    ref.read(balanceProvider.notifier).addFunds(amount, target);

    // Close the PIN screen first
    Navigator.pop(context);

    GlassDialog.showLoading(context, message: 'Processing Top Up...');

    await ref
        .read(transactionProvider.notifier)
        .processTransaction(type: 'Top Up', amount: amount, target: target);

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
          label: 'Saved Sources',
          child: _savedPaymentMethods.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _savedPaymentMethods.map((method) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildSavedSource(
                          method['display'] ?? '',
                          method['type'] == 'Bank Connect'
                              ? Icons.account_balance_rounded
                              : method['type'] == 'Debit/Credit Card'
                              ? Icons.payment_rounded
                              : Icons.account_balance_wallet_rounded,
                          isDark,
                          method,
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: const Text(
                    'No saved payment methods. Add one below.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Add Payment Method',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_methods.length, (i) {
              return InkWell(
                onTap: () => _showPaymentMethodDialog(i),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        _methods[i]['icon'],
                        color: AppTheme.primaryColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _methods[i]['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),
        if (_selectedSavedSource != null)
          ServiceInputSection(
            label: 'Selected Payment Method',
            child: _buildSelectedSourceDetailsFields(isDark),
          ),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Amount to Deposit',
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['500', '1000', '2000', '5000'].map((amt) {
                  return InkWell(
                    onTap: () => setState(() => _amountController.text = amt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
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
                      _buildInfoRow('Service Charge', 'Rs. ${TransactionService.getServiceCharge(TransactionType.topUp, amount).toStringAsFixed(2)}', isDark),
                      const SizedBox(height: 8),
                      _buildInfoRow('Service Tax', 'Rs. ${TransactionService.getTax(TransactionType.topUp, amount).toStringAsFixed(2)}', isDark),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Total Payable',
                        'Rs. ${TransactionService.getTotalPayable(TransactionType.topUp, amount).toStringAsFixed(2)}',
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
          onPressed: _onTopUp,
          child: const Text('Top Up Now'),
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

  Widget _buildSelectedSourceDetailsFields(bool isDark) {
    if (_selectedSavedSource == null) {
      return const SizedBox.shrink();
    }

    final method = _selectedSavedSource!;

    if (method['type'] == 'Bank Connect') {
      return Column(
        children: [
          TextField(
            controller: TextEditingController(text: method['bankName'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Bank Name',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: method['branch'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Branch Name',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(
              text: method['accountNumber'] ?? '',
            ),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Account Number',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: method['holder'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    } else if (method['type'] == 'Debit/Credit Card') {
      return Column(
        children: [
          TextField(
            controller: TextEditingController(text: method['cardNumber'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: method['holder'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text: method['expiry'] ?? '',
                  ),
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Expiry',
                    border: const OutlineInputBorder(),
                    disabledBorder: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.lock, size: 18),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (method['type'] == 'eSewa Wallet') {
      return Column(
        children: [
          TextField(
            controller: TextEditingController(text: method['email'] ?? ''),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'eSewa Email/Phone',
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock, size: 18),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSavedSource(
    String label,
    IconData icon,
    bool isDark,
    Map<String, String> method,
  ) {
    final isSelected = _selectedSavedSource == method;

    return InkWell(
      onTap: () {
        setState(() => _selectedSavedSource = method);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
