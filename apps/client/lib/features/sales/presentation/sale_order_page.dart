import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/sale_order_page.dart';
import './mobile/sale_order_page.dart';
import 'package:flutter/widgets.dart';

class SaleOrderPage extends StatelessWidget {
  const SaleOrderPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSaleOrderPage(),
      mobile: const MobileSaleOrderPage(),
    );
  }
}
