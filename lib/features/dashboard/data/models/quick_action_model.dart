import 'package:flutter/material.dart';

class QuickActionModel {
  final String label;
  final IconData icon;
  final Color color;
  final String category;

  const QuickActionModel({
    required this.label,
    required this.icon,
    required this.color,
    this.category = 'Other',
  });

}
