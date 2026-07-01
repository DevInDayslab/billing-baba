import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_document_form.dart';
import 'package:flutter/material.dart';

class EstimateQuotationPage extends StatelessWidget {
  const EstimateQuotationPage({super.key});

  static const _accentColor = Color(0xFF7B1FA2);
  static const _circleColor = Color(0xFFEDE7F6);
  static const _squareColor = Color(0xFFB39DDB);

  @override
  Widget build(BuildContext context) {
    return const SaleDocumentForm(
      documentType: SaleDocumentType.estimate,
      route: AppRoutes.saleEstimateQuotation,
      pageTitle: 'Estimate/Quotation',
      accentColor: _accentColor,
      illustrationCircleColor: _circleColor,
      illustrationSquareColor: _squareColor,
      emptyStateDescription:
          'Create estimates and quotations for your clients.',
      createButtonLabel: 'Create Estimate',
    );
  }
}
