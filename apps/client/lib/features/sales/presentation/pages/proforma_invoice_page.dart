import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_document_form.dart';
import 'package:flutter/material.dart';

class ProformaInvoicePage extends StatelessWidget {
  const ProformaInvoicePage({super.key});

  static const _accentColor = Color(0xFFF57C00);
  static const _circleColor = Color(0xFFE3F2FD);
  static const _squareColor = Color(0xFFFFCCBC);

  @override
  Widget build(BuildContext context) {
    return const SaleDocumentForm(
      documentType: SaleDocumentType.proforma,
      route: AppRoutes.saleProformaInvoice,
      pageTitle: 'Proforma Invoice',
      accentColor: _accentColor,
      illustrationCircleColor: _circleColor,
      illustrationSquareColor: _squareColor,
      emptyStateDescription: 'Create estimates/proforma invoices easily.',
      createButtonLabel: 'Create Proforma Invoice',
    );
  }
}
