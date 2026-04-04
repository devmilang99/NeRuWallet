import 'package:flutter/material.dart';

enum TransactionType {
  utility,
  movie,
  bus,
  flight,
  withdraw,
  sendMoney,
  topUp,
  qrPayment,
  fine,
}

class TransactionService {
  static double getServiceCharge(TransactionType type, double amount, {bool isVoucherActive = false}) {
    if (isVoucherActive) return 0.0;
    switch (type) {
      case TransactionType.utility:
        return amount < 100 ? 2.0 : 5.0; // Tiered or flat fee
      case TransactionType.movie:
        return 20.0; // Flat service charge per booking
      case TransactionType.bus:
        return 35.0; // Higher for bus convenience
      case TransactionType.flight:
        return 50.0; // Agency service charge
      case TransactionType.withdraw:
        return 10.0; // Flat or could be % (see below)
      case TransactionType.sendMoney:
      case TransactionType.topUp:
        return 0.0; // Free
      case TransactionType.qrPayment:
        return 0.0; // Usually no user fee for QR
      case TransactionType.fine:
        return 10.0;
    }
  }

  static double getTax(TransactionType type, double amount, {bool isVoucherActive = false}) {
    if (isVoucherActive) return 0.0;
    switch (type) {
      case TransactionType.movie:
      case TransactionType.bus:
      case TransactionType.flight:
        return amount * 0.13; // 13% VAT
      case TransactionType.qrPayment:
        return amount * 0.01; // 1% Service Tax
      case TransactionType.withdraw:
        return amount * 0.015; // 1.5% Processing Fee (as tax)
      default:
        return 0.0;
    }
  }

  static double getTotalPayable(TransactionType type, double amount, {bool isVoucherActive = false}) {
    return amount + getServiceCharge(type, amount, isVoucherActive: isVoucherActive) + getTax(type, amount, isVoucherActive: isVoucherActive);
  }

  static IconData getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.utility: return Icons.bolt_rounded;
      case TransactionType.movie: return Icons.movie_rounded;
      case TransactionType.bus: return Icons.directions_bus_rounded;
      case TransactionType.flight: return Icons.flight_takeoff_rounded;
      case TransactionType.withdraw: return Icons.account_balance_wallet_rounded;
      case TransactionType.sendMoney: return Icons.send_rounded;
      case TransactionType.topUp: return Icons.add_circle_rounded;
      case TransactionType.qrPayment: return Icons.qr_code_scanner_rounded;
      case TransactionType.fine: return Icons.account_balance_rounded;
    }
  }

  static Color getColor(TransactionType type) {
    switch (type) {
      case TransactionType.utility: return Colors.orange;
      case TransactionType.movie: return const Color(0xFF6366F1);
      case TransactionType.bus: return const Color(0xFFEC4899);
      case TransactionType.flight: return const Color(0xFF10B981);
      case TransactionType.withdraw: return Colors.redAccent;
      case TransactionType.sendMoney: return Colors.blue;
      case TransactionType.topUp: return Colors.green;
      case TransactionType.qrPayment: return const Color(0xFF8B5CF6);
      case TransactionType.fine: return Colors.indigo;
    }
  }
}
