import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/utilities/application/barcode_item_label_mapper.dart';
import 'package:billing_baba/features/utilities/models/barcode_label_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class BarcodeGeneratorDraft {
  const BarcodeGeneratorDraft({
    this.itemName = '',
    this.itemId,
    this.itemCode = '',
    this.noOfLabels = '',
    this.header = '',
    this.line1 = '',
    this.line2 = '',
    this.line3 = '',
    this.line4 = '',
    this.noBarcode = false,
    this.showValidation = false,
  });

  final String itemName;
  final String? itemId;
  final String itemCode;
  final String noOfLabels;
  final String header;
  final String line1;
  final String line2;
  final String line3;
  final String line4;
  final bool noBarcode;
  final bool showValidation;

  bool get canAdd =>
      itemName.trim().isNotEmpty &&
      (noBarcode || itemCode.trim().isNotEmpty) &&
      (int.tryParse(noOfLabels.trim()) ?? 0) > 0;

  String? get itemNameError => showValidation && itemName.trim().isEmpty
      ? 'Item name is required'
      : null;

  String? get itemCodeError =>
      showValidation && !noBarcode && itemCode.trim().isEmpty
      ? 'Item code is required'
      : null;

  String? get noOfLabelsError {
    if (!showValidation) return null;
    final count = int.tryParse(noOfLabels.trim());
    if (count == null || count <= 0) return 'Enter a valid label count';
    return null;
  }

  BarcodeGeneratorDraft copyWith({
    String? itemName,
    String? itemId,
    bool clearItemId = false,
    String? itemCode,
    String? noOfLabels,
    String? header,
    String? line1,
    String? line2,
    String? line3,
    String? line4,
    bool? noBarcode,
    bool? showValidation,
  }) {
    return BarcodeGeneratorDraft(
      itemName: itemName ?? this.itemName,
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      itemCode: itemCode ?? this.itemCode,
      noOfLabels: noOfLabels ?? this.noOfLabels,
      header: header ?? this.header,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      line3: line3 ?? this.line3,
      line4: line4 ?? this.line4,
      noBarcode: noBarcode ?? this.noBarcode,
      showValidation: showValidation ?? this.showValidation,
    );
  }
}

class BarcodeGeneratorState {
  const BarcodeGeneratorState({
    this.draft = const BarcodeGeneratorDraft(),
    this.entries = const [],
    this.selectedEntryIds = const {},
    this.printer = BarcodePrinterOption.labelPrinter,
    this.layout = BarcodeLabelLayout.twoLabels50x25,
    this.isGenerating = false,
    this.formSession = 0,
  });

  final BarcodeGeneratorDraft draft;
  final List<BarcodeLabelEntry> entries;
  final Set<String> selectedEntryIds;
  final BarcodePrinterOption printer;
  final BarcodeLabelLayout layout;
  final bool isGenerating;
  final int formSession;

  bool get allSelected =>
      entries.isNotEmpty && selectedEntryIds.length == entries.length;

  bool get hasSelection => selectedEntryIds.isNotEmpty;

  bool get canGenerate => hasSelection && !isGenerating;

  BarcodeGeneratorState copyWith({
    BarcodeGeneratorDraft? draft,
    List<BarcodeLabelEntry>? entries,
    Set<String>? selectedEntryIds,
    BarcodePrinterOption? printer,
    BarcodeLabelLayout? layout,
    bool? isGenerating,
    int? formSession,
  }) {
    return BarcodeGeneratorState(
      draft: draft ?? this.draft,
      entries: entries ?? this.entries,
      selectedEntryIds: selectedEntryIds ?? this.selectedEntryIds,
      printer: printer ?? this.printer,
      layout: layout ?? this.layout,
      isGenerating: isGenerating ?? this.isGenerating,
      formSession: formSession ?? this.formSession,
    );
  }
}

final barcodeGeneratorProvider =
    NotifierProvider<BarcodeGeneratorNotifier, BarcodeGeneratorState>(
      BarcodeGeneratorNotifier.new,
    );

class BarcodeGeneratorNotifier extends Notifier<BarcodeGeneratorState> {
  @override
  BarcodeGeneratorState build() => const BarcodeGeneratorState();

  void updateDraft(BarcodeGeneratorDraft draft) {
    state = state.copyWith(draft: draft);
  }

  void setPrinter(BarcodePrinterOption printer) {
    state = state.copyWith(printer: printer);
  }

  void setLayout(BarcodeLabelLayout layout) {
    state = state.copyWith(layout: layout);
  }

  void selectInventoryItem(InventoryItem item) {
    final companyName = ref.read(currentBusinessProvider)?.name ?? '';
    final categoryName = ref
        .read(categoriesProvider)
        .where((category) => category.id == item.categoryId)
        .map((category) => category.name)
        .firstOrNull;
    final labels = BarcodeItemLabelMapper.fromItem(
      item: item,
      companyName: companyName,
      categoryName: categoryName,
    );
    final itemCode = item.barcode?.trim() ?? '';

    state = state.copyWith(
      draft: state.draft.copyWith(
        itemName: item.name,
        itemId: item.id,
        itemCode: itemCode,
        header: labels.header,
        line1: labels.line1,
        line2: labels.line2,
        line3: labels.line3,
        line4: labels.line4,
        showValidation: false,
      ),
    );
  }

  void unlinkItemSelection({required String itemName}) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        itemName: itemName,
        clearItemId: true,
        showValidation: false,
      ),
    );
  }

  void clearDraft() {
    state = state.copyWith(
      draft: const BarcodeGeneratorDraft(),
    );
  }

  bool addEntry() {
    final draft = state.draft.copyWith(showValidation: true);
    state = state.copyWith(draft: draft);
    if (!draft.canAdd) return false;

    final entry = BarcodeLabelEntry(
      id: _uuid.v4(),
      itemName: draft.itemName.trim(),
      itemId: draft.itemId,
      itemCode: draft.itemCode.trim(),
      labelCount: int.parse(draft.noOfLabels.trim()),
      header: draft.header.trim(),
      line1: draft.line1.trim(),
      line2: draft.line2.trim(),
      line3: draft.line3.trim(),
      line4: draft.line4.trim(),
      noBarcode: draft.noBarcode,
    );

    state = state.copyWith(
      entries: [...state.entries, entry],
      selectedEntryIds: {...state.selectedEntryIds, entry.id},
      draft: const BarcodeGeneratorDraft(),
      formSession: state.formSession + 1,
    );
    return true;
  }

  void removeEntry(String id) {
    final nextSelected = Set<String>.from(state.selectedEntryIds)..remove(id);
    state = state.copyWith(
      entries: state.entries.where((entry) => entry.id != id).toList(),
      selectedEntryIds: nextSelected,
    );
  }

  void toggleEntry(String id, {required bool selected}) {
    final next = Set<String>.from(state.selectedEntryIds);
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    state = state.copyWith(selectedEntryIds: next);
  }

  void toggleSelectAll({required bool selected}) {
    if (!selected) {
      state = state.copyWith(selectedEntryIds: {});
      return;
    }
    state = state.copyWith(
      selectedEntryIds: state.entries.map((entry) => entry.id).toSet(),
    );
  }

  List<BarcodeLabelEntry> selectedEntries() {
    return state.entries
        .where((entry) => state.selectedEntryIds.contains(entry.id))
        .toList();
  }

  void setGenerating(bool value) {
    state = state.copyWith(isGenerating: value);
  }
}
