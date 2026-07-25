import 'package:billing_baba/core/constants/app_constants.dart';
import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Resolves a scanned barcode against business inventory and public product data.
class BarcodeLookupService {
  BarcodeLookupService({
    required this._repository,
    required this._remoteDataSource,
    Dio? openFoodFactsDio,
  })  : _openFoodFactsDio = openFoodFactsDio ?? Dio();

  final InventoryRepository _repository;
  final InventoryRemoteDataSource _remoteDataSource;
  final Dio _openFoodFactsDio;

  static const _openFoodFactsProductUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  Future<BarcodeLookupResult> lookup(String barcode) async {
    debugPrint('[BarcodeService] Looking up barcode: $barcode');

    final trimmed = barcode.trim();
    if (trimmed.isEmpty) {
      final result = BarcodeLookupResult.notFound();
      debugPrint(
        '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
      );
      return result;
    }

    var hadError = false;

    try {
      final inventoryResult = await _lookupInventory(trimmed);
      debugPrint(
        '[BarcodeService] Inventory result: ${inventoryResult?.name ?? "not found"}',
      );
      if (inventoryResult != null) {
        final result = await _enrichMissingCommercialFields(
          trimmed,
          BarcodeLookupResult.fromInventory(inventoryResult),
        );
        debugPrint(
          '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
        );
        return result;
      }
    } catch (error, stackTrace) {
      _logLookupError('Inventory barcode lookup failed', error, stackTrace);
    }

    if (!BarcodeConfidence.isEligibleForExternalLookup(trimmed)) {
      debugPrint(
        '[BarcodeService] Skipping external lookup: barcode failed GTIN confidence check',
      );
      final result = BarcodeLookupResult.notFound(hadError: hadError);
      debugPrint(
        '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
      );
      return result;
    }

    debugPrint('[BarcodeService] Trying Open Food Facts...');

    try {
      final openFoodFactsMatch = await _lookupOpenFoodFacts(trimmed);
      if (openFoodFactsMatch != null) {
        final result = await _enrichMissingCommercialFields(
          trimmed,
          openFoodFactsMatch,
        );
        debugPrint(
          '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
        );
        return result;
      }
    } on DioException catch (error, stackTrace) {
      _logLookupError('Open Food Facts lookup failed', error, stackTrace);
    } catch (error, stackTrace) {
      hadError = true;
      _logLookupError('Open Food Facts lookup failed', error, stackTrace);
    }

    debugPrint('[BarcodeService] Trying Gemini fallback...');

    try {
      final geminiData = await _remoteDataSource.geminiBarcodeLookup(trimmed);
      if (_isHighConfidenceGeminiMatch(trimmed, geminiData)) {
        final result = BarcodeLookupResult.fromGemini(geminiData);
        debugPrint(
          '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
        );
        return result;
      }
    } catch (error) {
      debugPrint('[BarcodeService] Gemini fallback error: $error');
      hadError = true;
    }

    final result = BarcodeLookupResult.notFound(hadError: hadError);
    debugPrint(
      '[BarcodeService] Final result: found=${result.found}, source=${result.source}, name=${result.itemName}',
    );
    return result;
  }

  Future<ItemListDto?> _lookupInventory(String barcode) async {
    final response = await _repository.listItems(
      ItemListQuery(barcode: barcode, limit: 1),
    );
    return _findExactBarcodeMatch(response.items, barcode);
  }

  /// Same exact-match rules as [findInventoryItemByBarcodeOrQuery].
  ItemListDto? _findExactBarcodeMatch(
    List<ItemListDto> items,
    String barcode,
  ) {
    for (final item in items) {
      if (BarcodeConfidence.isExactBarcodeMatch(barcode, item.barcode)) {
        return item;
      }
    }
    return null;
  }

  static bool _isHighConfidenceGeminiMatch(
    String barcode,
    Map<String, dynamic> data,
  ) {
    if (data['found'] != true) return false;
    if (!BarcodeConfidence.isEligibleForExternalLookup(barcode)) return false;

    final itemName = (data['itemName'] as String?)?.trim() ?? '';
    if (itemName.length < 3) return false;

    final confidence = data['confidence'];
    if (confidence is! num || confidence < 0.85) return false;

    return true;
  }

  Future<BarcodeLookupResult?> _lookupOpenFoodFacts(String barcode) async {
    final response = await _openFoodFactsDio.get<Map<String, dynamic>>(
      '$_openFoodFactsProductUrl/$barcode.json',
      options: Options(
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: const {'User-Agent': 'BillingBaba/1.0'},
      ),
    );

    debugPrint('[BarcodeService] OFF status: ${response.data?['status']}');
    debugPrint(
      '[BarcodeService] OFF product: ${response.data?['product']?['product_name']}',
    );

    final data = response.data;
    if (data == null || data['status'] != 1) return null;

    final responseCode = data['code'];
    if (responseCode is! String && responseCode is! num) return null;
    if (!BarcodeConfidence.isExactBarcodeMatch(
      barcode,
      responseCode.toString(),
    )) {
      debugPrint('[BarcodeService] OFF code mismatch for barcode=$barcode');
      return null;
    }

    final product = data['product'];
    if (product is! Map<String, dynamic>) return null;

    final productName = (product['product_name'] as String?)?.trim() ?? '';
    if (productName.isEmpty) return null;

    final categoryTags = product['categories_tags'];
    final rawCategory = categoryTags is List && categoryTags.isNotEmpty
        ? categoryTags.first
        : null;
    final category = rawCategory is String ? _cleanCategoryTag(rawCategory) : '';

    final quantity = (product['quantity'] as String?)?.trim();
    final defaultMrp = _extractMrpFromOpenFoodFacts(product);

    return BarcodeLookupResult.fromOpenFoodFacts(
      itemName: productName,
      category: category,
      baseUnit: quantity?.isNotEmpty == true ? quantity! : null,
      defaultMrp: defaultMrp,
    );
  }

  Future<BarcodeLookupResult> _enrichMissingCommercialFields(
    String barcode,
    BarcodeLookupResult base,
  ) async {
    if (!base.needsCommercialEnrichment) return base;

    debugPrint('[BarcodeService] Enriching commercial fields via Gemini...');

    try {
      final geminiData = await _remoteDataSource.geminiBarcodeLookup(barcode);
      if (geminiData['found'] != true) return base;

      final enriched = base.mergeGeminiCommercialFields(geminiData);
      debugPrint(
        '[BarcodeService] Enriched hsn=${enriched.hsnCode}, mrp=${enriched.defaultMrp}',
      );
      return enriched;
    } catch (error, stackTrace) {
      _logLookupError('Gemini commercial enrichment failed', error, stackTrace);
      return base;
    }
  }

  static String? _extractMrpFromOpenFoodFacts(Map<String, dynamic> product) {
    final prices = product['prices'];
    if (prices is Map) {
      for (final key in ['in', 'india', 'en:in']) {
        final countryPrice = prices[key];
        if (countryPrice is Map) {
          final price = countryPrice['price'] ?? countryPrice['value'];
          final normalized = _normalizePrice(price);
          if (normalized != null) return normalized;
        }
      }
    }

    return _normalizePrice(product['price']);
  }

  static String? _normalizePrice(Object? value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final numeric = raw.replaceAll(RegExp(r'[^\d.]'), '');
    return numeric.isNotEmpty ? numeric : null;
  }

  static String? _firstNonEmpty(String? primary, String? secondary) {
    if (primary != null && primary.trim().isNotEmpty) return primary.trim();
    if (secondary != null && secondary.trim().isNotEmpty) return secondary.trim();
    return null;
  }

  static String _cleanCategoryTag(String tag) {
    final withoutLang = tag.contains(':') ? tag.split(':').last : tag;
    return withoutLang
        .split('-')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  void _logLookupError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class BarcodeLookupResult {
  const BarcodeLookupResult({
    required this.found,
    required this.source, this.itemName,
    this.category,
    this.hsnCode,
    this.defaultMrp,
    this.salePrice,
    this.taxPercent,
    this.baseUnit,
    this.incTax = true,
    this.hadError = false,
  });

  factory BarcodeLookupResult.fromInventory(ItemListDto item) {
    return BarcodeLookupResult(
      found: true,
      itemName: item.name,
      category: item.category?.name ?? '',
      hsnCode: item.hsnCode ?? '',
      defaultMrp: item.mrp ?? '',
      salePrice: item.salePrice,
      taxPercent: '',
      baseUnit: item.baseUnit,
      source: 'inventory',
    );
  }

  factory BarcodeLookupResult.fromOpenFoodFacts({
    required String itemName,
    String? category,
    String? baseUnit,
    String? defaultMrp,
  }) {
    final mrp = defaultMrp?.trim() ?? '';
    return BarcodeLookupResult(
      found: true,
      itemName: itemName,
      category: category ?? '',
      hsnCode: '',
      defaultMrp: mrp,
      salePrice: '',
      taxPercent: '',
      baseUnit: baseUnit ?? '',
      source: 'openfoodfacts',
    );
  }

  factory BarcodeLookupResult.fromGemini(Map<String, dynamic> data) {
    final defaultMrp = _normalizePriceField(data['defaultMrp'] as String?);
    final salePrice = _normalizePriceField(data['salePrice'] as String?);
    return BarcodeLookupResult(
      found: true,
      itemName: data['itemName'] as String?,
      category: data['category'] as String?,
      hsnCode: data['hsnCode'] as String?,
      defaultMrp: defaultMrp,
      salePrice: salePrice ?? defaultMrp,
      taxPercent: data['taxPercent'] as String?,
      baseUnit: data['baseUnit'] as String?,
      incTax: data['incTax'] as bool? ?? true,
      source: 'gemini',
    );
  }

  factory BarcodeLookupResult.notFound({bool hadError = false}) {
    return BarcodeLookupResult(
      found: false,
      source: 'notFound',
      hadError: hadError,
    );
  }

  final bool found;
  final String? itemName;
  final String? category;
  final String? hsnCode;
  final String? defaultMrp;
  final String? salePrice;
  final String? taxPercent;
  final String? baseUnit;
  final bool incTax;
  final String source;
  final bool hadError;

  bool get needsCommercialEnrichment {
    return _isBlank(hsnCode) || _isBlank(taxPercent);
  }

  BarcodeLookupResult mergeGeminiCommercialFields(Map<String, dynamic> data) {
    final enrichedMrp = BarcodeLookupService._firstNonEmpty(
      defaultMrp,
      _normalizePriceField(data['defaultMrp'] as String?),
    );
    final enrichedSalePrice = BarcodeLookupService._firstNonEmpty(
      salePrice,
      _normalizePriceField(data['salePrice'] as String?),
    );

    return BarcodeLookupResult(
      found: found,
      itemName: itemName,
      category: category,
      hsnCode: BarcodeLookupService._firstNonEmpty(
        hsnCode,
        data['hsnCode'] as String?,
      ),
      defaultMrp: enrichedMrp,
      salePrice: enrichedSalePrice ?? enrichedMrp,
      taxPercent: BarcodeLookupService._firstNonEmpty(
        taxPercent,
        data['taxPercent'] as String?,
      ),
      baseUnit: BarcodeLookupService._firstNonEmpty(
        baseUnit,
        data['baseUnit'] as String?,
      ),
      incTax: data['incTax'] is bool ? data['incTax'] as bool : incTax,
      source: source,
      hadError: hadError,
    );
  }

  static String? _normalizePriceField(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final numeric = trimmed.replaceAll(RegExp(r'[^\d.]'), '');
    return numeric.isNotEmpty ? numeric : null;
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;
}
