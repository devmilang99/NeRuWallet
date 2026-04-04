import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String subtitle;
  final double amount; // Base amount (excludes fee/tax)
  final double fee;    // Service charge
  final double tax;    // Tax amount
  final IconData icon;
  final Color color;
  final String time;
  final String category;
  final Map<String, dynamic>? metadata; // To store ticket/receipt specific data

  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.fee = 0.0,
    this.tax = 0.0,
    required this.icon,
    required this.color,
    required this.time,
    this.category = 'Other',
    this.metadata,
  });

  double get totalPayable => amount.abs() + fee + tax;
  
  // For total balance calculation, we need the signed amount including costs
  double get totalDeduction => amount < 0 ? -(amount.abs() + fee + tax) : amount;
}
