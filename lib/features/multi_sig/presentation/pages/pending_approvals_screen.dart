import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/secure_signing_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Approvals',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildApprovalCard(
            context,
            ref,
            title: 'Office Rent - July',
            amount: 'Rs. 75,000',
            group: 'Business Ops',
            requestedBy: 'Suraj K.',
          ),
          const SizedBox(height: 16),
          _buildApprovalCard(
            context,
            ref,
            title: 'School Fees',
            amount: 'Rs. 12,500',
            group: 'Family Fund',
            requestedBy: 'Priya M.',
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String amount,
    required String group,
    required String requestedBy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  requestedBy[0],
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requestedBy,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Requested in $group',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1/2 Signed',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleApprove(context, ref, title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    final signingService = ref.read(secureSigningServiceProvider);

    GlassDialog.showLoading(context, message: 'Authenticating...');

    // Simulate multi-sig signing process
    // In real app, we would sign a SHA-256 hash of the transaction metadata
    final result = await signingService.signMultiSigPayload(
      Uint8List.fromList(
        DateTime.now().toIso8601String().codeUnits,
      ), // Mock payload
      'group_id_123',
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (result != null) {
      GlassDialog.showSuccess(
        context,
        'Transaction "$title" signed successfully using hardware HSM.',
        onConfirm: () => Navigator.pop(context),
      );
    } else {
      GlassDialog.showError(
        context,
        'Biometric authentication failed or was canceled.',
      );
    }
  }
}
