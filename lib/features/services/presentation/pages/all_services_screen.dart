import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class AllServicesScreen extends ConsumerWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Grouped Services
    final categories = {
      'Finance': [
        {
          'label': 'Send Money',
          'icon': Icons.send_rounded,
          'color': Colors.blue,
          'route': '/send-money',
        },
        {
          'label': 'Top Up',
          'icon': Icons.add_circle_outline_rounded,
          'color': Colors.green,
          'route': '/top-up',
        },
        {
          'label': 'Withdraw',
          'icon': Icons.file_download_outlined,
          'color': Colors.orange,
          'route': '/withdraw',
        },
      ],
      'Bills & Utilities': [
        {
          'label': 'Electricity',
          'icon': Icons.flash_on_rounded,
          'color': Colors.amber,
          'route': '/electricity',
        },
        {
          'label': 'Water',
          'icon': Icons.water_drop_rounded,
          'color': Colors.blueAccent,
          'route': '/water',
        },
        {
          'label': 'Internet',
          'icon': Icons.router_rounded,
          'color': Colors.purple,
          'route': '/internet',
        },
      ],
      'Government': [
        {
          'label': 'Fine Payment',
          'icon': Icons.gavel_rounded,
          'color': Colors.redAccent,
          'route': '/fine-payment',
        },
      ],
      'Merchant & Lifestyle': [
        {
          'label': 'Food',
          'icon': Icons.restaurant_rounded,
          'color': Colors.orangeAccent,
          'route': '/food',
        },
        {
          'label': 'Tickets',
          'icon': Icons.confirmation_number_rounded,
          'color': Colors.teal,
          'route': '/tickets',
        },
        {
          'label': 'Shopping',
          'icon': Icons.shopping_bag_rounded,
          'color': Colors.pinkAccent,
          'route': '/shopping',
        },
      ],
    };

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryName = categories.keys.elementAt(index);
          final items = categories[categoryName]!;

          return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _buildServiceItem(context, item, isDark);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              )
              .animate(delay: (index * 100).ms)
              .fadeIn()
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => context.push(item['route']),
      borderRadius: AppTheme.radiusLarge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['label'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
