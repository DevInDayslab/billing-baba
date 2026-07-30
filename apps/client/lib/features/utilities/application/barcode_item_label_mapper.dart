import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:intl/intl.dart';

/// Label text derived from an inventory item for barcode printing.
class BarcodeItemLabelFields {
  const BarcodeItemLabelFields({
    required this.header,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.line4,
  });

  final String header;
  final String line1;
  final String line2;
  final String line3;
  final String line4;
}

/// Maps [InventoryItem] data to barcode label header and line fields.
class BarcodeItemLabelMapper {
  const BarcodeItemLabelMapper._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs.',
    decimalDigits: 2,
  );

  static BarcodeItemLabelFields fromItem({
    required InventoryItem item,
    required String companyName,
    String? categoryName,
  }) {
    return BarcodeItemLabelFields(
      header: companyName.trim(),
      line1: item.name.trim(),
      line2: _formatSalePrice(item.salePrice),
      line3: '',
      line4: _formatLine4(
        mrp: item.mrp,
        hsnCode: item.hsnCode,
        categoryName: categoryName,
      ),
    );
  }

  static String _formatSalePrice(double? salePrice) {
    if (salePrice == null) return '';
    return _currencyFormat.format(salePrice);
  }

  static String _formatLine4({
    required double? mrp,
    required String? hsnCode,
    required String? categoryName,
  }) {
    if (mrp != null && mrp > 0) {
      return 'MRP: ${_currencyFormat.format(mrp)}';
    }
    final hsn = hsnCode?.trim();
    if (hsn != null && hsn.isNotEmpty) {
      return 'HSN: $hsn';
    }
    final category = categoryName?.trim();
    if (category != null && category.isNotEmpty) {
      return category;
    }
    return '';
  }
}
