import 'package:flutter/material.dart';

class NavItemModel {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  NavItemModel({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
