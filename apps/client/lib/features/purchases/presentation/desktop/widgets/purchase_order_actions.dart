import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum PurchaseOrderMenuAction {
  viewEdit,
  convertToBill,
  paymentHistory,
  delete,
  duplicate,
  openPdf,
  previewPrint,
  viewHistory,
}

String purchaseOrderMenuActionLabel(PurchaseOrderMenuAction action) {
  return switch (action) {
    PurchaseOrderMenuAction.viewEdit => 'View/Edit',
    PurchaseOrderMenuAction.convertToBill => 'Convert to Bill',
    PurchaseOrderMenuAction.paymentHistory => 'Payment History',
    PurchaseOrderMenuAction.delete => 'Delete',
    PurchaseOrderMenuAction.duplicate => 'Duplicate',
    PurchaseOrderMenuAction.openPdf => 'Open PDF',
    PurchaseOrderMenuAction.previewPrint => 'Preview Print',
    PurchaseOrderMenuAction.viewHistory => 'View History',
  };
}

List<PurchaseOrderMenuAction> purchaseOrderMenuActionsFor(
  PurchaseOrderModel order,
) {
  return PurchaseOrderMenuAction.values;
}

Future<void> handlePurchaseOrderMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required PurchaseOrderMenuAction action,
  required PurchaseOrderModel order,
}) async {
  switch (action) {
    case PurchaseOrderMenuAction.viewEdit:
      await context.push('${AppRoutes.editPurchaseOrder}/${order.id}');
    case PurchaseOrderMenuAction.convertToBill:
      await _convertToBill(context, ref, order);
    case PurchaseOrderMenuAction.paymentHistory:
      await _showPaymentHistory(context, ref, order);
    case PurchaseOrderMenuAction.delete:
      await _confirmDelete(context, ref, order);
    case PurchaseOrderMenuAction.duplicate:
      await _duplicateOrder(context, ref, order);
    case PurchaseOrderMenuAction.openPdf:
      await DocumentPrintActions.save(
        context,
        ref,
        PrintRequest.purchaseOrder(order.id),
        filename: DocumentPrintActions.filenameFor(order.orderNo),
      );
    case PurchaseOrderMenuAction.previewPrint:
      await DocumentPrintActions.preview(
        context,
        ref,
        PrintRequest.purchaseOrder(order.id),
        filename: DocumentPrintActions.filenameFor(order.orderNo),
      );
    case PurchaseOrderMenuAction.viewHistory:
      await _showViewHistory(context, ref, order);
  }
}

Future<void> _convertToBill(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrderModel order,
) async {
  if (order.isDraft || order.status == PurchaseOrderStatus.cancelled) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only finalized orders can be converted to a bill'),
      ),
    );
    return;
  }

  if (!order.canConvertToBill) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This purchase order cannot be converted to a bill'),
      ),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Convert to bill?'),
      content: Text(
        'Create a purchase bill from order ${order.orderNo}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Convert'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final result = await ref
      .read(purchaseOrdersProvider.notifier)
      .convertToBillWithId(order.id);

  if (!context.mounted) return;
  if (result.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
    return;
  }

  if (result.billId != null) {
    await context.push('${AppRoutes.editPurchase}/${result.billId}');
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Purchase order converted to bill')),
  );
}

Future<void> _duplicateOrder(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrderModel order,
) async {
  final result = await ref
      .read(purchaseOrdersProvider.notifier)
      .duplicateOrder(order.id);

  if (!context.mounted) return;
  if (result.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
    return;
  }

  if (result.newId != null) {
    await context.push('${AppRoutes.editPurchaseOrder}/${result.newId}');
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrderModel order,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(order.isDraft ? 'Delete draft?' : 'Cancel order?'),
      content: Text(
        order.isDraft
            ? 'Delete draft ${order.orderNo}? This cannot be undone.'
            : 'Cancel order ${order.orderNo}? This will mark the order as cancelled.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(order.isDraft ? 'Delete' : 'Cancel order'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final notifier = ref.read(purchaseOrdersProvider.notifier);
  final error = order.isDraft
      ? await notifier.deleteDraft(order.id)
      : await notifier.cancelOrder(order.id);

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

Future<void> _showPaymentHistory(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrderModel order,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final entries = await service.fetchPaymentHistory(order.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseOrderPaymentHistoryDialog(
        order: order,
        entries: entries,
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(PurchaseErrorMapper.messageFor(error))),
    );
  }
}

Future<void> _showViewHistory(
  BuildContext context,
  WidgetRef ref,
  PurchaseOrderModel order,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final events = await service.fetchOrderHistory(order.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseOrderViewHistoryDialog(
        order: order,
        events: events,
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(PurchaseErrorMapper.messageFor(error))),
    );
  }
}

class _PurchaseOrderPaymentHistoryDialog extends StatelessWidget {
  const _PurchaseOrderPaymentHistoryDialog({
    required this.order,
    required this.entries,
  });

  final PurchaseOrderModel order;
  final List<PurchaseBillPaymentHistoryEntry> entries;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Payment History — ${order.orderNo}'),
      content: SizedBox(
        width: 480,
        child: entries.isEmpty
            ? const Text(
                'No payments recorded for this order.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _currencyFormat.format(entries[i].allocatedAmount),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${entries[i].paymentMode} · ${_dateFormat.format(entries[i].paymentDate)}'
                          '${entries[i].referenceNumber != null ? ' · Ref ${entries[i].referenceNumber}' : ''}',
                        ),
                        trailing: Text(
                          'Total ${_currencyFormat.format(entries[i].paymentAmount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PurchaseOrderViewHistoryDialog extends StatelessWidget {
  const _PurchaseOrderViewHistoryDialog({
    required this.order,
    required this.events,
  });

  final PurchaseOrderModel order;
  final List<PurchaseBillHistoryEvent> events;

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('View History — ${order.orderNo}'),
      content: SizedBox(
        width: 420,
        child: events.isEmpty
            ? const Text(
                'No history available.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < events.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.history,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(events[i].title),
                        subtitle: Text(
                          [
                            _dateFormat.format(events[i].timestamp),
                            if (events[i].subtitle != null) events[i].subtitle,
                          ].join('\n'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
