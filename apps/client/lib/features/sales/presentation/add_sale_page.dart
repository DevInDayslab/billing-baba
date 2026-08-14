import 'package:billing_baba/features/sales/presentation/desktop/add_sale_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_sale_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddSalePage extends StatelessWidget {
  const AddSalePage({
    super.key,
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.initialPartyId,
    this.initialPartyName,
    this.readOnly = false,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final String? initialPartyId;
  final String? initialPartyName;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddSalePage(
        invoiceId: invoiceId,
        duplicateFromId: duplicateFromId,
        attachOrderIds: attachOrderIds,
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
        readOnly: readOnly,
      ),
      mobile: MobileAddSalePage(
        invoiceId: invoiceId,
        duplicateFromId: duplicateFromId,
        attachOrderIds: attachOrderIds,
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
        readOnly: readOnly,
      ),
    );
  }
}
