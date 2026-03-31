import 'package:flutter/material.dart';
import 'package:neruwallet/features/services/presentation/pages/bills/bill_payment_screen.dart';

class TaxPaymentScreen extends StatelessWidget {
  const TaxPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BillPaymentScreen(
      billType: 'Tax Payment',
      icon: Icons.payments_rounded,
      color: Color(0xFF10B981),
      label: 'PAN / Taxpayer ID',
    );
  }
}
