import 'package:billing_baba/features/sales/presentation/desktop/add_proforma_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_proforma_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class AddProformaPage extends StatelessWidget {
  const AddProformaPage({
    super.key,
    this.proformaId,
    this.duplicateFromId,
  });

  final String? proformaId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddProformaPage(
        proformaId: proformaId,
        duplicateFromId: duplicateFromId,
      ),
      mobile: MobileAddProformaPage(
        proformaId: proformaId,
        duplicateFromId: duplicateFromId,
      ),
    );
  }
}
