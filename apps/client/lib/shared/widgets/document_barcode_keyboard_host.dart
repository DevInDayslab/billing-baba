import 'dart:async';

import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/barcode_keyboard_listener.dart';
import 'package:billing_baba/shared/widgets/document_barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a sale/purchase/POS surface with HID barcode listening.
///
/// Respects item-settings [isBarcodeScanningEnabled] and ignores EditableText.
class DocumentBarcodeKeyboardHost extends ConsumerStatefulWidget {
  const DocumentBarcodeKeyboardHost({
    required this.onCatalogItem,
    required this.child,
    super.key,
    this.enabled = true,
    this.autofocus = true,
  });

  final FutureOr<void> Function(SaleItemOption catalogItem) onCatalogItem;
  final Widget child;
  final bool enabled;
  final bool autofocus;

  @override
  ConsumerState<DocumentBarcodeKeyboardHost> createState() =>
      _DocumentBarcodeKeyboardHostState();
}

class _DocumentBarcodeKeyboardHostState
    extends ConsumerState<DocumentBarcodeKeyboardHost> {
  final _hidController = BarcodeKeyboardController();
  final _handler = BarcodeScanHandler(
    debounce: BarcodeScanHandler.hidDebounce,
  );

  Future<void> _onBarcode(String barcode) async {
    await handleDocumentBarcodeScanCode(
      barcode,
      context: context,
      ref: ref,
      handler: _handler,
      onCatalogItem: widget.onCatalogItem,
      onAfterScan: _hidController.requestFocus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanningEnabled = widget.enabled && isBarcodeScanningEnabled(ref);
    return BarcodeKeyboardListener(
      enabled: scanningEnabled,
      autofocus: widget.autofocus && scanningEnabled,
      controller: _hidController,
      ignoreWhenEditableFocused: true,
      onBarcode: (code) => unawaited(_onBarcode(code)),
      child: widget.child,
    );
  }
}
