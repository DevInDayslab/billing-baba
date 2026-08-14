import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/mobile/mobile_add_sale_document_page.dart';
import 'package:flutter/material.dart';

class MobileAddEstimatePage extends StatelessWidget {
  const MobileAddEstimatePage({
    super.key,
    this.estimateId,
    this.duplicateFromId,
  });

  final String? estimateId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return MobileAddSaleDocumentPage(
      documentType: SaleDocumentType.estimate,
      listRoute: AppRoutes.saleEstimateQuotation,
      documentId: estimateId,
      duplicateFromId: duplicateFromId,
    );
  }
}
