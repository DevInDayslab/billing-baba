import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum PurchaseFaMenuAction {
  viewEdit,
  paymentHistory,
  delete,
  duplicate,
  openPdf,
  previewPrint,
  viewHistory,
}

String purchaseFaMenuActionLabel(PurchaseFaMenuAction action) {
  return switch (action) {
    PurchaseFaMenuAction.viewEdit => 'View/Edit',
    PurchaseFaMenuAction.paymentHistory => 'Payment History',
    PurchaseFaMenuAction.delete => 'Delete',
    PurchaseFaMenuAction.duplicate => 'Duplicate',
    PurchaseFaMenuAction.openPdf => 'Open PDF',
    PurchaseFaMenuAction.previewPrint => 'Preview Print',
    PurchaseFaMenuAction.viewHistory => 'View History',
  };
}

List<PurchaseFaMenuAction> purchaseFaMenuActionsFor(PurchaseFaModel record) {
  return PurchaseFaMenuAction.values;
}

Future<void> handlePurchaseFaMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required PurchaseFaMenuAction action,
  required PurchaseFaModel record,
}) async {
  switch (action) {
    case PurchaseFaMenuAction.viewEdit:
      await context.push('${AppRoutes.editPurchaseFa}/${record.batchId}');
    case PurchaseFaMenuAction.paymentHistory:
      await _showPaymentHistory(context, ref, record);
    case PurchaseFaMenuAction.delete:
      await _confirmDelete(context, ref, record);
    case PurchaseFaMenuAction.duplicate:
      await _duplicateRecord(context, ref, record);
    case PurchaseFaMenuAction.openPdf:
      await DocumentPrintActions.save(
        context,
        ref,
        PrintRequest.fixedAssetPurchase(record.batchId),
        filename: VoucherPrintActions.filenameFor(record.invoiceNo),
      );
    case PurchaseFaMenuAction.previewPrint:
      await VoucherPrintActions.previewFixedAssetPurchase(
        context,
        ref,
        record.batchId,
        filename: VoucherPrintActions.filenameFor(record.invoiceNo),
      );
    case PurchaseFaMenuAction.viewHistory:
      await _showViewHistory(context, ref, record);
  }
}

Future<void> _duplicateRecord(
  BuildContext context,
  WidgetRef ref,
  PurchaseFaModel record,
) async {
  final result = await ref
      .read(purchaseFaProvider.notifier)
      .duplicateRecord(record.batchId);

  if (!context.mounted) return;
  if (result.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
    return;
  }

  if (result.newId != null) {
    await context.push('${AppRoutes.editPurchaseFa}/${result.newId}');
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PurchaseFaModel record,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete purchase?'),
      content: Text(
        'Delete ${record.invoiceNo.isNotEmpty ? record.invoiceNo : record.partyName}? This cannot be undone.',
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

  final error = await ref
      .read(purchaseFaProvider.notifier)
      .deleteBatch(record.batchId);

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

Future<void> _showPaymentHistory(
  BuildContext context,
  WidgetRef ref,
  PurchaseFaModel record,
) async {
  try {
    final service = await ref.read(purchaseServiceProvider.future);
    final entries = await service.fetchPaymentHistory(record.batchId);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseFaPaymentHistoryDialog(
        record: record,
        entries: entries,
        onLinkPayment: () async {
          Navigator.of(context).pop();
          await showPaymentOutDialog(
            context,
            initialPartyId: record.partyId,
            initialPartyName: record.partyName,
          );
        },
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
  PurchaseFaModel record,
) async {
  try {
    final service = await ref.read(purchaseFaServiceProvider.future);
    final events = await service.fetchBatchHistory(record.batchId);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _PurchaseFaViewHistoryDialog(
        record: record,
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

class _PurchaseFaPaymentHistoryDialog extends StatelessWidget {
  const _PurchaseFaPaymentHistoryDialog({
    required this.record,
    required this.entries,
    required this.onLinkPayment,
  });

  final PurchaseFaModel record;
  final List<PurchaseBillPaymentHistoryEntry> entries;
  final VoidCallback onLinkPayment;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Payment History — ${record.invoiceNo}'),
      content: SizedBox(
        width: 480,
        child: entries.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No payments recorded for this purchase.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: onLinkPayment,
                    child: const Text('Link Payment'),
                  ),
                ],
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

class _PurchaseFaViewHistoryDialog extends StatelessWidget {
  const _PurchaseFaViewHistoryDialog({
    required this.record,
    required this.events,
  });

  final PurchaseFaModel record;
  final List<PurchaseFaHistoryEvent> events;

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('View History — ${record.invoiceNo}'),
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
