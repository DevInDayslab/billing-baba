import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum PurchaseReturnMenuAction {
  viewEdit,
  paymentHistory,
  delete,
  duplicate,
  openPdf,
  previewPrint,
  viewHistory,
}

String purchaseReturnMenuActionLabel(PurchaseReturnMenuAction action) {
  return switch (action) {
    PurchaseReturnMenuAction.viewEdit => 'View/Edit',
    PurchaseReturnMenuAction.paymentHistory => 'Payment History',
    PurchaseReturnMenuAction.delete => 'Delete',
    PurchaseReturnMenuAction.duplicate => 'Duplicate',
    PurchaseReturnMenuAction.openPdf => 'Open PDF',
    PurchaseReturnMenuAction.previewPrint => 'Preview Print',
    PurchaseReturnMenuAction.viewHistory => 'View History',
  };
}

List<PurchaseReturnMenuAction> purchaseReturnMenuActionsFor(
  PurchaseReturnModel item,
) {
  return PurchaseReturnMenuAction.values;
}

Future<void> handlePurchaseReturnMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required PurchaseReturnMenuAction action,
  required PurchaseReturnModel item,
}) async {
  switch (action) {
    case PurchaseReturnMenuAction.viewEdit:
      await context.push('${AppRoutes.editDebitNote}/${item.id}');
    case PurchaseReturnMenuAction.paymentHistory:
      await _showPaymentHistory(context, ref, item);
    case PurchaseReturnMenuAction.delete:
      await _confirmDelete(context, ref, item);
    case PurchaseReturnMenuAction.duplicate:
      await _duplicateReturn(context, ref, item);
    case PurchaseReturnMenuAction.openPdf:
      await DocumentPrintActions.save(
        context,
        ref,
        PrintRequest.debitNote(item.id),
        filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
      );
    case PurchaseReturnMenuAction.previewPrint:
      await DocumentPrintActions.preview(
        context,
        ref,
        PrintRequest.debitNote(item.id),
        filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
      );
    case PurchaseReturnMenuAction.viewHistory:
      await _showViewHistory(context, ref, item);
  }
}

Future<void> _duplicateReturn(
  BuildContext context,
  WidgetRef ref,
  PurchaseReturnModel item,
) async {
  final result = await ref
      .read(purchaseReturnsProvider.notifier)
      .duplicateReturn(item.id);

  if (!context.mounted) return;
  if (result.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
    return;
  }

  if (result.newId != null) {
    await context.push('${AppRoutes.editDebitNote}/${result.newId}');
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PurchaseReturnModel item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(item.isDraft ? 'Delete draft?' : 'Cancel debit note?'),
      content: Text(
        item.isDraft
            ? 'Delete draft ${item.debitNoteNo}? This cannot be undone.'
            : 'Cancel debit note ${item.debitNoteNo}? This will mark it as cancelled.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(item.isDraft ? 'Delete' : 'Cancel debit note'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final notifier = ref.read(purchaseReturnsProvider.notifier);
  final error = item.isDraft
      ? await notifier.deleteDraft(item.id)
      : await notifier.cancelReturn(item.id);

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

Future<void> _showPaymentHistory(
  BuildContext context,
  WidgetRef ref,
  PurchaseReturnModel item,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final entries = await service.fetchPaymentHistory(item.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseReturnPaymentHistoryDialog(
        item: item,
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
  PurchaseReturnModel item,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final events = await service.fetchReturnHistory(item.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseReturnViewHistoryDialog(
        item: item,
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

class _PurchaseReturnPaymentHistoryDialog extends StatelessWidget {
  const _PurchaseReturnPaymentHistoryDialog({
    required this.item,
    required this.entries,
  });

  final PurchaseReturnModel item;
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
      title: Text('Payment History — ${item.debitNoteNo}'),
      content: SizedBox(
        width: 480,
        child: entries.isEmpty
            ? const Text(
                'No payments recorded for this debit note.',
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

class _PurchaseReturnViewHistoryDialog extends StatelessWidget {
  const _PurchaseReturnViewHistoryDialog({
    required this.item,
    required this.events,
  });

  final PurchaseReturnModel item;
  final List<PurchaseBillHistoryEvent> events;

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('View History — ${item.debitNoteNo}'),
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
