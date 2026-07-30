import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

class BusinessSettingsDto {
  const BusinessSettingsDto({
    required this.id,
    required this.valuationMethod,
    required this.defaultTaxType,
    required this.enablePriceConflictAlerts,
    required this.creditLimitAction,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceTerms,
    this.pricingTierLabels,
    this.defaultInvoiceTaxRate,
  });

  final String id;
  final String valuationMethod;
  final String defaultTaxType;
  final String? invoiceTerms;
  final bool enablePriceConflictAlerts;
  final String creditLimitAction;
  final Map<String, String>? pricingTierLabels;
  final String? defaultInvoiceTaxRate;
  final String createdAt;
  final String updatedAt;
}

class UpdateBusinessSettingsRequest {
  const UpdateBusinessSettingsRequest({
    this.valuationMethod,
    this.defaultTaxType,
    this.invoiceTerms,
    this.enablePriceConflictAlerts,
    this.creditLimitAction,
    this.pricingTierLabels,
    this.defaultInvoiceTaxRate,
    this.clearDefaultInvoiceTaxRate = false,
    this.clearInvoiceTerms = false,
  });

  final String? valuationMethod;
  final String? defaultTaxType;
  final String? invoiceTerms;
  final bool? enablePriceConflictAlerts;
  final String? creditLimitAction;
  final Map<String, String>? pricingTierLabels;
  final String? defaultInvoiceTaxRate;
  final bool clearDefaultInvoiceTaxRate;
  final bool clearInvoiceTerms;
}

/// Drift-backed local store for business settings. Does not enqueue SyncJobs.
class BusinessSettingsLocalSource {
  BusinessSettingsLocalSource(this._db);

  final AppDatabase _db;

  Future<BusinessSettingsTableData?> getByBusinessId(String businessId) {
    return (_db.select(_db.businessSettingsLocal)
          ..where(
            (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<BusinessSettingsTableData?> getById(String id) {
    return (_db.select(
      _db.businessSettingsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<BusinessSettingsDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String valuationMethod = 'average',
    String defaultTaxType = 'none',
    String? invoiceTerms,
    bool enablePriceConflictAlerts = true,
    String creditLimitAction = 'warn',
    String? pricingTierLabels,
    String? defaultInvoiceTaxRate,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.businessSettingsLocal)
        .insertOnConflictUpdate(
          BusinessSettingsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            valuationMethod: Value(valuationMethod),
            defaultTaxType: Value(defaultTaxType),
            invoiceTerms: Value(invoiceTerms),
            enablePriceConflictAlerts: Value(enablePriceConflictAlerts),
            creditLimitAction: Value(creditLimitAction),
            pricingTierLabels: Value(pricingTierLabels),
            defaultInvoiceTaxRate: Value(defaultInvoiceTaxRate),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(
      _db.businessSettingsLocal,
    )..where((t) => t.id.equals(id))).write(
      BusinessSettingsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  BusinessSettingsDto _toDto(BusinessSettingsTableData row) {
    Map<String, String>? labels;
    final raw = row.pricingTierLabels;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          labels = {
            for (final e in decoded.entries)
              if (e.key != null && e.value != null)
                e.key.toString(): e.value.toString(),
          };
        }
      } on Object {
        labels = null;
      }
    }
    return BusinessSettingsDto(
      id: row.id,
      valuationMethod: row.valuationMethod,
      defaultTaxType: row.defaultTaxType,
      invoiceTerms: row.invoiceTerms,
      enablePriceConflictAlerts: row.enablePriceConflictAlerts,
      creditLimitAction: row.creditLimitAction,
      pricingTierLabels: labels,
      defaultInvoiceTaxRate: row.defaultInvoiceTaxRate,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }

  static String? encodeLabels(Map<String, String>? labels) {
    if (labels == null) return null;
    return jsonEncode(labels);
  }
}
