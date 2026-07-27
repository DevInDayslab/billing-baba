import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: business_settings` into Drift.
class BusinessSettingsSync {
  BusinessSettingsSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.businessSettingsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (isDeleted) {
      await _db.into(_db.businessSettingsLocal).insertOnConflictUpdate(
            BusinessSettingsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              valuationMethod: Value(
                existing?.valuationMethod ??
                    _str(payload, 'valuation_method') ??
                    'average',
              ),
              defaultTaxType: Value(
                existing?.defaultTaxType ??
                    _str(payload, 'default_tax_type') ??
                    'none',
              ),
              invoiceTerms: Value(existing?.invoiceTerms),
              enablePriceConflictAlerts: Value(
                existing?.enablePriceConflictAlerts ?? true,
              ),
              creditLimitAction: Value(
                existing?.creditLimitAction ?? 'warn',
              ),
              pricingTierLabels: Value(existing?.pricingTierLabels),
              defaultInvoiceTaxRate: Value(existing?.defaultInvoiceTaxRate),
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

    await _db.into(_db.businessSettingsLocal).insertOnConflictUpdate(
          BusinessSettingsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            valuationMethod: Value(
              _str(payload, 'valuation_method') ??
                  existing?.valuationMethod ??
                  'average',
            ),
            defaultTaxType: Value(
              _str(payload, 'default_tax_type') ??
                  existing?.defaultTaxType ??
                  'none',
            ),
            invoiceTerms: Value(
              _str(payload, 'invoice_terms') ?? existing?.invoiceTerms,
            ),
            enablePriceConflictAlerts: Value(
              _bool(payload, 'enable_price_conflict_alerts') ??
                  existing?.enablePriceConflictAlerts ??
                  true,
            ),
            creditLimitAction: Value(
              _str(payload, 'credit_limit_action') ??
                  existing?.creditLimitAction ??
                  'warn',
            ),
            pricingTierLabels: Value(
              _labelsJson(payload) ?? existing?.pricingTierLabels,
            ),
            defaultInvoiceTaxRate: Value(
              _str(payload, 'default_invoice_tax_rate') ??
                  existing?.defaultInvoiceTaxRate,
            ),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.businessSettingsLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      BusinessSettingsLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    return value.toString();
  }

  static bool? _bool(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }

  static String? _labelsJson(Map<String, dynamic>? payload) {
    final value = payload?['pricing_tier_labels'];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return jsonEncode(value);
    }
    return null;
  }
}
