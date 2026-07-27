import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `sales_documents` and `sales_document_lines`.
class SalesDocumentSync {
  SalesDocumentSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityType,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    if (entityType == 'sales_documents') {
      await _applyDocumentChange(
        businessId: businessId,
        entityId: entityId,
        syncVersion: syncVersion,
        updatedAt: updatedAt,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        deviceId: deviceId,
        payload: payload,
      );
      return;
    }
    if (entityType == 'sales_document_lines') {
      await _applyLineChange(
        businessId: businessId,
        entityId: entityId,
        syncVersion: syncVersion,
        updatedAt: updatedAt,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        deviceId: deviceId,
        payload: payload,
      );
    }
  }

  Future<void> updateAckMeta({
    required String entityType,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) async {
    if (entityType == 'sales_documents') {
      await (_db.update(_db.salesDocumentsLocal)
            ..where((t) => t.id.equals(entityId)))
          .write(
        SalesDocumentsLocalCompanion(
          syncVersion: Value(syncVersion),
          updatedAt: Value(updatedAt.toUtc()),
          deviceId: Value(deviceId),
        ),
      );
      return;
    }
    if (entityType == 'sales_document_lines') {
      await (_db.update(_db.salesDocumentLinesLocal)
            ..where((t) => t.id.equals(entityId)))
          .write(
        SalesDocumentLinesLocalCompanion(
          syncVersion: Value(syncVersion),
          updatedAt: Value(updatedAt.toUtc()),
          deviceId: Value(deviceId),
        ),
      );
    }
  }

  Future<void> _applyDocumentChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.salesDocumentsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (isDeleted) {
      await _db.into(_db.salesDocumentsLocal).insertOnConflictUpdate(
            SalesDocumentsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              documentType: existing?.documentType ??
                  _str(payload, 'document_type') ??
                  'tax_invoice',
              documentSeries: existing?.documentSeries ??
                  _str(payload, 'document_series') ??
                  'INV',
              documentDate: existing?.documentDate ??
                  _str(payload, 'document_date') ??
                  updatedAt.toUtc().toIso8601String(),
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    await _db.into(_db.salesDocumentsLocal).insertOnConflictUpdate(
          SalesDocumentsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            documentType:
                _str(payload, 'document_type') ?? existing?.documentType ?? 'tax_invoice',
            status: Value(_str(payload, 'status') ?? existing?.status ?? 'draft'),
            documentNumber: Value(
              _str(payload, 'document_number') ?? existing?.documentNumber,
            ),
            documentSeries:
                _str(payload, 'document_series') ?? existing?.documentSeries ?? 'INV',
            partyId: Value(_str(payload, 'party_id') ?? existing?.partyId),
            isGstFormal: Value(
              payload?['is_gst_formal'] as bool? ?? existing?.isGstFormal ?? false,
            ),
            partyStateCode: Value(
              _str(payload, 'party_state_code') ?? existing?.partyStateCode,
            ),
            subtotal: Value(
              _str(payload, 'subtotal') ?? existing?.subtotal ?? '0',
            ),
            discountTotal: Value(
              _str(payload, 'discount_total') ?? existing?.discountTotal ?? '0',
            ),
            taxAmount: Value(
              _str(payload, 'tax_amount') ?? existing?.taxAmount ?? '0',
            ),
            totalAmount: Value(
              _str(payload, 'total_amount') ?? existing?.totalAmount ?? '0',
            ),
            paidAmount: Value(
              _str(payload, 'paid_amount') ?? existing?.paidAmount ?? '0',
            ),
            paymentMode: Value(
              _str(payload, 'payment_mode') ?? existing?.paymentMode,
            ),
            documentDate: _str(payload, 'document_date') ??
                existing?.documentDate ??
                updatedAt.toUtc().toIso8601String(),
            convertedFromId: Value(
              _str(payload, 'converted_from_id') ?? existing?.convertedFromId,
            ),
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> _applyLineChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.salesDocumentLinesLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (isDeleted) {
      await _db.into(_db.salesDocumentLinesLocal).insertOnConflictUpdate(
            SalesDocumentLinesLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              salesDocumentId: existing?.salesDocumentId ??
                  _str(payload, 'sales_document_id') ??
                  '',
              itemId: existing?.itemId ?? _str(payload, 'item_id') ?? '',
              quantity: existing?.quantity ?? _str(payload, 'quantity') ?? '0',
              unit: existing?.unit ?? _str(payload, 'unit') ?? 'NONE',
              unitPrice:
                  existing?.unitPrice ?? _str(payload, 'unit_price') ?? '0',
              lineTotal:
                  existing?.lineTotal ?? _str(payload, 'line_total') ?? '0',
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    await _db.into(_db.salesDocumentLinesLocal).insertOnConflictUpdate(
          SalesDocumentLinesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            salesDocumentId: _str(payload, 'sales_document_id') ??
                existing?.salesDocumentId ??
                '',
            itemId: _str(payload, 'item_id') ?? existing?.itemId ?? '',
            quantity: _str(payload, 'quantity') ?? existing?.quantity ?? '0',
            unit: _str(payload, 'unit') ?? existing?.unit ?? 'NONE',
            unitPrice: _str(payload, 'unit_price') ?? existing?.unitPrice ?? '0',
            marketPrice: Value(
              _str(payload, 'market_price') ?? existing?.marketPrice,
            ),
            discountAmount: Value(
              _str(payload, 'discount_amount') ?? existing?.discountAmount ?? '0',
            ),
            taxType: Value(_str(payload, 'tax_type') ?? existing?.taxType ?? 'none'),
            taxRate: Value(_str(payload, 'tax_rate') ?? existing?.taxRate ?? '0'),
            cgstAmount: Value(
              _str(payload, 'cgst_amount') ?? existing?.cgstAmount ?? '0',
            ),
            sgstAmount: Value(
              _str(payload, 'sgst_amount') ?? existing?.sgstAmount ?? '0',
            ),
            igstAmount: Value(
              _str(payload, 'igst_amount') ?? existing?.igstAmount ?? '0',
            ),
            lineTotal: _str(payload, 'line_total') ?? existing?.lineTotal ?? '0',
            sortOrder: Value(
              (payload?['sort_order'] as num?)?.toInt() ?? existing?.sortOrder ?? 0,
            ),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            deviceId: Value(deviceId),
          ),
        );
  }

  String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    return value?.toString();
  }
}
