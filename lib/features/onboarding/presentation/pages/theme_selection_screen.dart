import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

import '../../../../core/providers/theme_provider.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() =>
      _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedThemeMode = ref.watch(themeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Choose Your Style',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'Select a theme that suits you best. You can always change this in settings.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _buildThemeCard(
                      context,
                      title: 'Light',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      isSelected: selectedThemeMode == ThemeMode.light,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildThemeCard(
                      context,
                      title: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      isSelected: selectedThemeMode == ThemeMode.dark,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              _buildThemeCard(
                context,
                title: 'System Preference',
                icon: Icons.settings_brightness_rounded,
                mode: ThemeMode.system,
                isSelected: selectedThemeMode == ThemeMode.system,
                isWide: true,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.go('/onboarding');
                },
                child: const Text('Continue'),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    bool isWide = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).state = mode;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isWide ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : (isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.8)),
          borderRadius: AppTheme.radiusLarge,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
