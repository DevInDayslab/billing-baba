import 'dart:async';

import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/barcode_keyboard_listener.dart';
import 'package:billing_baba/shared/widgets/document_barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes HID scanner focus to descendants (e.g. line-item scan icons).
class DocumentBarcodeKeyboardScope extends InheritedWidget {
  const DocumentBarcodeKeyboardScope({
    required this.requestScannerFocus,
    required super.child,
    super.key,
  });

  final VoidCallback requestScannerFocus;

  static DocumentBarcodeKeyboardScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DocumentBarcodeKeyboardScope>();
  }

  @override
  bool updateShouldNotify(DocumentBarcodeKeyboardScope oldWidget) => false;
}

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
    this.onBarcode,
  });

  final FutureOr<void> Function(SaleItemOption catalogItem) onCatalogItem;
  final Widget child;
  final bool enabled;
  final bool autofocus;

  /// When this returns `true`, default catalog handling is skipped.
  final FutureOr<bool> Function(String barcode)? onBarcode;

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
    if (widget.onBarcode != null) {
      final handled = await widget.onBarcode!(barcode);
      if (handled) {
        _hidController.requestFocus();
        return;
      }
    }
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
    return DocumentBarcodeKeyboardScope(
      requestScannerFocus: _hidController.requestFocus,
      child: BarcodeKeyboardListener(
        enabled: scanningEnabled,
        autofocus: widget.autofocus && scanningEnabled,
        controller: _hidController,
        ignoreWhenEditableFocused: true,
        onBarcode: (code) => unawaited(_onBarcode(code)),
        child: widget.child,
      ),
    );
  }
}
