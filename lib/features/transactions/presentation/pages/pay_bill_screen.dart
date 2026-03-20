import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_dialog.dart';
import '../providers/transaction_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PayBillScreen extends ConsumerStatefulWidget {
  const PayBillScreen({super.key});

  @override
  ConsumerState<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends ConsumerState<PayBillScreen> {
  final _amountController = TextEditingController();
  final _customerCodeController = TextEditingController();

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'NEA Electricity',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'WorldLink ISP',
      'icon': Icons.wifi_rounded,
      'color': const Color(0xFF0EA5E9),
    },
    {
      'name': 'KUKL Water',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'name': 'Dish Home TV',
      'icon': Icons.tv_rounded,
      'color': const Color(0xFFEF4444),
    },
  ];

  int _selectedServiceIndex = 0;

  void _onPay() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;
    final customerCode = _customerCodeController.text;

    if (amount <= 0 || customerCode.isEmpty) {
      GlassDialog.showError(
        context,
        'Please enter a valid amount and customer identifier.',
      );
      return;
    }

    GlassDialog.showLoading(context, message: 'Processing Bill Payment...');

    await ref.read(transactionProvider.notifier).processTransaction(
      type: 'Bill Payment',
      amount: amount,
      target: _services[_selectedServiceIndex]['name'],
    );

    if (!mounted) return;

    // Remove loading dialog
    Navigator.pop(context);

    final state = ref.read(transactionProvider);

    if (state.isSuccess) {
      GlassDialog.showSuccess(
        context,
        'Rs. ${amount.toStringAsFixed(2)} bill paid successfully to ${_services[_selectedServiceIndex]['name']} for $customerCode.',
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
          'Pay Utility Bills',
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
              'Select Service Provider',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (ctx, i) {
                      final selected = _selectedServiceIndex == i;
                      final serviceColor = _services[i]['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedServiceIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 110,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected ? serviceColor : (isDark ? AppTheme.surfaceDark : Colors.white),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: selected ? serviceColor : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              if (selected)
                                BoxShadow(
                                  color: serviceColor.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _services[i]['icon'],
                                color: selected ? Colors.white : serviceColor,
                                size: 32,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _services[i]['name'].split(' ')[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: selected ? Colors.white : null,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                .animate(delay: 100.ms)
                .fadeIn()
                .slideX(begin: 0.1, end: 0),
            const SizedBox(height: 40),
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
                        controller: _customerCodeController,
                        label: 'Customer ID / Number',
                        hint: 'e.g. 102.15.001',
                        icon: Icons.tag_rounded,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Bill Amount',
                        hint: '0.00',
                        icon: Icons.currency_rupee_rounded,
                        isNumber: true,
                        autoFocus: true,
                      ),
                    ],
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Confirm & Pay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
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
