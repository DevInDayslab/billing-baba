import 'dart:async';

import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/barcode_scan_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether HID/camera barcode scanning is enabled in item settings.
bool isBarcodeScanningEnabled(WidgetRef ref) {
  final settings = ref.watch(itemSettingsProvider).value;
  return settings?.barcodeScanningEnabled ?? true;
}

/// Prefer USB HID UI when item settings select USB scanner.
bool preferHardwareBarcodeScanner(WidgetRef ref) {
  final settings = ref.watch(itemSettingsProvider).value;
  return settings?.barcodeScannerType == BarcodeScannerType.usbScanner;
}

/// Shared document barcode scan → [SaleItemOption] for sale/purchase lines.
Future<void> handleDocumentBarcodeScanCode(
  String barcode, {
  required BuildContext context,
  required WidgetRef ref,
  required BarcodeScanHandler handler,
  required FutureOr<void> Function(SaleItemOption catalogItem) onCatalogItem,
  VoidCallback? onAfterScan,
}) async {
  await handleBarcodeScan(
    barcode,
    handler: handler,
    engine: ref.read(inventorySearchEngineProvider),
    items: ref.read(inventoryItemListProvider),
    onItemFound: (InventoryItem item, _) async {
      await onCatalogItem(saleItemOptionFromInventory(item));
      if (context.mounted) {
        showBarcodeAddedSnackBar(context, item.name);
      }
      onAfterScan?.call();
    },
    onNotFound: (code) {
      if (context.mounted) {
        showBarcodeNotFoundSnackBar(context, code);
      }
      onAfterScan?.call();
    },
  );
}
