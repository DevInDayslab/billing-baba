import 'package:billing_baba/features/generated_documents/providers/generated_document_providers.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/providers/print_providers.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:billing_baba/features/settings/models/transaction_message_settings.dart';
import 'package:billing_baba/features/settings/providers/notifications_remote_provider.dart';
import 'package:billing_baba/features/settings/providers/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/providers/whatsapp_settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fire-and-forget WhatsApp notify helpers gated by local settings.
abstract final class WhatsAppAutoNotify {
  static Future<bool> _messagingAllowed(Ref ref) async {
    final wa = await ref.read(whatsAppSettingsProvider.future);
    if (!wa.enabled) return false;
    final txn = await ref.read(transactionMessageSettingsProvider.future);
    return txn.sendToParty;
  }

  static Future<TransactionMessageSettings?> _settingsIfAllowed(
    Ref ref,
  ) async {
    if (!await _messagingAllowed(ref)) return null;
    return ref.read(transactionMessageSettingsProvider.future);
  }

  static Future<NotificationsRemoteDataSource> _remote(Ref ref) =>
      ref.read(notificationsRemoteProvider.future);

  /// Uploads the in-app print layout so storage is not the server MVP PDF.
  static Future<void> ensureSaleInvoicePdfCached(
    Ref ref, {
    required String documentId,
  }) async {
    try {
      final printService = await ref.read(printServiceProvider.future);
      final generatedDocuments =
          await ref.read(generatedDocumentServiceProvider.future);
      final request = PrintRequest.saleInvoice(documentId);
      final bytes = await printService.generatePdf(request);
      await generatedDocuments.cacheForPrintRequest(
        request,
        bytes,
        fileName: 'invoice.pdf',
      );
    } on Object catch (e, st) {
      debugPrint('Sale invoice PDF cache failed: $e\n$st');
    }
  }

  /// After sale invoice finalize — cache professional PDF, then optional WA.
  static Future<void> afterSaleFinalize(
    Ref ref, {
    required String documentId,
  }) async {
    await ensureSaleInvoicePdfCached(ref, documentId: documentId);

    try {
      final settings = await _settingsIfAllowed(ref);
      if (settings == null) return;
      if (!settings.isAutoSendEnabled(TransactionMessageType.sale)) return;

      final remote = await _remote(ref);
      await remote.shareSalesDocument(documentId);
      await remote.notifySalesDocument(documentId);
    } on Object catch (e, st) {
      debugPrint('WhatsApp sale notify failed: $e\n$st');
    }
  }

  /// After Payment In create — if auto-send Payment In is on.
  static Future<void> afterPaymentIn(
    Ref ref, {
    required String paymentId,
  }) async {
    try {
      final settings = await _settingsIfAllowed(ref);
      if (settings == null) return;
      if (!settings.isAutoSendEnabled(TransactionMessageType.paymentIn)) {
        return;
      }

      final remote = await _remote(ref);
      await remote.notifyPaymentReceived(paymentId);
    } on Object catch (e, st) {
      debugPrint('WhatsApp payment-in notify failed: $e\n$st');
    }
  }
}
