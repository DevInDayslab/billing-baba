import 'dart:async';

import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter/services.dart';

/// Outcome of [BarcodeScanHandler.handle] before surface-specific add-to-cart.
enum BarcodeScanStatus {
  /// Duplicate within debounce window — ignored.
  debounced,

  /// Empty / too short after normalize.
  invalid,

  /// Exact local inventory match.
  found,

  /// No matching product barcode in local inventory.
  notFound,
}

/// Result of the shared barcode pipeline (trim → debounce → validate → lookup).
class BarcodeScanResult {
  const BarcodeScanResult._({
    required this.status,
    required this.barcode,
    this.item,
  });

  factory BarcodeScanResult.debounced(String barcode) =>
      BarcodeScanResult._(status: BarcodeScanStatus.debounced, barcode: barcode);

  factory BarcodeScanResult.invalid(String barcode) =>
      BarcodeScanResult._(status: BarcodeScanStatus.invalid, barcode: barcode);

  factory BarcodeScanResult.found(String barcode, InventoryItem item) =>
      BarcodeScanResult._(
        status: BarcodeScanStatus.found,
        barcode: barcode,
        item: item,
      );

  factory BarcodeScanResult.notFound(String barcode) =>
      BarcodeScanResult._(status: BarcodeScanStatus.notFound, barcode: barcode);

  final BarcodeScanStatus status;
  final String barcode;
  final InventoryItem? item;

  bool get isFound => status == BarcodeScanStatus.found && item != null;
}

/// Suffix keys that terminate a HID keyboard-wedge barcode.
enum BarcodeScanSuffix {
  enter,
  tab,
  enterOrTab,
}

extension BarcodeScanSuffixX on BarcodeScanSuffix {
  bool matches(LogicalKeyboardKey key) {
    final isEnter = key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    final isTab = key == LogicalKeyboardKey.tab;
    return switch (this) {
      BarcodeScanSuffix.enter => isEnter,
      BarcodeScanSuffix.tab => isTab,
      BarcodeScanSuffix.enterOrTab => isEnter || isTab,
    };
  }
}

/// Shared barcode processing for camera and USB/Bluetooth HID scanners.
///
/// Surfaces must call [handle] / [handleBarcodeScan] from both sources and
/// implement add-to-document via callbacks — no duplicated lookup logic.
class BarcodeScanHandler {
  BarcodeScanHandler({
    this.debounce = const Duration(milliseconds: 100),
    this.minLength = 3,
  });

  /// Camera scanners typically need a longer window to avoid double-fires.
  static const cameraDebounce = Duration(milliseconds: 1500);

  /// HID wedge scanners are discrete Enter/Tab terminated reads.
  static const hidDebounce = Duration(milliseconds: 100);

  final Duration debounce;
  final int minLength;

  String? _lastBarcode;
  DateTime? _lastScanAt;
  bool _isProcessing = false;

  bool _shouldProcess(String barcode) {
    final now = DateTime.now();
    if (_lastBarcode == barcode &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < debounce) {
      return false;
    }
    _lastBarcode = barcode;
    _lastScanAt = now;
    return true;
  }

  /// Trim, debounce, validate, and look up a barcode in local inventory.
  Future<BarcodeScanResult> process(
    String raw, {
    required InventorySearchEngine engine,
    required Iterable<InventoryItem> items,
  }) async {
    final trimmed = raw.trim();
    final normalized = BarcodeConfidence.normalize(trimmed);
    final barcode = normalized.isNotEmpty ? normalized : trimmed;
    if (barcode.isEmpty || barcode.length < minLength) {
      return BarcodeScanResult.invalid(barcode);
    }
    if (!_shouldProcess(barcode)) {
      return BarcodeScanResult.debounced(barcode);
    }

    final products = items.where((item) => item.type == ItemType.product);
    final inventoryItem = findInventoryItemByBarcodeOrQuery(
      engine,
      products,
      query: barcode,
    );
    if (inventoryItem == null) {
      return BarcodeScanResult.notFound(barcode);
    }
    return BarcodeScanResult.found(barcode, inventoryItem);
  }

  /// Full pipeline: process + callbacks + haptic on success/error.
  Future<BarcodeScanResult> handle(
    String raw, {
    required InventorySearchEngine engine,
    required Iterable<InventoryItem> items,
    required FutureOr<void> Function(InventoryItem item, String barcode)
        onItemFound,
    required void Function(String barcode) onNotFound,
    void Function(String barcode)? onInvalid,
  }) async {
    if (_isProcessing) {
      return BarcodeScanResult.debounced(raw.trim());
    }
    _isProcessing = true;
    try {
      final result = await process(
        raw,
        engine: engine,
        items: items,
      );

      if (result.status == BarcodeScanStatus.debounced) {
        return result;
      }
      if (result.status == BarcodeScanStatus.invalid) {
        onInvalid?.call(result.barcode);
        return result;
      }
      if (result.status == BarcodeScanStatus.found) {
        unawaited(HapticFeedback.mediumImpact());
        await onItemFound(result.item!, result.barcode);
        return result;
      }
      unawaited(HapticFeedback.heavyImpact());
      onNotFound(result.barcode);
      return result;
    } finally {
      _isProcessing = false;
    }
  }

  void clearDebounce() {
    _lastBarcode = null;
    _lastScanAt = null;
  }
}

/// Convenience entry used by camera and HID surfaces.
Future<BarcodeScanResult> handleBarcodeScan(
  String barcode, {
  required BarcodeScanHandler handler,
  required InventorySearchEngine engine,
  required Iterable<InventoryItem> items,
  required FutureOr<void> Function(InventoryItem item, String barcode)
      onItemFound,
  required void Function(String barcode) onNotFound,
  void Function(String barcode)? onInvalid,
}) {
  return handler.handle(
    barcode,
    engine: engine,
    items: items,
    onItemFound: onItemFound,
    onNotFound: onNotFound,
    onInvalid: onInvalid,
  );
}
