import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment-in local series key (no dedicated constant module yet).
const paymentInDocumentSeries = 'PIN';

/// Payment-out local series key.
const paymentOutDocumentSeries = 'POUT';

/// Expense local series key.
const expenseDocumentSeries = 'EXP';

/// Formats a series preview as `{prefix}{number}` (e.g. `INV1`).
String formatDocumentNumberPreview({
  required String prefix,
  required int nextNumber,
}) {
  final trimmed = prefix.trim();
  final safePrefix = trimmed.isEmpty ? 'DOC' : trimmed;
  final safeNumber = nextNumber < 1 ? 1 : nextNumber;
  return '$safePrefix$safeNumber';
}

/// Whether [currentNumber] is an unset auto placeholder on a new form.
bool isUnsetDocumentNumber(String? currentNumber) {
  final value = currentNumber?.trim() ?? '';
  return value.isEmpty || value == 'Auto';
}

/// Resolves what to show in a document-number field.
///
/// New forms (no [documentId]) always use the series [preview].
/// Existing documents show the assigned number when present.
String resolveDocumentNumberDisplay({
  required String? documentId,
  required String currentNumber,
  required String? preview,
  bool forceAuto = false,
}) {
  final assigned = currentNumber.trim();
  final hasDocument = documentId != null && documentId.trim().isNotEmpty;
  final usePreview =
      forceAuto ||
      !hasDocument ||
      isUnsetDocumentNumber(assigned);

  if (!usePreview && assigned.isNotEmpty) {
    return assigned;
  }

  final peek = preview?.trim() ?? '';
  if (peek.isNotEmpty) return peek;
  if (!isUnsetDocumentNumber(assigned) && assigned != '1') return assigned;
  return '…';
}

SaleTransactionPrefixType? prefixTypeForDocumentSeries(String documentSeries) {
  return switch (documentSeries) {
    SalesConstants.defaultDocumentSeries => SaleTransactionPrefixType.sale,
    SalesConstants.saleOrderSeries => SaleTransactionPrefixType.saleOrder,
    SalesConstants.estimateSeries => SaleTransactionPrefixType.estimate,
    SalesConstants.challanSeries => SaleTransactionPrefixType.deliveryChallan,
    SalesConstants.proformaSeries => SaleTransactionPrefixType.proformaInvoice,
    SalesConstants.creditNoteSeries => SaleTransactionPrefixType.creditNote,
    paymentInDocumentSeries => SaleTransactionPrefixType.paymentIn,
    PurchaseConstants.purchaseBillSeries => SaleTransactionPrefixType.purchase,
    PurchaseConstants.purchaseOrderSeries =>
      SaleTransactionPrefixType.purchaseOrder,
    PurchaseConstants.purchaseReturnSeries => SaleTransactionPrefixType.debitNote,
    paymentOutDocumentSeries => SaleTransactionPrefixType.paymentOut,
    expenseDocumentSeries => SaleTransactionPrefixType.expense,
    _ => null,
  };
}

String prefixForDocumentSeries(
  SaleInvoiceSettings? settings,
  String documentSeries,
) {
  final type = prefixTypeForDocumentSeries(documentSeries);
  if (type != null && settings != null) {
    return settings.prefixFor(type);
  }
  return documentSeries;
}

/// Peeks the next series number for a document series without allocating it.
final nextDocumentNumberPreviewProvider =
    FutureProvider.family<String, String>((ref, documentSeries) async {
      final businessId = ref.watch(currentBusinessProvider)?.id.trim() ?? '';
      final settings = ref.watch(saleInvoiceSettingsProvider).asData?.value;
      final prefix = prefixForDocumentSeries(settings, documentSeries);
      if (businessId.isEmpty) {
        return formatDocumentNumberPreview(prefix: prefix, nextNumber: 1);
      }

      final next = await ref
          .watch(localDocumentNumberServiceProvider)
          .peekNext(businessId: businessId, documentSeries: documentSeries);
      return formatDocumentNumberPreview(prefix: prefix, nextNumber: next);
    });

/// Sync helper for widgets: loading/error fall back safely.
String watchDocumentNumberPreview(WidgetRef ref, String documentSeries) {
  final settings = ref.watch(saleInvoiceSettingsProvider).asData?.value;
  final fallbackPrefix = prefixForDocumentSeries(settings, documentSeries);
  final asyncPreview = ref.watch(
    nextDocumentNumberPreviewProvider(documentSeries),
  );
  return asyncPreview.when(
    data: (String value) => value,
    loading: () => formatDocumentNumberPreview(
      prefix: fallbackPrefix,
      nextNumber: 1,
    ),
    error: (Object _, StackTrace _) => formatDocumentNumberPreview(
      prefix: fallbackPrefix,
      nextNumber: 1,
    ),
  );
}
