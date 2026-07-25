import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_sale_page.dart';
import 'package:flutter/widgets.dart';

class AddSalePage extends StatelessWidget {
  const AddSalePage({
    super.key,
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.readOnly = false,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddSalePage(invoiceId: invoiceId, duplicateFromId: duplicateFromId, attachOrderIds: attachOrderIds, readOnly: readOnly),
      mobile: MobileAddSalePage(invoiceId: invoiceId, duplicateFromId: duplicateFromId, attachOrderIds: attachOrderIds, readOnly: readOnly),
    );
  }
}
