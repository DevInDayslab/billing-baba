import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/settings/data/business_settings_local_source.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _settingsEntity = 'business_settings';

/// Local-first business settings writes + SyncQueue enqueue.
class BusinessSettingsMasterRepository {
  BusinessSettingsMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final BusinessSettingsLocalSource _local;
  final SyncQueue _syncQueue;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  BusinessSettingsLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for settings operations');
    }
    return id;
  }

  Future<BusinessSettingsDto?> getForBusiness() async {
    final row = await _local.getByBusinessId(_requireBusinessId());
    if (row == null || row.isDeleted) return null;
    return _local.getActiveDto(row.id);
  }

  /// Creates settings row if missing, otherwise updates.
  Future<BusinessSettingsDto> upsert(
    UpdateBusinessSettingsRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getByBusinessId(businessId);
    final now = DateTime.now().toUtc();

    if (existing == null || existing.isDeleted) {
      final id = _uuid.v4();
      final valuationMethod = request.valuationMethod ?? 'average';
      final defaultTaxType = request.defaultTaxType ?? 'none';
      final invoiceTerms = request.clearInvoiceTerms
          ? null
          : request.invoiceTerms;
      final enableAlerts = request.enablePriceConflictAlerts ?? true;
      final creditLimitAction = request.creditLimitAction ?? 'warn';
      final labelsJson = BusinessSettingsLocalSource.encodeLabels(
        request.pricingTierLabels,
      );
      final taxRate = request.clearDefaultInvoiceTaxRate
          ? null
          : request.defaultInvoiceTaxRate;
      await _local.upsertRow(
        id: id,
        businessId: businessId,
        valuationMethod: valuationMethod,
        defaultTaxType: defaultTaxType,
        invoiceTerms: invoiceTerms,
        enablePriceConflictAlerts: enableAlerts,
        creditLimitAction: creditLimitAction,
        pricingTierLabels: labelsJson,
        defaultInvoiceTaxRate: taxRate,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _settingsEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: _payload(
          valuationMethod: valuationMethod,
          defaultTaxType: defaultTaxType,
          invoiceTerms: invoiceTerms,
          enablePriceConflictAlerts: enableAlerts,
          creditLimitAction: creditLimitAction,
          pricingTierLabels: request.pricingTierLabels,
          defaultInvoiceTaxRate: taxRate,
        ),
        clientUpdatedAt: now,
      );
      return (await _local.getActiveDto(id))!;
    }

    final valuationMethod = request.valuationMethod ?? existing.valuationMethod;
    final defaultTaxType = request.defaultTaxType ?? existing.defaultTaxType;
    final invoiceTerms = request.clearInvoiceTerms
        ? null
        : (request.invoiceTerms ?? existing.invoiceTerms);
    final enableAlerts =
        request.enablePriceConflictAlerts ?? existing.enablePriceConflictAlerts;
    final creditLimitAction =
        request.creditLimitAction ?? existing.creditLimitAction;
    final labelsJson = request.pricingTierLabels != null
        ? BusinessSettingsLocalSource.encodeLabels(request.pricingTierLabels)
        : existing.pricingTierLabels;
    final taxRate = request.clearDefaultInvoiceTaxRate
        ? null
        : (request.defaultInvoiceTaxRate ?? existing.defaultInvoiceTaxRate);

    await _local.upsertRow(
      id: existing.id,
      businessId: businessId,
      valuationMethod: valuationMethod,
      defaultTaxType: defaultTaxType,
      invoiceTerms: invoiceTerms,
      enablePriceConflictAlerts: enableAlerts,
      creditLimitAction: creditLimitAction,
      pricingTierLabels: labelsJson,
      defaultInvoiceTaxRate: taxRate,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _settingsEntity,
      entityId: existing.id,
      operation: SyncQueueOperation.update,
      payload: _payload(
        valuationMethod: valuationMethod,
        defaultTaxType: defaultTaxType,
        invoiceTerms: invoiceTerms,
        enablePriceConflictAlerts: enableAlerts,
        creditLimitAction: creditLimitAction,
        pricingTierLabels:
            request.pricingTierLabels ??
            (await _local.getActiveDto(existing.id))?.pricingTierLabels,
        defaultInvoiceTaxRate: taxRate,
      ),
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDto(existing.id))!;
  }

  Future<void> softDelete(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) return;
    final now = DateTime.now().toUtc();
    await _local.softDelete(id: id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _settingsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  static Map<String, dynamic> _payload({
    required String valuationMethod,
    required String defaultTaxType,
    required bool enablePriceConflictAlerts,
    required String creditLimitAction,
    String? invoiceTerms,
    Map<String, String>? pricingTierLabels,
    String? defaultInvoiceTaxRate,
  }) {
    return {
      'valuation_method': valuationMethod,
      'default_tax_type': defaultTaxType,
      'invoice_terms': invoiceTerms,
      'enable_price_conflict_alerts': enablePriceConflictAlerts,
      'credit_limit_action': creditLimitAction,
      'pricing_tier_labels': pricingTierLabels,
      'default_invoice_tax_rate': defaultInvoiceTaxRate,
    };
  }
}
