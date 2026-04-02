import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/merchant_collection.dart';
import 'food_items_screen.dart';

class FoodDeliveryScreen extends StatelessWidget {
  const FoodDeliveryScreen({super.key});

  final List<Map<String, dynamic>> _foodPartners = const [
    {
      'name': 'Foodmandu',
      'icon': Icons.delivery_dining_rounded,
      'color': Color(0xFFEF4444),
      'category': 'Food Delivery',
    },
    {
      'name': 'Pathao Food',
      'icon': Icons.motorcycle_rounded,
      'color': Color(0xFF10B981),
      'category': 'Delivery',
    },
    {
      'name': 'KFC Pay',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFB91C1C),
      'category': 'Restaurant',
    },
    {
      'name': 'Burger King',
      'icon': Icons.lunch_dining_rounded,
      'color': Color(0xFFF59E0B),
      'category': 'Restaurant',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Food & Dining',
      children: [
        const ServiceHeader(
          title: 'Hungry?',
          subtitle:
              'Pay at your favorite restaurants or order food online with NeRuWallet.',
          icon: Icons.restaurant_rounded,
          color: Color(0xFFEC4899),
        ),
        const SizedBox(height: 32),

        // Browse Categories Button
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFEC4899).withValues(alpha: 0.1),
                const Color(0xFFEC4899).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodItemsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        size: 28,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Browse Food Categories',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Burgers, Pizza, Momos, and more',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFEC4899),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().slideX(begin: -0.2, end: 0).fadeIn(),

        const SizedBox(height: 32),
        MerchantCollection(title: 'Top Partners', merchants: _foodPartners),
      ],
    );
  }
}
