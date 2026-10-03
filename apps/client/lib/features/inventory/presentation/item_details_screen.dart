import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_details_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({
    required this.itemId,
    this.fallbackItem,
    super.key,
  });

  final String itemId;
  final Object? fallbackItem;

  @override
  Widget build(BuildContext context) {
    final item = fallbackItem is InventoryItem
        ? fallbackItem as InventoryItem
        : null;

    return AdaptivePage(
      desktop: const ComingSoonPage(title: 'Item Details'),
      mobile: MobileItemDetailsScreen(
        itemId: itemId,
        fallbackItem: item,
      ),
    );
  }
}
