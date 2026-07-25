import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/models/quick_create_action.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_dialog.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Launches a quick-create action (shared by menu clicks and keyboard shortcuts).
void executeQuickCreate(
  BuildContext context,
  WidgetRef ref,
  QuickCreateAction action,
) {
  switch (action.type) {
    case QuickCreateActionType.routePush:
      context.push(action.route!);
    case QuickCreateActionType.routeGo:
      context.go(action.route!);
    case QuickCreateActionType.paymentInDialog:
      showPaymentInDialog(context);
    case QuickCreateActionType.paymentOutDialog:
      showPaymentOutDialog(context);
    case QuickCreateActionType.proformaForm:
      context.go(AppRoutes.saleProformaInvoice);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(saleDocumentFormProvider(SaleDocumentType.proforma).notifier)
            .openForm();
      });
  }
}
