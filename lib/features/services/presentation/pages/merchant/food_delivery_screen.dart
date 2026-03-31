import 'package:flutter/material.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/merchant_collection.dart';

class FoodDeliveryScreen extends StatelessWidget {
  const FoodDeliveryScreen({super.key});

  final List<Map<String, dynamic>> _foodPartners = const [
    {'name': 'Foodmandu', 'icon': Icons.delivery_dining_rounded, 'color': Color(0xFFEF4444), 'category': 'Food Delivery'},
    {'name': 'Pathao Food', 'icon': Icons.motorcycle_rounded, 'color': Color(0xFF10B981), 'category': 'Delivery'},
    {'name': 'KFC Pay', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFB91C1C), 'category': 'Restaurant'},
    {'name': 'Burger King', 'icon': Icons.lunch_dining_rounded, 'color': Color(0xFFF59E0B), 'category': 'Restaurant'},
  ];

  @override
  Widget build(BuildContext context) {
    return BaseServicePage(
      title: 'Food & Dining',
      children: [
        const ServiceHeader(
          title: 'Hungry?',
          subtitle: 'Pay at your favorite restaurants or order food online with NeRuWallet.',
          icon: Icons.restaurant_rounded,
          color: Color(0xFFEC4899),
        ),
        const SizedBox(height: 32),
        MerchantCollection(title: 'Top Partners', merchants: _foodPartners),
      ],
    );
  }
}
