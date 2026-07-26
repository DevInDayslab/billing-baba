import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/sale_return_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/sale_return_page.dart';
import 'package:flutter/widgets.dart';

class SaleReturnPage extends StatelessWidget {
  const SaleReturnPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSaleReturnPage(),
      mobile: MobileSaleReturnPage(),
    );
  }
}
