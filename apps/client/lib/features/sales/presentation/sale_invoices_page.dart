import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/sale_invoices_page.dart';
import './mobile/sale_invoices_page.dart';
import 'package:flutter/widgets.dart';

class SaleInvoicesPage extends StatelessWidget {
  const SaleInvoicesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSaleInvoicesPage(),
      mobile: const MobileSaleInvoicesPage(),
    );
  }
}
