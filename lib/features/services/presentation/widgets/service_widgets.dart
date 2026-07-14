import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BaseServicePage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const BaseServicePage({
    super.key,
    required this.title,
    required this.children,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class ServiceInputSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const ServiceInputSection({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        child,
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
