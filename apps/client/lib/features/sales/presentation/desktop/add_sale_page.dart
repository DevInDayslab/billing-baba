import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/hidden_ledger/models/short_payment_handling.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_recovery_dialog.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_summary_tile.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/short_payment_handling_dialog.dart';
import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/sale_invoice_print_actions.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/sales/application/sale_document_barcode_providers.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/application/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_features.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_header_visibility.dart';
import 'package:billing_baba/features/sales/application/sale_transaction_totals_settings.dart';
import 'package:billing_baba/features/sales/application/sale_tabs_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/add_sale_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_profit_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_item_serial_no_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_tabs_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/barcode_scan_feedback.dart';
import 'package:billing_baba/shared/widgets/document_barcode_keyboard_host.dart';
import 'package:billing_baba/shared/widgets/document_barcode_scan.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addressFieldLines = 3;
const _invoiceMetaWidth = 200.0;
const _narrowBreakpoint = 720.0;
const _billingNameRowFlex = 6;
const _phoneRowFlex = 5;
const _phoneRowTrailingSpacerFlex = 9;
const _billingAddressRowFlex = 6;
const _eWayBillRowFlex = 5;
const _addressRowTrailingSpacerFlex = 8;

class DesktopAddSalePage extends ConsumerStatefulWidget {
  const DesktopAddSalePage({
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.initialPartyId,
    this.initialPartyName,
    this.readOnly = false,
    super.key,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final String? initialPartyId;
  final String? initialPartyName;
  final bool readOnly;

  @override
  ConsumerState<DesktopAddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends ConsumerState<DesktopAddSalePage> {
  var _initialized = false;
  late final String _duplicateSessionKey =
      'duplicate_${widget.duplicateFromId}';
  late final String _attachSessionKey =
      'attach_${widget.attachOrderIds?.join('_') ?? ''}';

  bool _supportsTabs(WidgetRef ref) {
    if (ref.read(saleTransactionTotalsSettingsProvider).isLiteSale) {
      return false;
    }
    return widget.invoiceId == null &&
        !widget.readOnly &&
        widget.duplicateFromId == null &&
        widget.attachOrderIds == null;
  }

  String get _sessionKey {
    if (widget.attachOrderIds != null && widget.attachOrderIds!.isNotEmpty) {
      return _attachSessionKey;
    }
    if (widget.duplicateFromId != null) return _duplicateSessionKey;
    if (widget.invoiceId != null) return widget.invoiceId!;
    final partyId = widget.initialPartyId?.trim();
    if (partyId != null && partyId.isNotEmpty) return 'party_$partyId';
    if (_supportsTabs(ref)) {
      return ref.read(saleTabsProvider()).activeTab.sessionKey;
    }
    return 'default';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Warm the inventory catalog so the item picker opens instantly.
      unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
    });
    if (widget.invoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else if (widget.attachOrderIds != null &&
        widget.attachOrderIds!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeAttachForm(),
      );
    } else if (widget.duplicateFromId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
    } else {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_applyTransactionHeaderDefaultsForNewSale());
      });
      final partyId = widget.initialPartyId?.trim();
      final partyName = widget.initialPartyName?.trim();
      if (partyId != null &&
          partyId.isNotEmpty &&
          partyName != null &&
          partyName.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
              .updateParty(partyId: partyId, partyName: partyName);
        });
      }
    }
  }

  Future<void> _applyTransactionHeaderDefaultsForNewSale() async {
    if (widget.invoiceId != null ||
        widget.duplicateFromId != null ||
        (widget.attachOrderIds != null && widget.attachOrderIds!.isNotEmpty)) {
      return;
    }
    await ref.read(saleInvoiceSettingsProvider.future);
    if (!mounted) return;
    ref
        .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
        .applyTransactionHeaderDefaultsForNewDocument();
  }

  Future<void> _initializeAttachForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: _attachSessionKey).notifier)
        .attachSaleOrders(widget.attachOrderIds!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: widget.invoiceId!).notifier)
        .loadDocument(widget.invoiceId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeForm() async {
    await ref
        .read(
          addSaleFormProvider(sessionKey: _duplicateSessionKey).notifier,
        )
        .duplicateDocument(widget.duplicateFromId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  bool get _isEditing => widget.invoiceId != null;

  bool _directBarcodeScanAutofocus(WidgetRef ref) {
    final settings = ref.read(itemSettingsProvider).value;
    if (settings == null || !settings.barcodeScanningEnabled) return false;
    return settings.vyapar.directBarcodeScan;
  }

  String _mergeSerialNo(String existing, String scanned) {
    final parts = parseSaleItemSerialNos(existing);
    if (!parts.contains(scanned)) {
      parts.add(scanned);
    }
    return joinSaleItemSerialNos(parts);
  }

  Future<void> _applyBarcodeCatalogToRow(
    String sessionKey,
    int rowIndex,
    String barcode,
    BarcodeScanHandler handler,
  ) async {
    await handleDocumentBarcodeScanCode(
      barcode,
      context: context,
      ref: ref,
      handler: handler,
      onCatalogItem: (catalog) async {
        await ref
            .read(addSaleFormProvider(sessionKey: sessionKey).notifier)
            .selectCatalogItem(rowIndex, catalog);
      },
    );
  }

  Future<bool> _handleSaleDocumentBarcode(
    String barcode,
    String sessionKey,
  ) async {
    final handler = BarcodeScanHandler(debounce: BarcodeScanHandler.hidDebounce);
    final serialRow = saleDocumentBarcodeSerialRow(ref, sessionKey);
    if (serialRow != null) {
      final result = await handler.process(
        barcode,
        engine: ref.read(inventorySearchEngineProvider),
        items: ref.read(inventoryItemListProvider),
      );
      final notifier = ref.read(
        addSaleFormProvider(sessionKey: sessionKey).notifier,
      );
      if (result.isFound && result.item != null) {
        await notifier.selectCatalogItem(
          serialRow,
          saleItemOptionFromInventory(result.item!),
        );
        if (mounted) {
          showBarcodeAddedSnackBar(context, result.item!.name);
        }
      } else if (result.status != BarcodeScanStatus.debounced &&
          result.status != BarcodeScanStatus.invalid) {
        final form = ref.read(addSaleFormProvider(sessionKey: sessionKey));
        if (serialRow >= 0 && serialRow < form.items.length) {
          final line = form.items[serialRow];
          notifier.updateLineItem(
            serialRow,
            line.copyWith(serialNo: _mergeSerialNo(line.serialNo, result.barcode)),
          );
        }
      }
      setSaleDocumentBarcodeSerialRow(ref, sessionKey, null);
      return true;
    }

    final itemRow = saleDocumentBarcodeItemRow(ref, sessionKey);
    if (itemRow != null) {
      await _applyBarcodeCatalogToRow(sessionKey, itemRow, barcode, handler);
      setSaleDocumentBarcodeItemRow(ref, sessionKey, null);
      return true;
    }

    return false;
  }

  void _resetSaleFormState(String sessionKey) {
    ref.invalidate(addSaleFormProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleSubtotalProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleTotalTaxProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleGrandTotalProvider(sessionKey: sessionKey));
  }

  Future<void> _handleClose() async {
    if (!widget.readOnly) {
      final confirmed = await showCloseFormDialog(
        context,
        title: 'Close Sale',
      );
      if (!confirmed || !mounted) return;
    }
    _resetSaleFormState(_sessionKey);
    _navigateBackToSaleInvoices();
  }

  void _navigateBackToSaleInvoices() {
    returnToTransactionList(context, AppRoutes.saleInvoices);
  }

  void _navigateToSaleInvoices() {
    _resetSaleFormState(_sessionKey);
    _navigateBackToSaleInvoices();
  }

  Future<void> _handleClearForm() async {
    if (widget.readOnly) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear sale'),
        content: const Text(
          'Discard all entered details for this sale?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _resetSaleFormState(_sessionKey);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_applyTransactionHeaderDefaultsForNewSale());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionKey = _sessionKey;
    final supportsTabs = _supportsTabs(ref);
    final isLoading = ref.watch(
      addSaleFormProvider(
        sessionKey: sessionKey,
      ).select((form) => form.isLoading),
    );

    if (!_initialized ||
        (widget.invoiceId != null && isLoading) ||
        (widget.duplicateFromId != null && isLoading) ||
        (widget.attachOrderIds != null && isLoading)) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DocumentBarcodeKeyboardHost(
      enabled: !widget.readOnly,
      autofocus: !widget.readOnly && _directBarcodeScanAutofocus(ref),
      onBarcode: (barcode) => _handleSaleDocumentBarcode(barcode, sessionKey),
      onCatalogItem: (catalog) async {
        clearSaleDocumentBarcodeTargets(ref, sessionKey);
        final form = ref.read(addSaleFormProvider(sessionKey: sessionKey));
        final notifier = ref.read(
          addSaleFormProvider(sessionKey: sessionKey).notifier,
        );
        var index = form.items.lastIndexWhere(isEmptySaleLineDraft);
        if (index < 0) {
          notifier.addLineItem();
          index =
              ref
                  .read(addSaleFormProvider(sessionKey: sessionKey))
                  .items
                  .length -
              1;
        }
        await notifier.selectCatalogItem(index, catalog);
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleClose();
        },
        child: ColoredBox(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (supportsTabs) ...[
                const _SaleTabsActiveFormLabelListener(),
                SaleTabsBar(onFormClose: _handleClose),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(color: _cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    _sectionGap,
                                    _sectionGap,
                                    _sectionGap,
                                    0,
                                  ),
                                  child: _PageHeader(
                                    sessionKey: sessionKey,
                                    readOnly: widget.readOnly,
                                    isEditing: _isEditing,
                                    showTitle: !supportsTabs,
                                    showCloseButton: !supportsTabs,
                                    onClose: _handleClose,
                                    onClear: _handleClearForm,
                                  ),
                                ),
                                const SizedBox(height: _sectionGap),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: _sectionGap,
                                  ),
                                  child: IgnorePointer(
                                    ignoring: widget.readOnly,
                                    child: Opacity(
                                      opacity: widget.readOnly ? 0.85 : 1,
                                      child: _FormFields(
                                        sessionKey: sessionKey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: _sectionGap),
                                IgnorePointer(
                                  ignoring: widget.readOnly,
                                  child: Opacity(
                                    opacity: widget.readOnly ? 0.85 : 1,
                                    child: SaleLineItemsTable(
                                      sessionKey: sessionKey,
                                      embedded: true,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: _cardBorder,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                    _sectionGap,
                                  ),
                                  child: IgnorePointer(
                                    ignoring: widget.readOnly,
                                    child: Opacity(
                                      opacity: widget.readOnly ? 0.85 : 1,
                                      child: AddSaleFooter(
                                        sessionKey: sessionKey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!widget.readOnly) ...[
                          const Divider(height: 1, color: _cardBorder),
                          _BottomActionBar(
                            sessionKey: sessionKey,
                            isEditing: _isEditing,
                            onSaved: _navigateToSaleInvoices,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({
    required this.sessionKey,
    required this.onClose,
    required this.onClear,
    this.readOnly = false,
    this.isEditing = false,
    this.showTitle = true,
    this.showCloseButton = true,
  });

  final String sessionKey;
  final VoidCallback onClose;
  final Future<void> Function() onClear;
  final bool readOnly;
  final bool isEditing;
  final bool showTitle;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: sessionKey).notifier,
    );
    final title = readOnly ? 'View Sale' : (isEditing ? 'Edit Sale' : 'Sale');
    final features = ref.watch(saleTransactionFeaturesProvider);

    return Row(
      children: [
        if (showTitle) ...[
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        if (!readOnly)
          _SaleTypeToggle(
            saleType: form.saleType,
            onChanged: notifier.toggleSaleType,
          ),
        if (!readOnly && features.wholesalePriceToggleOnInvoice) ...[
          const SizedBox(width: AppSpacing.md),
          FilterChip(
            label: const Text('Wholesale price'),
            selected: form.useWholesalePriceOnInvoice,
            onSelected: notifier.setUseWholesalePriceOnInvoice,
            visualDensity: VisualDensity.compact,
          ),
        ],
        const Spacer(),
        if (!readOnly && features.showProfitOnSaleInvoice)
          TextButton.icon(
            onPressed: () => showSaleInvoiceProfitDialog(
              context,
              form: form,
            ),
            icon: const Icon(Icons.trending_up, size: 18),
            label: const Text('Profit'),
          ),
        if (!readOnly) ...[
          _GodownSelector(
            value: form.godown,
            onSelected: notifier.updateGodown,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Clear sale',
            visualDensity: VisualDensity.compact,
          ),
          const _SaleLineItemColumnSettingsButton(),
        ],
        if (showCloseButton)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _SaleLineItemColumnSettingsButton extends ConsumerWidget {
  const _SaleLineItemColumnSettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility = ref.watch(saleLineItemEffectiveColumnVisibilityProvider);
    final notifier = ref.read(
      saleLineItemColumnVisibilityStateProvider.notifier,
    );
    final itemSettings =
        ref.watch(itemSettingsProvider).value ?? ItemSettings.defaults();

    bool isColumnOffered(SaleLineItemColumn column) {
      return switch (column) {
        SaleLineItemColumn.taxPercent || SaleLineItemColumn.taxAmount =>
          itemSettings.itemWiseTax,
        SaleLineItemColumn.discount => itemSettings.itemWiseDiscount,
        _ => true,
      };
    }

    return MenuAnchor(
      alignmentOffset: const Offset(-180, 4),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: const WidgetStatePropertyAll(6),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
      menuChildren: [
        SizedBox(
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final column in SaleLineItemColumn.values)
                if (!column.isSettingsControlled && isColumnOffered(column))
                  _SaleLineItemColumnMenuTile(
                    label: column.label,
                    value: visibility.isVisible(column),
                    onChanged: () => notifier.toggleColumn(column),
                  ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.settings_outlined, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Line item columns',
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}

class _SaleLineItemColumnMenuTile extends StatelessWidget {
  const _SaleLineItemColumnMenuTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (_) => onChanged(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GodownSelector extends ConsumerWidget {
  const _GodownSelector({
    required this.value,
    required this.onSelected,
  });

  final String value;
  final void Function(String name, {String? godownId}) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final options = godownsAsync.maybeWhen(
      data: (godowns) => godowns.map((godown) => godown.name).toList(),
      orElse: () => SaleDropdownOptions.godowns,
    );

    return GodownLabelSelector(
      value: value,
      options: options,
      onSelected: (name) {
        final godowns = ref.read(inventoryGodownsProvider).value ?? [];
        final match = godowns
            .where((godown) => godown.name == name)
            .firstOrNull;
        onSelected(name, godownId: match?.id);
      },
    );
  }
}

class _SaleTypeToggle extends StatelessWidget {
  const _SaleTypeToggle({
    required this.saleType,
    required this.onChanged,
  });

  final SaleType saleType;
  final ValueChanged<SaleType> onChanged;

  static const _trackColor = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _trackColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: 'Credit',
            isActive: saleType == SaleType.credit,
            onTap: () => onChanged(SaleType.credit),
          ),
          _TogglePill(
            label: 'Cash',
            isActive: saleType == SaleType.cash,
            onTap: () => onChanged(SaleType.cash),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields({required this.sessionKey});

  final String sessionKey;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _customerPoDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  void initState() {
    super.initState();
    // Preload party list as soon as the form mounts so data is ready
    // before the user taps the party field.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final partiesAsync = ref.read(partyPickerListProvider);
      if (!partiesAsync.hasValue || (partiesAsync.value?.isEmpty ?? true)) {
        ref.read(partyPickerListProvider.future).ignore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final canViewHiddenLedger = ref
        .watch(permissionServiceProvider)
        .canViewHiddenLedger;
    final partyId = form.partyId;
    final showHiddenLedgerBanner =
        canViewHiddenLedger && partyId != null && partyId.isNotEmpty;
    final hiddenLedgerBanner = showHiddenLedgerBanner
        ? HiddenLedgerSummaryTile(partyId: partyId)
        : null;
    final headerVisibility = ref.watch(saleTransactionHeaderVisibilityProvider);
    final transactionFeatures = ref.watch(saleTransactionFeaturesProvider);
    final isLiteSale = ref.watch(saleTransactionTotalsSettingsProvider).isLiteSale;
    final showEWayBill =
        !isLiteSale && transactionFeatures.showEWayBillNumber;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _narrowBreakpoint;
        final partySearchField = _LabeledField(
          label: 'Customer',
          child: BillingNamePartySearchField(
            value: form.billingName,
            selectedPartyId: form.partyId,
            hasError: form.partyHasError,
            errorMessage: kPartyValidationMessage,
            emptyPlaceholder: 'Search party name',
            onSelected: notifier.updateBillingName,
            onPartySelected: notifier.applyPartyDetails,
            onPartySelectedWithId: (partyId, name) => notifier.updateParty(
              partyId: partyId,
              partyName: name,
            ),
            onPartyCreated: (party) {
              notifier.updateBillingName(party.partyName);
              if (party.phone.isNotEmpty) {
                notifier.updatePhone(party.phone);
              }
              if (party.billingAddress.isNotEmpty) {
                notifier.updateAddresses(billing: party.billingAddress);
              }
              if (party.shippingAddress.isNotEmpty) {
                notifier.updateAddresses(shipping: party.shippingAddress);
              }
              if (ref.read(enableGstinOnPartyProvider) &&
                  party.gstin.isNotEmpty) {
                notifier.updateGstin(party.gstin);
              }
              if (party.email.isNotEmpty) {
                notifier.updateEmail(party.email);
              }
              if (party.state.isNotEmpty) {
                notifier.updateStateOfSupply(party.state);
              }
            },
          ),
        );
        final billingNameOnInvoiceField = !isLiteSale &&
                headerVisibility.showBillingNameOnInvoice
            ? _LabeledField(
                label: 'Billing Name (Optional)',
                child: _SaleTextField(
                  initialValue: form.businessName,
                  hintText: 'Name to print on invoice',
                  onChanged: notifier.updateBusinessName,
                ),
              )
            : null;
        final phoneField = _LabeledField(
          label: 'Phone No.',
          child: _SaleTextField(
            initialValue: form.phone,
            hintText: 'Phone number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            hasError: form.phoneHasError,
            errorText: form.phoneErrorMessage,
            onChanged: notifier.updatePhone,
          ),
        );
        final billingAddressField = _LabeledField(
          label: 'Billing Address',
          child: _SaleTextField(
            initialValue: form.billingAddress,
            hintText: 'Billing address',
            minLines: _addressFieldLines,
            maxLines: _addressFieldLines,
            onChanged: (value) => notifier.updateAddresses(billing: value),
          ),
        );
        final shippingAddressField = _LabeledField(
          label: 'Shipping Address',
          child: _SaleTextField(
            initialValue: form.shippingAddress,
            hintText: 'Shipping address',
            minLines: _addressFieldLines,
            maxLines: _addressFieldLines,
            onChanged: (value) => notifier.updateAddresses(shipping: value),
          ),
        );
        final eWayBillField = showEWayBill
            ? _LabeledField(
                label: 'E-Way Bill No.',
                child: _SaleTextField(
                  initialValue: form.eWayBillNo,
                  hintText: 'E-Way bill number',
                  onChanged: notifier.updateEWayBillNo,
                ),
              )
            : null;

        final invoiceDetails = _InvoiceDetailsFields(
          sessionKey: widget.sessionKey,
          invoiceDatePickerKey: _invoiceDatePickerKey,
          dueDatePickerKey: _dueDatePickerKey,
          customerPoDatePickerKey: _customerPoDatePickerKey,
        );

        final partyDetails = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      partySearchField,
                      if (billingNameOnInvoiceField != null) ...[
                        const SizedBox(height: _sectionGap),
                        billingNameOnInvoiceField,
                      ],
                      const SizedBox(height: _sectionGap),
                      phoneField,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: _billingNameRowFlex,
                        child: partySearchField,
                      ),
                      if (billingNameOnInvoiceField != null) ...[
                        const SizedBox(width: _sectionGap),
                        Expanded(
                          flex: _billingNameRowFlex,
                          child: billingNameOnInvoiceField,
                        ),
                      ],
                      const SizedBox(width: _sectionGap),
                      Expanded(flex: _phoneRowFlex, child: phoneField),
                      Expanded(
                        flex: _phoneRowTrailingSpacerFlex,
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
            if (hiddenLedgerBanner != null) ...[
              const SizedBox(height: _sectionGap),
              hiddenLedgerBanner,
            ],
            if (!isLiteSale) ...[
              const SizedBox(height: _sectionGap),
              isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        billingAddressField,
                        const SizedBox(height: _sectionGap),
                        shippingAddressField,
                        if (eWayBillField != null) ...[
                          const SizedBox(height: _sectionGap),
                          eWayBillField,
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: _billingAddressRowFlex,
                          child: billingAddressField,
                        ),
                        const SizedBox(width: _sectionGap),
                        Expanded(
                          flex: _billingAddressRowFlex,
                          child: shippingAddressField,
                        ),
                        if (eWayBillField != null) ...[
                          const SizedBox(width: _sectionGap),
                          Expanded(flex: _eWayBillRowFlex, child: eWayBillField),
                        ],
                        Expanded(
                          flex: _addressRowTrailingSpacerFlex,
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    ),
            ],
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              partyDetails,
              const SizedBox(height: _sectionGap),
              invoiceDetails,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: partyDetails),
            const SizedBox(width: _sectionGap),
            SizedBox(width: _invoiceMetaWidth, child: invoiceDetails),
          ],
        );
      },
    );
  }
}

class _InvoiceDetailsFields extends ConsumerWidget {
  const _InvoiceDetailsFields({
    required this.sessionKey,
    required this.invoiceDatePickerKey,
    required this.dueDatePickerKey,
    required this.customerPoDatePickerKey,
  });

  final String sessionKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> invoiceDatePickerKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> dueDatePickerKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> customerPoDatePickerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerVisibility = ref.watch(saleTransactionHeaderVisibilityProvider);
    final transactionFeatures = ref.watch(saleTransactionFeaturesProvider);
    final isLiteSale = ref.watch(saleTransactionTotalsSettingsProvider).isLiteSale;
    final paymentTermOptions = ref.watch(salePaymentTermNameOptionsProvider);
    final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: sessionKey).notifier,
    );
    final isAutoNumber = form.invoiceNumberMode == InvoiceNumberMode.auto;
    final preview = watchDocumentNumberPreview(
      ref,
      SalesConstants.defaultDocumentSeries,
    );
    final displayNumber = resolveDocumentNumberDisplay(
      documentId: form.documentId,
      currentNumber: form.invoiceNumber,
      preview: preview,
      forceAuto: isAutoNumber,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headerVisibility.showInvoiceBillNumber) ...[
          _LabeledField(
            label: 'Invoice Number',
            child: _SaleTextField(
              initialValue: displayNumber,
              hintText: 'Invoice number',
              readOnly: true,
              filled: true,
              compact: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: _sectionGap),
        ],
        _LabeledField(
          label: 'Invoice Date',
          child: SaleSingleDatePickerAnchor(
            key: invoiceDatePickerKey,
            selectedDate: form.invoiceDate,
            onDateSelected: notifier.updateInvoiceDate,
            child: _PickerField(
              value: formatSaleSingleDate(form.invoiceDate),
              icon: Icons.calendar_today_outlined,
              compact: true,
              onTap: () => invoiceDatePickerKey.currentState?.toggle(),
            ),
          ),
        ),
        if (headerVisibility.showTransactionTime) ...[
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'Time',
            child: SaleTimeDropdown(
              value: form.invoiceTime,
              compact: true,
              onSelected: notifier.updateInvoiceTime,
            ),
          ),
        ],
        if (form.saleType == SaleType.credit &&
            transactionFeatures.dueDatesAndPaymentTerms) ...[
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'Payment Terms',
            child: SaleGenericSelectDropdown(
              value: form.paymentTerms,
              options: paymentTermOptions.isNotEmpty
                  ? paymentTermOptions
                  : SaleDropdownOptions.paymentTerms,
              hintText: 'Select terms',
              maxMenuHeight: 280,
              compact: true,
              onSelected: notifier.updatePaymentTerms,
            ),
          ),
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'Due Date',
            child: SaleSingleDatePickerAnchor(
              key: dueDatePickerKey,
              selectedDate: form.dueDate,
              onDateSelected: notifier.updateDueDate,
              child: _PickerField(
                value: form.dueDate != null
                    ? formatSaleSingleDate(form.dueDate)
                    : 'Select Date',
                icon: Icons.calendar_today_outlined,
                isPlaceholder: form.dueDate == null,
                compact: true,
                onTap: () => dueDatePickerKey.currentState?.toggle(),
              ),
            ),
          ),
        ],
        if (!isLiteSale) ...[
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'State of supply',
            child: SaleGenericSelectDropdown(
              value: form.stateOfSupply,
              options: SaleDropdownOptions.indianStates,
              hintText: 'Select state',
              maxMenuHeight: 280,
              compact: true,
              onSelected: notifier.updateStateOfSupply,
            ),
          ),
        ],
        if (!isLiteSale && headerVisibility.showCustomerPoDetails) ...[
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'Customer P.O. No.',
            child: _SaleTextField(
              initialValue: form.customerPoNumber,
              hintText: 'PO number',
              compact: true,
              onChanged: notifier.updateCustomerPoNumber,
            ),
          ),
          const SizedBox(height: _sectionGap),
          _LabeledField(
            label: 'Customer P.O. Date',
            child: SaleSingleDatePickerAnchor(
              key: customerPoDatePickerKey,
              selectedDate: form.customerPoDate,
              onDateSelected: notifier.updateCustomerPoDate,
              child: _PickerField(
                value: form.customerPoDate != null
                    ? formatSaleSingleDate(form.customerPoDate)
                    : 'Select Date',
                icon: Icons.calendar_today_outlined,
                isPlaceholder: form.customerPoDate == null,
                compact: true,
                onTap: () => customerPoDatePickerKey.currentState?.toggle(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomActionBar extends ConsumerStatefulWidget {
  const _BottomActionBar({
    required this.sessionKey,
    required this.onSaved,
    this.isEditing = false,
  });

  final String sessionKey;
  final VoidCallback onSaved;
  final bool isEditing;

  @override
  ConsumerState<_BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends ConsumerState<_BottomActionBar> {
  /// Synchronous guard — blocks duplicate taps before async dialogs / isSaving.
  bool _submitInFlight = false;

  Future<void> _runExclusive(Future<void> Function() action) async {
    if (_submitInFlight) return;
    _submitInFlight = true;
    try {
      await action();
    } finally {
      _submitInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addSaleFormProvider(sessionKey: widget.sessionKey));
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final isBusy = _submitInFlight || form.isSaving;
    final isCash = form.saleType == SaleType.cash;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < _narrowBreakpoint;
          final printButton = !isCash
              ? OutlinedButton.icon(
                  onPressed: isBusy ? null : () => _handlePrintPreview(context),
                  icon: const Icon(Icons.print_outlined, size: 16),
                  label: const Text(
                    'Print / Preview',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: _cardBorder),
                  ),
                )
              : null;
          final shareButton = ShareMenuButton(
            onChannelSelected: isBusy
                ? null
                : (_) => _runExclusive(() => _handleSaveAndShare(context)),
          );
          final saveButton = FilledButton(
            onPressed: isBusy
                ? null
                : () => _runExclusive(() => _handleSave(context, notifier)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
            ),
            child: isBusy
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Saving...', style: TextStyle(fontSize: 13)),
                    ],
                  )
                : const Text('Save', style: TextStyle(fontSize: 13)),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (printButton != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: printButton,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(
                  children: [
                    shareButton,
                    const Spacer(),
                    saveButton,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              ?printButton,
              const Spacer(),
              shareButton,
              const SizedBox(width: AppSpacing.sm),
              saveButton,
            ],
          );
        },
      ),
    );
  }

  String? _documentIdForForm(AddSaleFormState form) => form.documentId;

  String _filename(AddSaleFormState form) {
    final number = form.invoiceNumber.trim();
    if (number.isNotEmpty) {
      return SaleInvoicePrintActions.filenameFor(number);
    }
    final id = _documentIdForForm(form);
    return id == null ? 'invoice' : SaleInvoicePrintActions.filenameFor(id);
  }

  Future<void> _handlePrintPreview(BuildContext context) async {
    final form = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey));
    final docId = _documentIdForForm(form);
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the invoice before printing')),
      );
      return;
    }
    await SaleInvoicePrintActions.preview(
      context,
      ref,
      docId,
      filename: _filename(form),
    );
  }

  Future<({String? shortPaymentHandling, double? shortfallAmount})>
  _resolveShortPaymentHandling(BuildContext context) async {
    final form = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey));
    if (!form.hasShortPayment) {
      return (shortPaymentHandling: null, shortfallAmount: null);
    }

    final paidAmount = form.displayReceivedAmount;
    final allowHiddenLedger = ref
        .read(permissionServiceProvider)
        .canViewHiddenLedger;

    final handling = await showShortPaymentHandlingDialog(
      context,
      paidAmount: paidAmount,
      targetAmount: form.invoiceTotal,
      allowHiddenLedger: allowHiddenLedger,
    );
    if (handling == null) {
      return (shortPaymentHandling: null, shortfallAmount: null);
    }

    final shortfall = (form.invoiceTotal - paidAmount)
        .clamp(0, double.infinity)
        .toDouble();
    return (
      shortPaymentHandling: handling.apiValue,
      shortfallAmount: handling == ShortPaymentHandling.hiddenLedger
          ? shortfall
          : null,
    );
  }

  Future<double?> _resolveHiddenLedgerRecovery(BuildContext context) async {
    if (!ref.read(permissionServiceProvider).canViewHiddenLedger) return 0;

    final form = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey));
    if (!form.hasRecoverableMarkup) return 0;

    final result = await showHiddenLedgerRecoveryDialog(
      context,
      hiddenBalance: form.hiddenLedgerBalance,
      markupAmount: form.markupAmount,
    );
    if (result == null) return null;
    if (result.choice == HiddenLedgerRecoveryChoice.ignore) return 0;
    return result.amount;
  }

  Future<void> _handleSaveAndShare(BuildContext context) async {
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );

    final shortPayment = await _resolveShortPaymentHandling(context);
    if (!context.mounted) return;
    final latestForm = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    if (latestForm.hasShortPayment &&
        shortPayment.shortPaymentHandling == null) {
      return;
    }

    final recoveryAmount = await _resolveHiddenLedgerRecovery(context);
    if (!context.mounted) return;
    if (latestForm.hasRecoverableMarkup && recoveryAmount == null) {
      return;
    }

    final result = await notifier.saveInvoice(
      shortPaymentHandling: shortPayment.shortPaymentHandling,
      shortfallAmount: shortPayment.shortfallAmount,
      hiddenLedgerRecoveryAmount: recoveryAmount ?? 0,
    );
    if (!context.mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    await _showSaveSuccessDialog(
      context,
      isEditing: widget.isEditing,
      earnedLoyaltyPoints: result.earnedLoyaltyPoints,
      pointsAvailable: result.pointsAvailable,
    );
    if (!context.mounted) return;
    final saved = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey));
    final docId = saved.documentId;
    if (docId == null) {
      widget.onSaved();
      return;
    }
    await SaleInvoicePrintActions.share(
      context,
      ref,
      docId,
      filename: _filename(saved),
    );
    if (context.mounted) widget.onSaved();
  }

  Future<void> _handleSave(
    BuildContext context,
    AddSaleForm notifier,
  ) async {
    final shortPayment = await _resolveShortPaymentHandling(context);
    if (!context.mounted) return;
    final latestForm = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    if (latestForm.hasShortPayment &&
        shortPayment.shortPaymentHandling == null) {
      return;
    }

    final recoveryAmount = await _resolveHiddenLedgerRecovery(context);
    if (!context.mounted) return;
    if (latestForm.hasRecoverableMarkup && recoveryAmount == null) {
      return;
    }

    final result = await notifier.saveInvoice(
      shortPaymentHandling: shortPayment.shortPaymentHandling,
      shortfallAmount: shortPayment.shortfallAmount,
      hiddenLedgerRecoveryAmount: recoveryAmount ?? 0,
    );
    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    final saved = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey));
    final docId = saved.documentId;
    final showPreview = ref.read(saleTransactionFeaturesProvider).showInvoicePreviewOnSave;

    if (!widget.isEditing &&
        showPreview &&
        docId != null &&
        docId.isNotEmpty) {
      await SaleInvoicePrintActions.preview(
        context,
        ref,
        docId,
        filename: _filename(saved),
      );
      if (!context.mounted) return;
    }

    await _showSaveSuccessDialog(
      context,
      isEditing: widget.isEditing,
      earnedLoyaltyPoints: result.earnedLoyaltyPoints,
      pointsAvailable: result.pointsAvailable,
    );
    if (!context.mounted) return;
    widget.onSaved();
  }

  Future<void> _showSaveSuccessDialog(
    BuildContext context, {
    required bool isEditing,
    int earnedLoyaltyPoints = 0,
    double pointsAvailable = 0,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Sale Updated' : 'Sale Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'Sale updated successfully.'
                  : 'Sale created successfully.',
            ),
            if (earnedLoyaltyPoints > 0) ...[
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '⭐',
                            style: AppTypography.inter(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loyalty Points Earned',
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$earnedLoyaltyPoints',
                        style: AppTypography.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (pointsAvailable > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Total available: ${pointsAvailable == pointsAvailable.roundToDouble() ? pointsAvailable.toInt() : pointsAvailable.toStringAsFixed(0)} points',
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: saleFieldLabelStyle,
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _SaleTextField extends StatefulWidget {
  const _SaleTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.filled = false,
    this.compact = false,
    this.hasError = false,
    this.errorText,
    this.inputFormatters,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final bool filled;
  final bool compact;
  final bool hasError;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_SaleTextField> createState() => _SaleTextFieldState();
}

class _SaleTextFieldState extends State<_SaleTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SaleTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSingleLine = widget.minLines <= 1 && widget.maxLines <= 1;
    if (isSingleLine) {
      return SaleTextField(
        controller: _controller,
        hint: widget.hintText,
        hasError: widget.hasError,
        compact: widget.compact,
        filled: widget.filled,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
      );
    }

    return TextField(
      controller: _controller,
      readOnly: widget.readOnly,
      style: saleFieldTextStyle.copyWith(
        fontSize: widget.compact ? 13 : 14,
      ),
      decoration:
          buildSaleFieldDecoration(
            hint: widget.hintText,
            filled: widget.filled,
            compact: widget.compact,
            hasError: widget.hasError,
            fixedHeight: false,
          ).copyWith(
            errorText: widget.hasError ? widget.errorText : null,
          ),
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
    this.compact = false,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      compact: compact,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: saleFieldTextStyle.copyWith(
                fontSize: compact ? 13 : 14,
                color: isPlaceholder ? saleFieldErrorColor : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            icon,
            size: compact ? 14 : 15,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Keeps tab titles in sync without conditional [ref.listen] in [AddSalePage.build].
class _SaleTabsActiveFormLabelListener extends ConsumerWidget {
  const _SaleTabsActiveFormLabelListener();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(saleTabsProvider());
    final activeSessionKey = tabsState.activeTab.sessionKey;

    ref.listen(
      addSaleFormProvider(sessionKey: activeSessionKey),
      (previous, next) {
        if (previous?.saleType == next.saleType &&
            previous?.billingName == next.billingName) {
          return;
        }
        ref.read(saleTabsProvider().notifier).updateTabLabel(
              tabsState.activeIndex,
              saleTabLabelForForm(
                saleNumber: tabsState.activeTab.saleNumber,
                billingName: next.billingName,
              ),
            );
      },
    );

    return const SizedBox.shrink();
  }
}
