import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class FoodItemsScreen extends StatelessWidget {
  const FoodItemsScreen({super.key});

  final List<Map<String, dynamic>> _foodCategories = const [
    {
      'name': 'Burgers',
      'icon': Icons.lunch_dining_rounded,
      'color': Color(0xFFF59E0B),
      'itemCount': 45,
      'description': 'Fresh & Juicy',
    },
    {
      'name': 'Pizza',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFEF4444),
      'itemCount': 32,
      'description': 'Crispy Crust',
    },
    {
      'name': 'Chinese',
      'icon': Icons.ramen_dining_rounded,
      'color': Color(0xFFEC4899),
      'itemCount': 28,
      'description': 'Authentic Taste',
    },
    {
      'name': 'Momos',
      'icon': Icons.brunch_dining_rounded,
      'color': Color(0xFF10B981),
      'itemCount': 18,
      'description': 'Steamed & Fresh',
    },
    {
      'name': 'Biryani',
      'icon': Icons.rice_bowl_rounded,
      'color': Color(0xFF8B5CF6),
      'itemCount': 24,
      'description': 'Aromatic Rice',
    },
    {
      'name': 'Salads',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF14B8A6),
      'itemCount': 15,
      'description': 'Healthy Choice',
    },
    {
      'name': 'Desserts',
      'icon': Icons.cake_rounded,
      'color': Color(0xFFD97706),
      'itemCount': 22,
      'description': 'Sweet Treats',
    },
    {
      'name': 'Beverages',
      'icon': Icons.local_cafe_rounded,
      'color': Color(0xFF6B7280),
      'itemCount': 35,
      'description': 'Refreshing Drinks',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Food Items',
      children: [
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.88,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _foodCategories.length,
          itemBuilder: (context, index) {
            final category = _foodCategories[index];
            return _buildFoodCategoryBox(context, category, isDark, index);
          },
        ).animate(delay: 100.ms).fadeIn(),
      ],
    );
  }

  Widget _buildFoodCategoryBox(
    BuildContext context,
    Map<String, dynamic> category,
    bool isDark,
    int index,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category['name']} coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category['color'].withValues(alpha: 0.1),
              category['color'].withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: category['color'].withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and background circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: category['color'].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category['icon'],
                      size: 32,
                      color: category['color'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category name
                  Text(
                    category['name'],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  // Description
                  Text(
                    category['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Item count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: category['color'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${category['itemCount']} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Gradient overlay
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      category['color'].withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (100 + index * 50).ms).slideY(begin: 0.2, end: 0).fadeIn();
  }
}
