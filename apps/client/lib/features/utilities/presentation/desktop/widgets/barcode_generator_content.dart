import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:billing_baba/features/print/application/print_providers.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/utilities/application/barcode_generator_provider.dart';
import 'package:billing_baba/features/utilities/application/barcode_label_pdf_builder.dart';
import 'package:billing_baba/features/utilities/models/barcode_label_entry.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/widgets/barcode_label_preview.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/widgets/utilities_page_title_bar.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _actionRed = Color(0xFFD32F2F);
const _actionRedDisabled = Color(0xFFEF9A9A);
const Color _actionRedText = Colors.white;
const _actionRedTextDisabled = Color(0xFFFFEBEE);

class BarcodeGeneratorContent extends ConsumerStatefulWidget {
  const BarcodeGeneratorContent({super.key});

  @override
  ConsumerState<BarcodeGeneratorContent> createState() =>
      _BarcodeGeneratorContentState();
}

class _BarcodeGeneratorContentState
    extends ConsumerState<BarcodeGeneratorContent> {
  Future<void> _previewOrGenerate({required bool preview}) async {
    final notifier = ref.read(barcodeGeneratorProvider.notifier);
    final selected = notifier.selectedEntries();
    if (selected.isEmpty) return;

    notifier.setGenerating(true);
    try {
      final layout = ref.read(barcodeGeneratorProvider).layout;
      final document = PrintablePdf(
        bytes: await BarcodeLabelPdfBuilder.build(
          entries: selected,
          layout: layout,
        ),
        name: 'barcode-labels',
        profile: PdfPageProfile.barcode,
      );
      if (!mounted) return;

      final output = ref.read(printOutputServiceProvider);
      if (preview) {
        await output.previewDocument(context, document);
      } else {
        final path = await output.save(
          bytes: document.bytes,
          filename: document.filename,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              path != null
                  ? 'Barcode labels saved to $path'
                  : 'Barcode labels PDF ready',
            ),
          ),
        );
      }
    } on PrintException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OutputErrorMapper.printMessage(error))),
      );
    } finally {
      notifier.setGenerating(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(barcodeGeneratorProvider);
    final notifier = ref.read(barcodeGeneratorProvider.notifier);
    final draft = state.draft;
    final items = ref.watch(inventoryItemsProvider).value ?? [];

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UtilitiesPageTitleBar(
              currentRoute: AppRoutes.utilitiesBarcodeGenerator,
              trailing: _HeaderControls(
                printer: state.printer,
                layout: state.layout,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 1080;
                final topSection = stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EntryFormCard(
                            key: ValueKey(state.formSession),
                            draft: draft,
                            items: items,
                            onDraftChanged: notifier.updateDraft,
                            onItemSelected: notifier.selectInventoryItem,
                            onItemNameChanged: (name, linkedItem) {
                              if (linkedItem != null &&
                                  linkedItem.name.trim() != name.trim()) {
                                notifier.unlinkItemSelection(itemName: name);
                                return;
                              }
                              notifier.updateDraft(
                                draft.copyWith(itemName: name),
                              );
                            },
                            onAdd: notifier.addEntry,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _PreviewCard(
                            draft: draft,
                            canAdd: draft.canAdd,
                            onAdd: notifier.addEntry,
                          ),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _EntryFormCard(
                                key: ValueKey(state.formSession),
                                draft: draft,
                                items: items,
                                onDraftChanged: notifier.updateDraft,
                                onItemSelected: notifier.selectInventoryItem,
                                onItemNameChanged: (name, linkedItem) {
                                  if (linkedItem != null &&
                                      linkedItem.name.trim() != name.trim()) {
                                    notifier.unlinkItemSelection(itemName: name);
                                    return;
                                  }
                                  notifier.updateDraft(
                                    draft.copyWith(itemName: name),
                                  );
                                },
                                onAdd: notifier.addEntry,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 3,
                              child: _PreviewCard(
                                draft: draft,
                                canAdd: draft.canAdd,
                                onAdd: notifier.addEntry,
                              ),
                            ),
                          ],
                        ),
                      );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    topSection,
                    const SizedBox(height: AppSpacing.md),
                    _ItemDetailsTable(
                      entries: state.entries,
                      selectedIds: state.selectedEntryIds,
                      allSelected: state.allSelected,
                      onToggleAll: notifier.toggleSelectAll,
                      onToggle: notifier.toggleEntry,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FooterButton(
                            label: 'Preview',
                            enabled: state.canGenerate,
                            filled: false,
                            onPressed: state.canGenerate
                                ? () => _previewOrGenerate(preview: true)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FooterButton(
                            label: 'Generate',
                            enabled: state.canGenerate,
                            filled: true,
                            loading: state.isGenerating,
                            onPressed: state.canGenerate
                                ? () => _previewOrGenerate(preview: false)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderControls extends StatelessWidget {
  const _HeaderControls({
    required this.printer,
    required this.layout,
  });

  final BarcodePrinterOption printer;
  final BarcodeLabelLayout layout;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Printer:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Text(
          printer.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Text(
          'Size:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Text(
          layout.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          tooltip: 'Settings',
          onPressed: () {},
          icon: Icon(Icons.settings_outlined, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _EntryFormCard extends StatefulWidget {
  const _EntryFormCard({
    required this.draft, required this.items, required this.onDraftChanged, required this.onItemSelected, required this.onItemNameChanged, required this.onAdd, super.key,
  });

  final BarcodeGeneratorDraft draft;
  final List<InventoryItem> items;
  final ValueChanged<BarcodeGeneratorDraft> onDraftChanged;
  final ValueChanged<InventoryItem> onItemSelected;
  final void Function(String name, InventoryItem? linkedItem) onItemNameChanged;
  final bool Function() onAdd;

  @override
  State<_EntryFormCard> createState() => _EntryFormCardState();
}

class _EntryFormCardState extends State<_EntryFormCard> {
  late final TextEditingController _itemCodeController;
  late final TextEditingController _noOfLabelsController;
  late final TextEditingController _headerController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _line3Controller;
  late final TextEditingController _line4Controller;

  @override
  void initState() {
    super.initState();
    _itemCodeController = TextEditingController(text: widget.draft.itemCode);
    _noOfLabelsController = TextEditingController(text: widget.draft.noOfLabels);
    _headerController = TextEditingController(text: widget.draft.header);
    _line1Controller = TextEditingController(text: widget.draft.line1);
    _line2Controller = TextEditingController(text: widget.draft.line2);
    _line3Controller = TextEditingController(text: widget.draft.line3);
    _line4Controller = TextEditingController(text: widget.draft.line4);
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _noOfLabelsController.dispose();
    _headerController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    _line4Controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EntryFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_itemCodeController, widget.draft.itemCode);
    _syncController(_noOfLabelsController, widget.draft.noOfLabels);
    _syncController(_headerController, widget.draft.header);
    _syncController(_line1Controller, widget.draft.line1);
    _syncController(_line2Controller, widget.draft.line2);
    _syncController(_line3Controller, widget.draft.line3);
    _syncController(_line4Controller, widget.draft.line4);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  InventoryItem? _linkedItem() {
    final itemId = widget.draft.itemId;
    if (itemId == null) return null;
    for (final item in widget.items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final onDraftChanged = widget.onDraftChanged;
    final onItemSelected = widget.onItemSelected;
    final onItemNameChanged = widget.onItemNameChanged;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter item details to add for barcode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _LabeledField(
                    label: 'Item Name*',
                    error: draft.itemNameError,
                    child: _ItemNameDropdown(
                      value: draft.itemName,
                      items: widget.items,
                      hasError: draft.itemNameError != null,
                      onChanged: (name) =>
                          onItemNameChanged(name, _linkedItem()),
                      onItemSelected: onItemSelected,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Item Code*',
                    error: draft.itemCodeError,
                    child: TextFormField(
                      controller: _itemCodeController,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(
                        hint: 'Enter Item Code',
                        hasError: draft.itemCodeError != null,
                      ),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(itemCode: value)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'No of Labels*',
                    error: draft.noOfLabelsError,
                    child: TextFormField(
                      controller: _noOfLabelsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(
                        hint: 'Enter No of Labels',
                        hasError: draft.noOfLabelsError != null,
                      ),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(noOfLabels: value)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Header',
                    child: TextFormField(
                      controller: _headerController,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Enter Header'),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(header: value)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Line 1',
                    child: TextFormField(
                      controller: _line1Controller,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Enter Line 1'),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(line1: value)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Line 2',
                    child: TextFormField(
                      controller: _line2Controller,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Enter Line 2'),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(line2: value)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Line 3',
                    child: TextFormField(
                      controller: _line3Controller,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Enter Line 3'),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(line3: value)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Line 4',
                    child: TextFormField(
                      controller: _line4Controller,
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Enter Line 4'),
                      onChanged: (value) =>
                          onDraftChanged(draft.copyWith(line4: value)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.draft,
    required this.canAdd,
    required this.onAdd,
  });

  final BarcodeGeneratorDraft draft;
  final bool canAdd;
  final bool Function() onAdd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Center(
                child: BarcodeLabelPreview(
                  header: draft.header,
                  itemCode: draft.itemCode,
                  line1: draft.line1,
                  line2: draft.line2,
                  line3: draft.line3,
                  line4: draft.line4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: canAdd ? onAdd : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canAdd ? _actionRed : _actionRedDisabled,
                  foregroundColor:
                      canAdd ? _actionRedText : _actionRedTextDisabled,
                  disabledBackgroundColor: _actionRedDisabled,
                  disabledForegroundColor: _actionRedTextDisabled,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add for Barcode',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDetailsTable extends StatelessWidget {
  const _ItemDetailsTable({
    required this.entries,
    required this.selectedIds,
    required this.allSelected,
    required this.onToggleAll,
    required this.onToggle,
  });

  final List<BarcodeLabelEntry> entries;
  final Set<String> selectedIds;
  final bool allSelected;
  final void Function({required bool selected}) onToggleAll;
  final void Function(String id, {required bool selected}) onToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                const Text(
                  'Item Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.open_in_full,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 56),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Added items for Barcode generation will appear here.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            ResizableDataTable(
              columns: [
                ResizableDataColumn(
                  initialWidth: 52,
                  minWidth: 52,
                  maxWidth: 52,
                  resizable: false,
                  header: Align(
                    child: Checkbox(
                      value: allSelected,
                      onChanged: (value) =>
                          onToggleAll(selected: value ?? false),
                    ),
                  ),
                ),
                const ResizableDataColumn(
                  initialWidth: 160,
                  header: _BarcodeTableHeaderCell(label: 'Item Name'),
                ),
                const ResizableDataColumn(
                  initialWidth: 100,
                  header: _BarcodeTableHeaderCell(label: 'No of Labels'),
                ),
                const ResizableDataColumn(
                  initialWidth: 140,
                  header: _BarcodeTableHeaderCell(label: 'Header'),
                ),
                const ResizableDataColumn(
                  initialWidth: 120,
                  header: _BarcodeTableHeaderCell(label: 'Line 1'),
                ),
                const ResizableDataColumn(
                  initialWidth: 120,
                  header: _BarcodeTableHeaderCell(label: 'Line 2'),
                ),
                const ResizableDataColumn(
                  initialWidth: 120,
                  header: _BarcodeTableHeaderCell(label: 'Line 3'),
                ),
                const ResizableDataColumn(
                  initialWidth: 120,
                  header: _BarcodeTableHeaderCell(label: 'Line 4'),
                ),
              ],
              rows: [
                for (final entry in entries)
                  ResizableDataRow(
                    isSelected: selectedIds.contains(entry.id),
                    cells: [
                      Align(
                        child: Checkbox(
                          value: selectedIds.contains(entry.id),
                          onChanged: (value) => onToggle(
                            entry.id,
                            selected: value ?? false,
                          ),
                        ),
                      ),
                      _BarcodeTableDataCell(text: entry.itemName),
                      _BarcodeTableDataCell(text: '${entry.labelCount}'),
                      _BarcodeTableDataCell(text: entry.header),
                      _BarcodeTableDataCell(text: entry.line1),
                      _BarcodeTableDataCell(text: entry.line2),
                      _BarcodeTableDataCell(text: entry.line3),
                      _BarcodeTableDataCell(text: entry.line4),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BarcodeTableHeaderCell extends StatelessWidget {
  const _BarcodeTableHeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}

class _BarcodeTableDataCell extends StatelessWidget {
  const _BarcodeTableDataCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.error,
  });

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 6),
        child,
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
          ),
        ],
      ],
    );
  }
}

class _ItemNameDropdown extends StatelessWidget {
  const _ItemNameDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onItemSelected,
    this.hasError = false,
  });

  final String value;
  final List<InventoryItem> items;
  final ValueChanged<String> onChanged;
  final ValueChanged<InventoryItem> onItemSelected;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final products =
        items.where((item) => item.type == ItemType.product).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return Autocomplete<InventoryItem>(
      initialValue: TextEditingValue(text: value),
      displayStringForOption: (item) => item.name,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return products.take(20);
        return products.where(
          (item) => item.name.toLowerCase().contains(query),
        );
      },
      onSelected: onItemSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: saleFieldTextStyle,
          decoration: buildSaleFieldDecoration(
            hint: 'Enter Item Name',
            hasError: hasError,
            suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 20),
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.enabled,
    required this.filled,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final bool enabled;
  final bool filled;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? (filled ? _actionRed : Colors.white)
        : (filled ? _actionRedDisabled : Colors.white);
    final foreground = enabled
        ? (filled ? _actionRedText : AppColors.textSecondary)
        : _actionRedTextDisabled;

    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(
            color: filled ? background : const Color(0xFFE0E0E0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
