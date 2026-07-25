import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/items_page.dart';
import './mobile/items_page.dart';
import 'package:flutter/widgets.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopItemsPage(),
      mobile: const MobileItemsPage(),
    );
  }
}
