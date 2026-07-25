import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_order_form_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SalesDocumentMenuAction {
  view,
  edit,
  duplicate,
  delete,
  convertToSaleOrder,
  convertToDeliveryChallan,
  convertToInvoice,
}

class SalesDocumentTableConfig {
  const SalesDocumentTableConfig({
    required this.scope,
    required this.emptyMessage,
    required this.searchTitle,
    required this.searchHint,
    required this.actions,
    this.documentType,
    this.onView,
    this.onEdit,
    this.onDuplicate,
  });

  final SalesDocumentListScope scope;
  final String emptyMessage;
  final String searchTitle;
  final String searchHint;
  final List<SalesDocumentMenuAction> actions;
  final SaleDocumentType? documentType;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel document,
  )?
  onView;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel document,
  )?
  onEdit;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel document,
  )?
  onDuplicate;
}

SalesDocumentTableConfig estimateTableConfig() => SalesDocumentTableConfig(
  scope: estimateListScope(),
  emptyMessage: 'No estimates found',
  searchTitle: 'Search estimates',
  searchHint: 'Document no, party...',
  documentType: SaleDocumentType.estimate,
  actions: const [
    SalesDocumentMenuAction.view,
    SalesDocumentMenuAction.edit,
    SalesDocumentMenuAction.duplicate,
    SalesDocumentMenuAction.delete,
    SalesDocumentMenuAction.convertToSaleOrder,
    SalesDocumentMenuAction.convertToInvoice,
  ],
);

SalesDocumentTableConfig proformaTableConfig() => SalesDocumentTableConfig(
  scope: proformaListScope(),
  emptyMessage: 'No proforma invoices found',
  searchTitle: 'Search proforma invoices',
  searchHint: 'Document no, party...',
  documentType: SaleDocumentType.proforma,
  actions: const [
    SalesDocumentMenuAction.view,
    SalesDocumentMenuAction.edit,
    SalesDocumentMenuAction.duplicate,
    SalesDocumentMenuAction.delete,
    SalesDocumentMenuAction.convertToInvoice,
  ],
);

SalesDocumentTableConfig saleOrderTableConfig() => SalesDocumentTableConfig(
  scope: saleOrderListScope(),
  emptyMessage: 'No sale orders found',
  searchTitle: 'Search sale orders',
  searchHint: 'Order no, party...',
  actions: const [
    SalesDocumentMenuAction.view,
    SalesDocumentMenuAction.edit,
    SalesDocumentMenuAction.delete,
    SalesDocumentMenuAction.convertToDeliveryChallan,
    SalesDocumentMenuAction.convertToInvoice,
  ],
);

SalesDocumentTableConfig deliveryChallanTableConfig() =>
    SalesDocumentTableConfig(
      scope: deliveryChallanListScope(),
      emptyMessage: 'No delivery challans found',
      searchTitle: 'Search delivery challans',
      searchHint: 'Challan no, party...',
      actions: const [
        SalesDocumentMenuAction.view,
        SalesDocumentMenuAction.edit,
        SalesDocumentMenuAction.delete,
        SalesDocumentMenuAction.convertToInvoice,
      ],
    );

Future<void> handleSalesDocumentMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required SalesDocumentTableConfig config,
  required SalesDocumentMenuAction action,
  required SaleInvoiceModel document,
}) async {
  final listNotifier = ref.read(
    salesDocumentsListProvider(config.scope).notifier,
  );

  switch (action) {
    case SalesDocumentMenuAction.view:
      if (config.onView != null) {
        await config.onView!(context, ref, document);
        return;
      }
      await _defaultView(context, ref, config, document);
    case SalesDocumentMenuAction.edit:
      if (config.onEdit != null) {
        await config.onEdit!(context, ref, document);
        return;
      }
      await _defaultEdit(context, ref, config, document);
    case SalesDocumentMenuAction.duplicate:
      if (config.onDuplicate != null) {
        await config.onDuplicate!(context, ref, document);
        return;
      }
      await _defaultDuplicate(context, ref, config, document);
    case SalesDocumentMenuAction.delete:
      await _confirmDelete(context, ref, listNotifier, document);
    case SalesDocumentMenuAction.convertToSaleOrder:
      await _convertDocument(
        context,
        ref,
        listNotifier,
        document,
        targetType: 'sale_order',
        successMessage: 'Converted to sale order',
      );
    case SalesDocumentMenuAction.convertToDeliveryChallan:
      await _convertDocument(
        context,
        ref,
        listNotifier,
        document,
        targetType: 'delivery_challan',
        successMessage: 'Converted to delivery challan',
      );
    case SalesDocumentMenuAction.convertToInvoice:
      await _convertDocument(
        context,
        ref,
        listNotifier,
        document,
        targetType: 'tax_invoice',
        successMessage: 'Converted to invoice',
      );
  }
}

Future<void> _defaultView(
  BuildContext context,
  WidgetRef ref,
  SalesDocumentTableConfig config,
  SaleInvoiceModel document,
) async {
  if (config.documentType != null) {
    final notifier = ref.read(
      saleDocumentFormProvider(config.documentType!).notifier,
    );
    await notifier.loadDocument(document.id);
    return;
  }

  if (config.scope.documentType == SalesDocumentType.saleOrder) {
    await ref.read(saleOrderFormProvider().notifier).loadDocument(document.id);
    return;
  }

  if (config.scope.documentType == SalesDocumentType.deliveryChallan) {
    await ref
        .read(deliveryChallanFormProvider.notifier)
        .loadDocument(document.id);
  }
}

Future<void> _defaultEdit(
  BuildContext context,
  WidgetRef ref,
  SalesDocumentTableConfig config,
  SaleInvoiceModel document,
) async {
  if (!document.isDraft) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Only draft documents can be edited')),
    );
    return;
  }
  await _defaultView(context, ref, config, document);
}

Future<void> _defaultDuplicate(
  BuildContext context,
  WidgetRef ref,
  SalesDocumentTableConfig config,
  SaleInvoiceModel document,
) async {
  if (config.documentType != null) {
    final notifier = ref.read(
      saleDocumentFormProvider(config.documentType!).notifier,
    );
    await notifier.duplicateDocument(document.id);
    return;
  }

  if (config.scope.documentType == SalesDocumentType.saleOrder) {
    await ref
        .read(saleOrderFormProvider().notifier)
        .duplicateDocument(document.id);
    return;
  }

  if (config.scope.documentType == SalesDocumentType.deliveryChallan) {
    await ref
        .read(deliveryChallanFormProvider.notifier)
        .duplicateDocument(
          document.id,
        );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  SalesDocumentsList listNotifier,
  SaleInvoiceModel document,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete document?'),
      content: const Text(
        'This document will be permanently deleted.\n'
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final error = document.isDraft
      ? await listNotifier.deleteDraft(document.id)
      : await listNotifier.cancelDocument(document.id);

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

Future<void> _convertDocument(
  BuildContext context,
  WidgetRef ref,
  SalesDocumentsList listNotifier,
  SaleInvoiceModel document, {
  required String targetType,
  required String successMessage,
}) async {
  final error = await listNotifier.convertDocument(
    document.id,
    targetType: targetType,
  );
  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(successMessage)),
  );
}

String salesDocumentMenuActionLabel(SalesDocumentMenuAction action) {
  return switch (action) {
    SalesDocumentMenuAction.view => 'View',
    SalesDocumentMenuAction.edit => 'Edit',
    SalesDocumentMenuAction.duplicate => 'Duplicate',
    SalesDocumentMenuAction.delete => 'Delete',
    SalesDocumentMenuAction.convertToSaleOrder => 'Convert to Sale Order',
    SalesDocumentMenuAction.convertToDeliveryChallan =>
      'Convert to Delivery Challan',
    SalesDocumentMenuAction.convertToInvoice => 'Convert to Invoice',
  };
}

PrintRequest salesDocumentPrintRequest(
  SalesDocumentTableConfig config,
  String documentId,
) {
  final formType = config.documentType;
  if (formType == SaleDocumentType.estimate) {
    return PrintRequest.estimate(documentId);
  }
  if (formType == SaleDocumentType.proforma) {
    return PrintRequest.proformaInvoice(documentId);
  }

  return switch (config.scope.documentType) {
    SalesDocumentType.saleOrder => PrintRequest.saleOrder(documentId),
    SalesDocumentType.deliveryChallan => PrintRequest.deliveryChallan(
      documentId,
    ),
    SalesDocumentType.estimate => PrintRequest.estimate(documentId),
    _ => PrintRequest.saleInvoice(documentId),
  };
}
