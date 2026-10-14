import 'package:flutter_riverpod/flutter_riverpod.dart';

class _SaleDocumentBarcodeItemRowMap extends Notifier<Map<String, int?>> {
  @override
  Map<String, int?> build() => const {};

  void setForSession(String sessionKey, int? row) {
    state = {...state, sessionKey: row};
  }

  int? forSession(String sessionKey) => state[sessionKey];
}

class _SaleDocumentBarcodeSerialRowMap extends Notifier<Map<String, int?>> {
  @override
  Map<String, int?> build() => const {};

  void setForSession(String sessionKey, int? row) {
    state = {...state, sessionKey: row};
  }

  int? forSession(String sessionKey) => state[sessionKey];
}

final _saleDocumentBarcodeItemRowMapProvider =
    NotifierProvider<_SaleDocumentBarcodeItemRowMap, Map<String, int?>>(
  _SaleDocumentBarcodeItemRowMap.new,
);

final _saleDocumentBarcodeSerialRowMapProvider =
    NotifierProvider<_SaleDocumentBarcodeSerialRowMap, Map<String, int?>>(
  _SaleDocumentBarcodeSerialRowMap.new,
);

int? saleDocumentBarcodeItemRow(WidgetRef ref, String sessionKey) {
  return ref
      .read(_saleDocumentBarcodeItemRowMapProvider.notifier)
      .forSession(sessionKey);
}

int? saleDocumentBarcodeSerialRow(WidgetRef ref, String sessionKey) {
  return ref
      .read(_saleDocumentBarcodeSerialRowMapProvider.notifier)
      .forSession(sessionKey);
}

void setSaleDocumentBarcodeItemRow(
  WidgetRef ref,
  String sessionKey,
  int? row,
) {
  ref
      .read(_saleDocumentBarcodeItemRowMapProvider.notifier)
      .setForSession(sessionKey, row);
}

void setSaleDocumentBarcodeSerialRow(
  WidgetRef ref,
  String sessionKey,
  int? row,
) {
  ref
      .read(_saleDocumentBarcodeSerialRowMapProvider.notifier)
      .setForSession(sessionKey, row);
}

void clearSaleDocumentBarcodeTargets(WidgetRef ref, String sessionKey) {
  setSaleDocumentBarcodeItemRow(ref, sessionKey, null);
  setSaleDocumentBarcodeSerialRow(ref, sessionKey, null);
}
