import 'package:flutter/material.dart';
import 'package:neruwallet/features/services/presentation/widgets/merchant_collection.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  final List<Map<String, dynamic>> _shoppingPartners = const [
    {
      'name': 'Daraz Pay',
      'icon': Icons.shopping_cart_rounded,
      'color': Color(0xFFF97316),
      'category': 'Online Shopping',
    },
    {
      'name': 'Bhat-Bhateni',
      'icon': Icons.store_rounded,
      'color': Color(0xFF2563EB),
      'category': 'Supermarket',
    },
    {
      'name': 'BigMart',
      'icon': Icons.local_grocery_store_rounded,
      'color': Color(0xFF16A34A),
      'category': 'Department Store',
    },
    {
      'name': 'Sastodeal',
      'icon': Icons.local_mall_rounded,
      'color': Color(0xFFDB2777),
      'category': 'Online Shopping',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseServicePage(
      title: 'Shopping',
      children: [
        const SizedBox(height: 8),
        MerchantCollection(
          title: 'Stores & Malls',
          merchants: _shoppingPartners,
        ),
      ],
    );
  }
}
