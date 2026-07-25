import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/proforma_invoice_page.dart';
import './mobile/proforma_invoice_page.dart';
import 'package:flutter/widgets.dart';

class ProformaInvoicePage extends StatelessWidget {
  const ProformaInvoicePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopProformaInvoicePage(),
      mobile: const MobileProformaInvoicePage(),
    );
  }
}
