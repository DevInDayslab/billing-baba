import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/add_purchase_order_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/add_purchase_order_page.dart';
import 'package:flutter/widgets.dart';

class AddPurchaseOrderPage extends StatelessWidget {
  const AddPurchaseOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddPurchaseOrderPage(orderId: orderId),
      mobile: MobileAddPurchaseOrderPage(orderId: orderId),
    );
  }
}
