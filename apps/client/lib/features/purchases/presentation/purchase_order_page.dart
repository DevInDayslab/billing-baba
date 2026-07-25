import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/purchase_order_page.dart';
import './mobile/purchase_order_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseOrderPage extends StatelessWidget {
  const PurchaseOrderPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPurchaseOrderPage(),
      mobile: const MobilePurchaseOrderPage(),
    );
  }
}
