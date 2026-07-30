import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';

abstract final class PosCategoryStyle {
  static const _backgroundPalette = <Color>[
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFFFEBEE),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
    posSelectedBackground,
  ];

  static const _iconPalette = <IconData>[
    Icons.shopping_basket_outlined,
    Icons.local_drink_outlined,
    Icons.bakery_dining_outlined,
    Icons.fastfood_outlined,
    Icons.inventory_2_outlined,
    Icons.category_outlined,
    Icons.storefront_outlined,
  ];

  static Color backgroundColor(String? categoryKey) {
    if (categoryKey == null || categoryKey.trim().isEmpty) {
      return AppColors.background;
    }
    return _backgroundPalette[_paletteIndex(categoryKey) %
        _backgroundPalette.length];
  }

  static IconData icon(String? categoryKey) {
    if (categoryKey == null || categoryKey.trim().isEmpty) {
      return Icons.inventory_2_outlined;
    }
    return _iconPalette[_paletteIndex(categoryKey) % _iconPalette.length];
  }

  static int _paletteIndex(String key) => key.hashCode.abs();
}
