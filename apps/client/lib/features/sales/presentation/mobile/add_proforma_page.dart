import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/mobile/mobile_add_sale_document_page.dart';
import 'package:flutter/material.dart';

class MobileAddProformaPage extends StatelessWidget {
  const MobileAddProformaPage({
    super.key,
    this.proformaId,
    this.duplicateFromId,
  });

  final String? proformaId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return MobileAddSaleDocumentPage(
      documentType: SaleDocumentType.proforma,
      listRoute: AppRoutes.saleProformaInvoice,
      documentId: proformaId,
      duplicateFromId: duplicateFromId,
    );
  }
}
