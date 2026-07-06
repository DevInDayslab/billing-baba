import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:flutter/material.dart';

abstract final class PosCategoryStyle {
  static Color backgroundColor(String category) {
    return switch (category) {
      'Dairy' => posSelectedBackground,
      'Bakery' => const Color(0xFFFFF3E0),
      'Grocery' => const Color(0xFFE8F5E9),
      'Snacks' => const Color(0xFFFFEBEE),
      _ => AppColors.background,
    };
  }

  static IconData icon(String category) {
    return switch (category) {
      'Dairy' => Icons.local_drink_outlined,
      'Bakery' => Icons.bakery_dining_outlined,
      'Grocery' => Icons.shopping_basket_outlined,
      'Snacks' => Icons.fastfood_outlined,
      _ => Icons.inventory_2_outlined,
    };
  }
}
