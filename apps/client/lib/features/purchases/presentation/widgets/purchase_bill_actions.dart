import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum PurchaseBillMenuAction {
  viewEdit,
  convertToReturn,
  paymentHistory,
  delete,
  duplicate,
  openPdf,
  previewPrint,
  viewHistory,
}

String purchaseBillMenuActionLabel(PurchaseBillMenuAction action) {
  return switch (action) {
    PurchaseBillMenuAction.viewEdit => 'View/Edit',
    PurchaseBillMenuAction.convertToReturn => 'Convert to Return',
    PurchaseBillMenuAction.paymentHistory => 'Payment History',
    PurchaseBillMenuAction.delete => 'Delete',
    PurchaseBillMenuAction.duplicate => 'Duplicate',
    PurchaseBillMenuAction.openPdf => 'Open PDF',
    PurchaseBillMenuAction.previewPrint => 'Preview Print',
    PurchaseBillMenuAction.viewHistory => 'View History',
  };
}

List<PurchaseBillMenuAction> purchaseBillMenuActionsFor(PurchaseBillModel bill) {
  return PurchaseBillMenuAction.values;
}

Future<void> handlePurchaseBillMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required PurchaseBillMenuAction action,
  required PurchaseBillModel bill,
}) async {
  switch (action) {
    case PurchaseBillMenuAction.viewEdit:
      await context.push('${AppRoutes.editPurchase}/${bill.id}');
    case PurchaseBillMenuAction.convertToReturn:
      await _convertToReturn(context, ref, bill);
    case PurchaseBillMenuAction.paymentHistory:
      await _showPaymentHistory(context, ref, bill);
    case PurchaseBillMenuAction.delete:
      await _confirmDelete(context, ref, bill);
    case PurchaseBillMenuAction.duplicate:
      await _duplicateBill(context, ref, bill);
    case PurchaseBillMenuAction.openPdf:
      await DocumentPrintActions.save(
        context,
        ref,
        PrintRequest.purchaseBill(bill.id),
        filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
      );
    case PurchaseBillMenuAction.previewPrint:
      await DocumentPrintActions.preview(
        context,
        ref,
        PrintRequest.purchaseBill(bill.id),
        filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
      );
    case PurchaseBillMenuAction.viewHistory:
      await _showViewHistory(context, ref, bill);
  }
}

Future<void> _convertToReturn(
  BuildContext context,
  WidgetRef ref,
  PurchaseBillModel bill,
) async {
  if (bill.isDraft || bill.status == PurchaseBillStatus.cancelled) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only finalized bills can be converted to a return'),
      ),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Convert to return?'),
      content: Text(
        'Create a debit note draft from bill ${bill.invoiceNo}?',
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

  final error = await ref
      .read(purchaseBillsProvider.notifier)
      .convertToReturn(bill.id);

  if (!context.mounted) return;
  if (error.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.error!)),
    );
    return;
  }

  if (error.returnId != null) {
    await context.push('${AppRoutes.editDebitNote}/${error.returnId}');
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Converted to debit note draft')),
  );
}

Future<void> _duplicateBill(
  BuildContext context,
  WidgetRef ref,
  PurchaseBillModel bill,
) async {
  final result = await ref
      .read(purchaseBillsProvider.notifier)
      .duplicateBill(bill.id);

  if (!context.mounted) return;
  if (result.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
    return;
  }

  if (result.newId != null) {
    await context.push('${AppRoutes.editPurchase}/${result.newId}');
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PurchaseBillModel bill,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(bill.isDraft ? 'Delete draft?' : 'Cancel bill?'),
      content: Text(
        bill.isDraft
            ? 'Delete draft ${bill.invoiceNo}? This cannot be undone.'
            : 'Cancel bill ${bill.invoiceNo}? This will mark the bill as cancelled.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(bill.isDraft ? 'Delete' : 'Cancel bill'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final notifier = ref.read(purchaseBillsProvider.notifier);
  final error = bill.isDraft
      ? await notifier.deleteDraft(bill.id)
      : await notifier.cancelBill(bill.id);

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

Future<void> _showPaymentHistory(
  BuildContext context,
  WidgetRef ref,
  PurchaseBillModel bill,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final entries = await service.fetchPaymentHistory(bill.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseBillPaymentHistoryDialog(
        bill: bill,
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
  PurchaseBillModel bill,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final events = await service.fetchBillHistory(bill.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseBillViewHistoryDialog(
        bill: bill,
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

class _PurchaseBillPaymentHistoryDialog extends StatelessWidget {
  const _PurchaseBillPaymentHistoryDialog({
    required this.bill,
    required this.entries,
  });

  final PurchaseBillModel bill;
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
      title: Text('Payment History — ${bill.invoiceNo}'),
      content: SizedBox(
        width: 480,
        child: entries.isEmpty
            ? const Text(
                'No payments recorded for this bill.',
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

class _PurchaseBillViewHistoryDialog extends StatelessWidget {
  const _PurchaseBillViewHistoryDialog({
    required this.bill,
    required this.events,
  });

  final PurchaseBillModel bill;
  final List<PurchaseBillHistoryEvent> events;

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('View History — ${bill.invoiceNo}'),
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
