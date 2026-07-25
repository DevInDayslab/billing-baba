import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/purchase_order_page.dart';
import 'package:flutter/widgets.dart';

class PurchaseOrderPage extends StatelessWidget {
  const PurchaseOrderPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPurchaseOrderPage(),
      mobile: MobilePurchaseOrderPage(),
    );
  }
}
