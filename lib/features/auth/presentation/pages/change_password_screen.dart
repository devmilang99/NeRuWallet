import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _handleChangePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      GlassDialog.showError(context, 'Please fill in all fields.');
      return;
    }

    if (newPassword != confirmPassword) {
      GlassDialog.showError(context, 'New passwords do not match.');
      return;
    }

    if (newPassword.length < 8) {
      GlassDialog.showError(
        context,
        'Password must be at least 8 characters long.',
      );
      return;
    }

    GlassDialog.showLoading(context, message: 'Updating password...');

    try {
      await ref
          .read(authServiceProvider)
          .changePassword(oldPassword, newPassword);
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showSuccess(
          context,
          'Your password has been updated successfully.',
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showError(
          context,
          'Failed to update password: ${e.toString().replaceAll("Exception: ", "")}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ensure your account stays secure by using a strong password that you haven't used before.",
              style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryColor,
                fontSize: 16,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 40),
            _buildInputField(
              controller: _oldPasswordController,
              label: 'Current Password',
              obscureText: _obscureOld,
              toggleObscure: () => setState(() => _obscureOld = !_obscureOld),
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: _obscureNew,
              toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _obscureConfirm,
              toggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              isDark: isDark,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _handleChangePassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusLarge,
                ),
              ),
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppTheme.textBodyColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: toggleObscure,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
          ),
        ),
      ],
    );
  }
}
