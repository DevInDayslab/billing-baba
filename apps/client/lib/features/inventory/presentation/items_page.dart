import 'package:billing_baba/features/inventory/presentation/desktop/items_page.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/items_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopItemsPage(),
      mobile: MobileItemsPage(),
    );
  }
}
