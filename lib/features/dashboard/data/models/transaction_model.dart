import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;
  final String time;

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
    required this.time,
  });
}
