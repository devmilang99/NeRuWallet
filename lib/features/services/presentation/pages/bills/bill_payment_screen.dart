import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/transaction_receipt_sheet.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/transaction_service.dart';

class BillPaymentScreen extends ConsumerStatefulWidget {
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
  ConsumerState<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends ConsumerState<BillPaymentScreen> {
  final _customerIdController = TextEditingController();
  final _amountController = TextEditingController();

  // Mock Data
  final Map<String, List<String>> _provinceDistricts = {
    'Bagmati': ['Kathmandu', 'Lalitpur', 'Bhaktapur', 'Chitwan'],
    'Gandaki': ['Kaski', 'Lamjung', 'Tanahun', 'Myagdi'],
    'Lumbini': ['Rupandehi', 'Banke', 'Dang', 'Palpa'],
    'Koshi': ['Morang', 'Sunsari', 'Jhapa', 'Ilam'],
    'Madhesh': ['Parsa', 'Dhanusha', 'Bara', 'Saptari'],
    'Karnali': ['Surkhet', 'Dailekh', 'Jajarkot', 'Humla'],
    'Sudurpashchim': ['Kailali', 'Kanchanpur', 'Doti', 'Achham']
  };

  final List<String> _internetProviders = [
    'WorldLink', 'Vianet', 'Subisu', 'Classic Tech', 'DishHome Fibernet'
  ];

  final List<String> _serviceCenters = [
    'NEA Baneshwor', 'NEA Kuleshwor', 'NEA Ratnapark', 'NEA Pulchowk', 'KUKL Central'
  ];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCenter;
  String? _selectedInternetProvider;

  void _onPay() {
    final customerId = _customerIdController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;

    if (customerId.isEmpty) {
      GlassDialog.showError(context, 'Please enter your ${widget.label} ID.');
      return;
    }

    if (widget.billType == 'Electricity' || widget.billType == 'Water') {
      if (_selectedProvince == null || _selectedDistrict == null || _selectedCenter == null) {
        GlassDialog.showError(context, 'Please select your Province, District, and Center.');
        return;
      }
    }

    if (widget.billType == 'Internet' && _selectedInternetProvider == null) {
      GlassDialog.showError(context, 'Please select an internet provider.');
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
        fee: TransactionService.getServiceCharge(TransactionType.utility, amount),
        tax: TransactionService.getTax(TransactionType.utility, amount),
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

    // Deduct balance here (as the utility transaction is now completed successfully)
    ref.read(balanceProvider.notifier).deductQuickAction(
      title: '${widget.billType} Bill',
      amount: amount,
      fee: TransactionService.getServiceCharge(TransactionType.utility, amount),
      tax: TransactionService.getTax(TransactionType.utility, amount),
      icon: widget.icon,
      color: widget.color,
      category: 'Utility',
      metadata: {
        'customerId': customerId,
        'type': widget.billType,
        'center': _selectedCenter,
      },
    );

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

        // Province Dropdown (Always Visible)
        if (widget.billType == 'Electricity' || widget.billType == 'Water' || widget.billType.contains('Fine'))
          _buildDropdown(
            label: 'Province',
            hint: 'Select Province',
            value: _selectedProvince,
            items: _provinceDistricts.keys.toList(),
            onChanged: (val) {
              setState(() {
                _selectedProvince = val;
                _selectedDistrict = null;
                _selectedCenter = null;
              });
            },
            isDark: isDark,
            icon: Icons.map_rounded,
          ),

        // District Dropdown (Visible only after Province)
        if (_selectedProvince != null && (widget.billType == 'Electricity' || widget.billType == 'Water' || widget.billType.contains('Fine')))
          _buildDropdown(
            label: 'District',
            hint: 'Select District',
            value: _selectedDistrict,
            items: _provinceDistricts[_selectedProvince!]!,
            onChanged: (val) {
              setState(() {
                _selectedDistrict = val;
                _selectedCenter = null;
              });
            },
            isDark: isDark,
            icon: Icons.location_city_rounded,
          ),

        // Center Dropdown (Visible only after District)
        if (_selectedDistrict != null && (widget.billType == 'Electricity' || widget.billType == 'Water'))
          _buildDropdown(
            label: 'Service Center',
            hint: 'Select Service Center',
            value: _selectedCenter,
            items: _serviceCenters,
            onChanged: (val) => setState(() => _selectedCenter = val),
            isDark: isDark,
            icon: Icons.electrical_services_rounded,
          ),

        if (widget.billType == 'Internet')
          _buildDropdown(
            label: 'Internet Provider',
            hint: 'Select Provider',
            value: _selectedInternetProvider,
            items: _internetProviders,
            onChanged: (val) => setState(() => _selectedInternetProvider = val),
            isDark: isDark,
            icon: Icons.router_rounded,
          ),

        // Essential Fields (Always Visible as per request)
        const SizedBox(height: 16),
        ServiceInputSection(
          label: '${widget.label} ID / Consumer Number',
          child: TextField(
            controller: _customerIdController,
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

        // Payment Summary Card (Visible only after amount is entered)
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
                    color: widget.color.withValues(alpha: 0.05),
                    borderRadius: AppTheme.radiusLarge,
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Service Charge', 'Rs. ${TransactionService.getServiceCharge(TransactionType.utility, amount).toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Service Tax (VAT)', 'Rs. ${TransactionService.getTax(TransactionType.utility, amount).toStringAsFixed(2)}'),
                      const Divider(height: 24),
                      _buildInfoRow('Total Payable', 'Rs. ${TransactionService.getTotalPayable(TransactionType.utility, amount).toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],
            );
          },
        ),

        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onPay,
          style: ElevatedButton.styleFrom(backgroundColor: widget.color),
          child: Text('Pay ${widget.billType} Bill'),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required IconData icon,
  }) {
    return Column(
      children: [
        ServiceInputSection(
          label: label,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            hint: Text(hint, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
              prefixIcon: Icon(icon),
            ),
            dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: AppTheme.radiusMedium,
          ),
        ),
        const SizedBox(height: 24),
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
