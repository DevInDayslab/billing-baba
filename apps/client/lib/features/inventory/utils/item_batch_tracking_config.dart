import 'package:billing_baba/features/inventory/models/item_vyapar_settings.dart';

enum ItemBatchTrackingField {
  batchNo,
  mfgDate,
  expDate,
  modelNo,
  size,
  openingQty,
}

class ItemBatchTrackingColumn {
  const ItemBatchTrackingColumn({
    required this.field,
    required this.label,
    this.dateFormatId,
  });

  final ItemBatchTrackingField field;
  final String label;
  final String? dateFormatId;
}

extension ItemVyaparBatchTracking on ItemVyaparExtension {
  bool get hasBatchTrackingFieldsConfigured =>
      batchNoEnabled ||
      batchExpDateEnabled ||
      batchMfgDateEnabled ||
      batchModelNoEnabled ||
      batchSizeEnabled;

  ItemVyaparExtension withSyncedBatchTrackingEnabled() {
    return copyWith(batchTrackingEnabled: hasBatchTrackingFieldsConfigured);
  }

  List<ItemBatchTrackingColumn> openingStockBatchColumns() {
    final columns = <ItemBatchTrackingColumn>[];
    if (batchNoEnabled) {
      columns.add(
        ItemBatchTrackingColumn(
          field: ItemBatchTrackingField.batchNo,
          label: batchNoLabel.trim().isEmpty ? 'Batch No.' : batchNoLabel,
        ),
      );
    }
    if (batchModelNoEnabled) {
      columns.add(
        ItemBatchTrackingColumn(
          field: ItemBatchTrackingField.modelNo,
          label:
              batchModelNoLabel.trim().isEmpty ? 'Model No.' : batchModelNoLabel,
        ),
      );
    }
    if (batchMfgDateEnabled) {
      columns.add(
        ItemBatchTrackingColumn(
          field: ItemBatchTrackingField.mfgDate,
          label: batchMfgDateLabel.trim().isEmpty ? 'Mfg. Date' : batchMfgDateLabel,
          dateFormatId: ItemFieldCatalog.resolveBatchDateFormatId(
            batchMfgDateFormatId,
          ),
        ),
      );
    }
    if (batchExpDateEnabled) {
      columns.add(
        ItemBatchTrackingColumn(
          field: ItemBatchTrackingField.expDate,
          label: batchExpDateLabel.trim().isEmpty ? 'Exp. Date' : batchExpDateLabel,
          dateFormatId: ItemFieldCatalog.resolveBatchDateFormatId(
            batchExpDateFormatId,
          ),
        ),
      );
    }
    if (batchSizeEnabled) {
      columns.add(
        ItemBatchTrackingColumn(
          field: ItemBatchTrackingField.size,
          label: batchSizeLabel.trim().isEmpty ? 'Size' : batchSizeLabel,
        ),
      );
    }
    columns.add(
      const ItemBatchTrackingColumn(
        field: ItemBatchTrackingField.openingQty,
        label: 'OPENING QTY',
      ),
    );
    return columns;
  }
}

String formatItemBatchDate(DateTime? date, String? formatId) =>
    ItemFieldCatalog.formatBatchDate(date, formatId);

DateTime? parseItemBatchDate(String raw, String? formatId) =>
    ItemFieldCatalog.parseBatchDate(raw, formatId);
