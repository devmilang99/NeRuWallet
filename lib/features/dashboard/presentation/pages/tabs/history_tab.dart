import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../widgets/transaction_tile.dart';
import 'package:neruwallet/core/services/database/app_database.dart';

class HistoryTab extends StatefulWidget {
  final bool isDark;
  final List<Transaction> transactions;

  const HistoryTab({
    super.key,
    required this.isDark,
    required this.transactions,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Income', 'Expense', 'Movies', 'Travel', 'Payments'];

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'All') return widget.transactions;
    final lowerFilter = _selectedFilter.toLowerCase();
    
    if (lowerFilter == 'income') {
      return widget.transactions.where((t) => t.amount > 0).toList();
    }
    if (lowerFilter == 'expense') {
      return widget.transactions.where((t) => t.amount < 0).toList();
    }
    if (lowerFilter == 'movies') {
      // Check category first, then title
      return widget.transactions.where((t) => 
        t.category.toLowerCase().contains('movie') || 
        t.title.toLowerCase().contains('movie') ||
        t.title.toLowerCase().contains('ticket')
      ).toList();
    }
    if (lowerFilter == 'travel') {
      return widget.transactions.where((t) => 
        t.category.toLowerCase().contains('travel') || 
        t.category.toLowerCase().contains('flight') || 
        t.category.toLowerCase().contains('bus') || 
        t.title.toLowerCase().contains('flight') || 
        t.title.toLowerCase().contains('bus')
      ).toList();
    }
    if (lowerFilter == 'payments') {
      return widget.transactions.where((t) => 
        t.category.toLowerCase().contains('payment') || 
        t.title.toLowerCase().contains('qr')
      ).toList();
    }
    return widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: widget.isDark ? AppTheme.backgroundDark : const Color(0xFFF1F5F9),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Transactions',
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_list_rounded),
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final isActive = _selectedFilter == _filters[i];
                  final filter = _filters[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryColor
                            : (widget.isDark ? AppTheme.surfaceDark : Colors.white),
                        borderRadius: AppTheme.radiusFull,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : (widget.isDark
                                  ? AppTheme.textBodyDark
                                  : AppTheme.textBodyColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ).animate().fadeIn(),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: _filteredTransactions.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: (widget.isDark
                                  ? AppTheme.textHintDark
                                  : AppTheme.textHintColor)
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: widget.isDark
                                ? AppTheme.textHintDark
                                : AppTheme.textHintColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TransactionTile(
                      transaction: _filteredTransactions[i],
                      isDark: widget.isDark,
                      index: i,
                    ),
                    childCount: _filteredTransactions.length,
                  ),
                ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = filter);
                      Navigator.pop(context);
                    }
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

