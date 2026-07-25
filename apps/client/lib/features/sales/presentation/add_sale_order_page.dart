import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_sale_order_page.dart';
import './mobile/add_sale_order_page.dart';
import 'package:flutter/widgets.dart';

class AddSaleOrderPage extends StatelessWidget {
  const AddSaleOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddSaleOrderPage(orderId: orderId),
      mobile: MobileAddSaleOrderPage(orderId: orderId),
    );
  }
}
