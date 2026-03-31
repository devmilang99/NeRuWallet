import 'package:flutter/material.dart';
import 'package:neruwallet/features/services/presentation/pages/bills/bill_payment_screen.dart';

class FinePaymentScreen extends StatelessWidget {
  const FinePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BillPaymentScreen(
      billType: 'Traffic Fine Payment',
      icon: Icons.gavel_rounded,
      color: Color(0xFFFF6B6B),
      label: 'Ticket Number',
    );
  }
}
