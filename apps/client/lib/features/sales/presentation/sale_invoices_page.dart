import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/sale_invoices_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/sale_invoices_page.dart';
import 'package:flutter/widgets.dart';

class SaleInvoicesPage extends StatelessWidget {
  const SaleInvoicesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSaleInvoicesPage(),
      mobile: MobileSaleInvoicesPage(),
    );
  }
}
