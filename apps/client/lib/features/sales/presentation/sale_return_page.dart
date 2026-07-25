import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/sale_return_page.dart';
import './mobile/sale_return_page.dart';
import 'package:flutter/widgets.dart';

class SaleReturnPage extends StatelessWidget {
  const SaleReturnPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSaleReturnPage(),
      mobile: const MobileSaleReturnPage(),
    );
  }
}
