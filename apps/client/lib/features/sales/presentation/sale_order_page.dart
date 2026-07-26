import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/sale_order_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/sale_order_page.dart';
import 'package:flutter/widgets.dart';

class SaleOrderPage extends StatelessWidget {
  const SaleOrderPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSaleOrderPage(),
      mobile: MobileSaleOrderPage(),
    );
  }
}
