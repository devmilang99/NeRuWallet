import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/dashboard/data/models/quick_action_model.dart';

class QuickActionsNotifier extends StateNotifier<List<QuickActionModel>> {
  QuickActionsNotifier() : super(_defaultActions) {
    _loadSelectedActions();
  }

  static const List<QuickActionModel> allAvailableActions = [
    // Finance
    QuickActionModel(label: 'Top Up', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF8B5CF6), category: 'Finance'),
    QuickActionModel(label: 'Withdraw', icon: Icons.file_download_outlined, color: Color(0xFFF59E0B), category: 'Finance'),
    QuickActionModel(label: 'Exchange', icon: Icons.currency_exchange_rounded, color: Color(0xFF0EA5E9), category: 'Finance'),
    
    // Bills & Payments
    QuickActionModel(label: 'Pay Bill', icon: Icons.receipt_long_rounded, color: Color(0xFFEC4899), category: 'Bills'),
    QuickActionModel(label: 'Electricity', icon: Icons.bolt_rounded, color: Color(0xFFF59E0B), category: 'Bills'),
    QuickActionModel(label: 'Water', icon: Icons.water_drop_rounded, color: Color(0xFF0EA5E9), category: 'Bills'),
    QuickActionModel(label: 'Internet', icon: Icons.wifi_rounded, color: Color(0xFF0EA5E9), category: 'Bills'),
    QuickActionModel(label: 'TV', icon: Icons.tv_rounded, color: Color(0xFF8B5CF6), category: 'Bills'),
    QuickActionModel(label: 'Education', icon: Icons.school_rounded, color: Color(0xFF10B981), category: 'Bills'),
    QuickActionModel(label: 'Insurance', icon: Icons.security_rounded, color: Color(0xFF6366F1), category: 'Bills'),
    
    // Government & Fines
    QuickActionModel(label: 'Fine Payment', icon: Icons.gavel_rounded, color: Color(0xFFFF6B6B), category: 'Government'),
    QuickActionModel(label: 'Gov Services', icon: Icons.account_balance_rounded, color: Color(0xFF6366F1), category: 'Government'),
    QuickActionModel(label: 'Tax Payment', icon: Icons.payments_rounded, color: Color(0xFF10B981), category: 'Government'),
    
    // Merchant & Shopping
    QuickActionModel(label: 'Scan QR', icon: Icons.qr_code_scanner_rounded, color: Color(0xFF6366F1), category: 'Merchant'),
    QuickActionModel(label: 'Tickets', icon: Icons.confirmation_number_rounded, color: Color(0xFFF59E0B), category: 'Merchant'),
    QuickActionModel(label: 'Food', icon: Icons.restaurant_rounded, color: Color(0xFFEC4899), category: 'Merchant'),
    QuickActionModel(label: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFF8B5CF6), category: 'Merchant'),
    
    // Others
    QuickActionModel(label: 'Rewards', icon: Icons.card_giftcard_rounded, color: Color(0xFFFF6B6B), category: 'Other'),
    QuickActionModel(label: 'Referral', icon: Icons.people_rounded, color: Color(0xFF10B981), category: 'Other'),
    QuickActionModel(label: 'Support', icon: Icons.headset_mic_rounded, color: Color(0xFF6366F1), category: 'Other'),
  ];

  static const List<QuickActionModel> _defaultActions = [
    QuickActionModel(label: 'Top Up', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF8B5CF6), category: 'Finance'),
    QuickActionModel(label: 'Pay Bill', icon: Icons.receipt_long_rounded, color: Color(0xFFEC4899), category: 'Bills'),
    QuickActionModel(label: 'Scan QR', icon: Icons.qr_code_scanner_rounded, color: Color(0xFF6366F1), category: 'Merchant'),
    QuickActionModel(label: 'Internet', icon: Icons.wifi_rounded, color: Color(0xFF0EA5E9), category: 'Bills'),
    QuickActionModel(label: 'Fine Payment', icon: Icons.gavel_rounded, color: Color(0xFFFF6B6B), category: 'Government'),
    QuickActionModel(label: 'Gov Services', icon: Icons.account_balance_rounded, color: Color(0xFF6366F1), category: 'Government'),
  ];

  Future<void> _loadSelectedActions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? actionLabels = prefs.getStringList('selected_quick_actions');
    if (actionLabels != null && actionLabels.isNotEmpty) {
      final List<QuickActionModel> loaded = [];
      for (final label in actionLabels) {
        final action = allAvailableActions.firstWhere(
          (a) => a.label == label, 
          orElse: () => _defaultActions.firstWhere((d) => d.label == label, orElse: () => _defaultActions[0])
        );
        if (!loaded.contains(action)) {
          loaded.add(action);
        }
      }
      // Ensure we don't load more than 6 if user previously had more
      state = loaded.take(6).toList();
    }
  }

  Future<void> toggleAction(QuickActionModel action) async {
    final isSelected = state.any((a) => a.label == action.label);
    if (isSelected) {
      if (state.length > 1) { 
        state = state.where((a) => a.label != action.label).toList();
      }
    } else {
      if (state.length < 6) { // Re-limited to 6
        state = [...state, action];
      }
    }
    _saveSelectedActions();
  }

  Future<void> _saveSelectedActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_quick_actions', state.map((a) => a.label).toList());
  }

  bool isSelected(QuickActionModel action) {
    return state.any((a) => a.label == action.label);
  }
}

final quickActionsProvider = StateNotifierProvider<QuickActionsNotifier, List<QuickActionModel>>((ref) {
  return QuickActionsNotifier();
});
