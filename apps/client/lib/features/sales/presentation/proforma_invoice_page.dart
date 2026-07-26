import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/proforma_invoice_page.dart';
import 'package:flutter/widgets.dart';

class ProformaInvoicePage extends StatelessWidget {
  const ProformaInvoicePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopProformaInvoicePage(),
      mobile: MobileProformaInvoicePage(),
    );
  }
}
