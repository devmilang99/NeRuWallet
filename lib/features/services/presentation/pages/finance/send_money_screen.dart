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
import 'package:flutter_contacts/flutter_contacts.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedPurpose = 'Family Expenses';
  final List<String> _purposes = [
    'Family Expenses',
    'Utility Payment',
    'Gift',
    'Repayment',
    'Rent',
    'Other',
  ];

  Future<void> _pickContact() async {
    try {
      // Request permission first
      bool? granted = await FlutterContacts.requestPermission();

      if (granted == true) {
        try {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null && contact.phones.isNotEmpty) {
            _setPhone(contact.phones.first.number);
            return;
          }
        } catch (e) {
          // External picker failed, continue to internal picker
        }

        // Fallback to internal picker
        await _showInternalContactPicker();
      } else {
        if (!mounted) return;
        GlassDialog.showError(
          context,
          'Contact permission is required to pick a number.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      GlassDialog.showError(
        context,
        'Error accessing contacts: ${e.toString()}',
      );
    }
  }

  void _setPhone(String number) {
    String num = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (num.startsWith('977')) num = num.substring(3);
    if (num.length > 10) num = num.substring(num.length - 10);
    setState(() => _phoneController.text = num);
  }

  Future<void> _showInternalContactPicker() async {
    GlassDialog.showLoading(context, message: 'Loading Contacts...');
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Contact',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, i) {
                  final c = contacts[i];
                  if (c.phones.isEmpty) return const SizedBox.shrink();
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.displayName[0])),
                    title: Text(c.displayName),
                    subtitle: Text(c.phones.first.number),
                    onTap: () {
                      _setPhone(c.phones.first.number);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSendMoney() {
    final phone = _phoneController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (phone.length < 10) {
      GlassDialog.showError(
        context,
        'Please enter a valid 10-digit phone number.',
      );
      return;
    }

    if (amount <= 0) {
      GlassDialog.showError(context, 'Please enter a valid amount.');
      return;
    }

    final double totalPayable = amount;
    final double currentBalance = ref.read(balanceProvider).totalBalance;

    if (totalPayable > currentBalance) {
      GlassDialog.showError(
        context,
        'Insufficient balance for transfer.\n\nRequired: Rs. ${totalPayable.toStringAsFixed(2)}\nAvailable: Rs. ${currentBalance.toStringAsFixed(2)}',
      );
      return;
    }

    // 1. Show Receipt Preview
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(
        title: 'Send Money',
        target: 'To: $phone',
        amount: amount,
        fee: TransactionService.getServiceCharge(
          TransactionType.sendMoney,
          amount,
        ),
        tax: TransactionService.getTax(TransactionType.sendMoney, amount),
        metadata: {
          'Purpose': _selectedPurpose,
          if (_messageController.text.isNotEmpty)
            'Message': _messageController.text,
        },
        onConfirm: () {
          // 2. Trigger Security Validation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionPinScreen(
                mode: PinMode.verify,
                onSuccess: () => _executeTransaction(amount, phone),
              ),
            ),
          );
        },
      ),
    );
  }

  void _executeTransaction(double amount, String phone) async {
    // 1. Close PIN screen first
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // 2. Show processing state
    GlassDialog.showLoading(context, message: 'Processing Transfer...');

    // 3. Process Transaction via Provider (includes mock delay)
    await ref.read(transactionProvider.notifier).processTransaction(
          type: 'Send Money',
          amount: amount,
          target: phone,
        );

    final state = ref.read(transactionProvider);

    if (state.isSuccess) {
      // 4. Perform actual balance deduction on success
      final fee = TransactionService.getServiceCharge(TransactionType.sendMoney, amount);
      final tax = TransactionService.getTax(TransactionType.sendMoney, amount);

      ref.read(balanceProvider.notifier).deductQuickAction(
            title: 'Send Money',
            amount: amount,
            fee: fee,
            tax: tax,
            icon: Icons.send_rounded,
            color: AppTheme.accentColor,
            category: 'Transfer',
            metadata: {
              'to': phone,
              'purpose': _selectedPurpose,
              'message': _messageController.text,
            },
          );

      if (!mounted) return;
      
      // 5. Close loading dialog & Show Receipt
      Navigator.pop(context); 
      TransactionReceiptSheet.showSuccess(
        context: context,
        title: 'Send Money',
        target: 'To: $phone',
        amount: amount,
        fee: fee,
        tax: tax,
        metadata: {
          'Purpose': _selectedPurpose,
          if (_messageController.text.isNotEmpty)
            'Message': _messageController.text,
        },
      );
    } else {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      if (state.error != null) {
        GlassDialog.showError(context, state.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Send Money',
      children: [
        const ServiceHeader(
          title: 'Transfer Funds',
          subtitle:
              'Send money instantly to any NeRuWallet user via phone number.',
          icon: Icons.send_rounded,
          color: AppTheme.accentColor,
        ),
        const SizedBox(height: 10),
        _buildInfoBox(isDark),
        const SizedBox(height: 32),
        ServiceInputSection(
          label: 'Recipient Phone Number',
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: '98XXXXXXXX',
              prefixIcon: const Icon(Icons.phone_iphone_rounded),
              suffixIcon: IconButton(
                onPressed: _pickContact,
                icon: const Icon(Icons.contact_page_rounded),
              ),
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
              counterText: '',
            ),
          ),
        ),

        const SizedBox(height: 24),

        ServiceInputSection(
          label: 'Amount to Send',
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

        const SizedBox(height: 24),

        ServiceInputSection(
          label: 'Transaction Purpose',
          child: DropdownButtonFormField<String>(
            initialValue: _selectedPurpose,
            items: _purposes
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => _selectedPurpose = val!),
            decoration: InputDecoration(
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
              prefixIcon: const Icon(Icons.layers_rounded),
            ),
            dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: AppTheme.radiusMedium,
          ),
        ),

        const SizedBox(height: 24),

        ServiceInputSection(
          label: 'Optional Message',
          child: TextField(
            controller: _messageController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'What is this for?',
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 40),

        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onSendMoney,
            child: const Text('Send Money '),
          ).animate(delay: 600.ms).fadeIn(),
        ),
      ],
    );
  }



  Widget _buildInfoBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Transfers between NeRuWallet users are free and instant.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn();
  }
}
