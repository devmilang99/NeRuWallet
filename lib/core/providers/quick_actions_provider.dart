import 'package:flutter/material.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/dashboard/data/models/quick_action_model.dart';

part 'quick_actions_provider.g.dart';

@riverpod
class QuickActions extends _$QuickActions {
  @override
  List<QuickActionModel> build() {
    _loadSelectedActions();
    return _defaultActions;
  }

  static const List<QuickActionModel> allAvailableActions = [
    // Finance
    QuickActionModel(
      label: 'Top Up',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF8B5CF6),
      category: 'Finance',
    ),
    QuickActionModel(
      label: 'Withdraw',
      icon: Icons.file_download_outlined,
      color: Color(0xFFF59E0B),
      category: 'Finance',
    ),
    QuickActionModel(
      label: 'Exchange',
      icon: Icons.currency_exchange_rounded,
      color: Color(0xFF0EA5E9),
      category: 'Finance',
    ),
    QuickActionModel(
      label: 'Send Money',
      icon: Icons.send_rounded,
      color: Color(0xFF10B981),
      category: 'Finance',
    ),

    // Bills & Payments
    QuickActionModel(
      label: 'Electricity',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B),
      category: 'Bills',
    ),
    QuickActionModel(
      label: 'Water',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0EA5E9),
      category: 'Bills',
    ),
    QuickActionModel(
      label: 'Internet',
      icon: Icons.wifi_rounded,
      color: Color(0xFF0EA5E9),
      category: 'Bills',
    ),

    // Government & Fines
    QuickActionModel(
      label: 'Fine Payment',
      icon: Icons.gavel_rounded,
      color: Color(0xFFFF6B6B),
      category: 'Government',
    ),

    // Merchant & Shopping
    QuickActionModel(
      label: 'Tickets',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFFF59E0B),
      category: 'Merchant',
    ),
  ];

  static const List<QuickActionModel> _defaultActions = [
    QuickActionModel(
      label: 'Top Up',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF8B5CF6),
      category: 'Finance',
    ),
    QuickActionModel(
      label: 'Send Money',
      icon: Icons.send_rounded,
      color: Color(0xFF10B981),
      category: 'Finance',
    ),
    QuickActionModel(
      label: 'Tickets',
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFFF59E0B),
      category: 'Merchant',
    ),
    QuickActionModel(
      label: 'Fine Payment',
      icon: Icons.gavel_rounded,
      color: Color(0xFFFF6B6B),
      category: 'Government',
    ),
  ];

  Future<void> _loadSelectedActions() async {
    final prefService = ref.read(preferenceServiceProvider);
    final actionLabels = await prefService.getStringList(
      'selected_quick_actions',
    );
    if (actionLabels != null && actionLabels.isNotEmpty) {
      final loaded = <QuickActionModel>[];
      for (final label in actionLabels) {
        final action = allAvailableActions.firstWhere(
          (a) => a.label == label,
          orElse: () => _defaultActions.firstWhere(
            (d) => d.label == label,
            orElse: () => _defaultActions[0],
          ),
        );
        if (!loaded.contains(action)) {
          loaded.add(action);
        }
      }
      state = loaded.take(8).toList();
    }
  }

  void reorderActions(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedList = <QuickActionModel>[...state];
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);
    state = updatedList;
    _saveSelectedActions();
  }

  Future<void> toggleAction(QuickActionModel action) async {
    final isSelected = state.any((a) => a.label == action.label);
    if (isSelected) {
      if (state.length > 1) {
        state = state.where((a) => a.label != action.label).toList();
      }
    } else {
      if (state.length < 8) {
        state = [...state, action];
      }
    }
    _saveSelectedActions();
  }

  Future<void> _saveSelectedActions() async {
    final prefService = ref.read(preferenceServiceProvider);
    await prefService.setStringList(
      'selected_quick_actions',
      state.map((a) => a.label).toList(),
    );
  }

  bool isSelected(QuickActionModel action) {
    return state.any((a) => a.label == action.label);
  }
}
