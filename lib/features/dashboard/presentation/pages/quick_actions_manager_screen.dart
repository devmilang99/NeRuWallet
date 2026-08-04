import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/quick_actions_provider.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

import '../../data/models/quick_action_model.dart';

class QuickActionsManagerScreen extends ConsumerStatefulWidget {
  final bool isDark;

  const QuickActionsManagerScreen({
    required this.isDark, super.key,
  });

  @override
  ConsumerState<QuickActionsManagerScreen> createState() => _QuickActionsManagerScreenState();
}

class _QuickActionsManagerScreenState extends ConsumerState<QuickActionsManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedActions = ref.watch(quickActionsProvider);
    const allActions = QuickActionsNotifier.allAvailableActions;
    final isDark = widget.isDark;

    // Filter and group actions efficiently (only rebuild on search change)
    final filteredActions = allActions.where((action) {
      final searchLower = _searchQuery.toLowerCase();
      return action.label.toLowerCase().contains(searchLower) ||
             action.category.toLowerCase().contains(searchLower);
    }).toList();

    // Group by category efficiently
    final groupedActions = <String, List<QuickActionModel>>{};
    for (final action in filteredActions) {
      groupedActions.putIfAbsent(action.category, () => []).add(action);
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('All Services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${selectedActions.length}/8 Selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selectedActions.length >= 8 ? Colors.orange : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: groupedActions.entries.map((entry) {
                return _buildCategorySection(context, entry.key, entry.value, selectedActions, isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search for services...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          filled: true,
          fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategorySection(
    BuildContext context, 
    String category, 
    List<QuickActionModel> actions, 
    List<QuickActionModel> selectedActions,
    bool isDark
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: actions.length,
          itemBuilder: (ctx, i) {
            final action = actions[i];
            final isSelected = selectedActions.any((a) => a.label == action.label);
            
            return GestureDetector(
              onTap: () {
                ref.read(quickActionsProvider.notifier).toggleAction(action);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: isSelected ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected ? Border.all(color: action.color, width: 2) : null,
                        ),
                        child: Icon(action.icon, color: action.color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 10,
                          color: isDark ? Colors.white : AppTheme.textBodyColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 10),
                      ).animate().scale(),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
