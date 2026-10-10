import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/default_inventory_units.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/utils/item_unit_qty_conversion.dart';
import 'package:billing_baba/features/inventory/utils/min_wholesale_qty_units.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum AdjustStockFormVariant { mobile, desktop }

/// Shared adjust-stock form — compact vertical (mobile) or horizontal (desktop).
class AdjustStockForm extends ConsumerStatefulWidget {
  const AdjustStockForm({
    required this.item,
    this.onSuccess,
    this.variant = AdjustStockFormVariant.mobile,
    this.onClose,
    super.key,
  });

  final InventoryItem item;
  final VoidCallback? onSuccess;
  final AdjustStockFormVariant variant;
  final VoidCallback? onClose;

  @override
  ConsumerState<AdjustStockForm> createState() => _AdjustStockFormState();
}

class _AdjustStockFormState extends ConsumerState<AdjustStockForm> {
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  String? _godownId;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAddStock = true;
  DateTime _adjustmentDate = DateTime.now();
  String? _baseUnitId;
  String? _secondaryUnitId;
  String? _selectedQtyUnitId;
  bool _unitsHydrated = false;
  List<String> _linkedUnitIds = const [];

  static final _displayDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final purchasePrice = widget.item.purchasePrice;
    if (purchasePrice != null && purchasePrice > 0) {
      _costController.text = _formatDecimal(purchasePrice);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(inventoryGodownsProvider).value;
      if (current == null || current.isEmpty) {
        unawaited(ref.read(inventoryGodownsProvider.notifier).refresh());
      }
      _hydrateUnitIds(ref.read(inventoryUnitsProvider).value ?? catalogInventoryUnits());
      unawaited(_hydrateBaseUnitFromDetail());
    });
  }

  Future<void> _hydrateBaseUnitFromDetail() async {
    if (_baseUnitId != null) return;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final detail = await service.fetchItemDetailDto(widget.item.id);
      if (!mounted) return;
      _hydrateUnitIds(
        ref.read(inventoryUnitsProvider).value ?? catalogInventoryUnits(),
        baseUnitShortName: detail.baseUnit,
      );
    } on Object {
      // List item fields are enough when detail is unavailable offline.
    }
  }

  void _hydrateUnitIds(
    List<InventoryUnit> units, {
    String? baseUnitShortName,
  }) {
    final shortName = baseUnitShortName ?? widget.item.baseUnitShortName;
    final baseId = resolveInventoryUnitIdByShortName(units, shortName);
    if (baseId == null) return;
    if (_baseUnitId == baseId && _unitsHydrated) return;

    final secondaryId = inferItemSecondaryUnitId(
      allUnits: units,
      baseUnitId: baseId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _baseUnitId = baseId;
        _secondaryUnitId = secondaryId;
        _selectedQtyUnitId ??= baseId;
        _unitsHydrated = true;
      });
      if (secondaryId == null || _linkedUnitIds.isEmpty) {
        unawaited(_loadBaseUnitConversions(baseId));
      }
    });
  }

  Future<void> _loadBaseUnitConversions(String baseUnitId) async {
    final detail = await ref
        .read(inventoryUnitsProvider.notifier)
        .loadUnitDetail(baseUnitId);
    var conversions = detail?.conversions ?? const <UnitConversion>[];
    if (conversions.isEmpty) {
      try {
        final service = await ref.read(inventoryServiceProvider.future);
        final forward = await service.fetchUnitConversions(
          fromUnitId: baseUnitId,
          limit: 50,
        );
        final reverse = await service.fetchUnitConversions(
          toUnitId: baseUnitId,
          limit: 50,
        );
        conversions = [...forward, ...reverse];
      } on Object {
        // Offline or missing conversions — keep the item's base unit only.
      }
    }
    if (!mounted) return;

    final units = [
      if (detail != null) detail.copyWith(conversions: conversions),
      ...?ref.read(inventoryUnitsProvider).value,
    ];
    var secondaryId = inferItemSecondaryUnitId(
      allUnits: units,
      baseUnitId: baseUnitId,
    );
    secondaryId ??= conversions
        .map((conversion) {
          if (conversion.toUnitId != null && conversion.toUnitId != baseUnitId) {
            return conversion.toUnitId;
          }
          if (conversion.fromUnitId != null &&
              conversion.fromUnitId != baseUnitId) {
            return conversion.fromUnitId;
          }
          return null;
        })
        .whereType<String>()
        .firstOrNull;
    final linkedIds = linkedUnitIdsFromConversions(
      baseUnitId: baseUnitId,
      conversions: conversions,
    );
    if (listEquals(linkedIds, _linkedUnitIds) && secondaryId == _secondaryUnitId) {
      return;
    }
    setState(() {
      _linkedUnitIds = linkedIds;
      if (secondaryId != null) {
        _secondaryUnitId = secondaryId;
      } else if (_secondaryUnitId == null && linkedIds.isNotEmpty) {
        _secondaryUnitId = linkedIds.first;
      }
    });
  }

  String? _secondaryUnitIdForQtyConversion(String? displayUnitId) {
    final baseUnitId = _baseUnitId;
    if (baseUnitId == null || displayUnitId == null) return _secondaryUnitId;
    if (displayUnitId == baseUnitId) return _secondaryUnitId;
    return displayUnitId;
  }

  double? _baseToSecondaryRateForDisplay(
    List<InventoryUnit> units,
    String? displayUnitId,
  ) {
    final baseUnitId = _baseUnitId;
    if (baseUnitId == null) return null;
    final secondaryId = _secondaryUnitIdForQtyConversion(displayUnitId);
    return resolveBaseToSecondaryRate(
      units: units,
      baseUnitId: baseUnitId,
      secondaryUnitId: secondaryId,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }

  double? _signedQuantityDelta(List<InventoryUnit> units) {
    final magnitude = double.tryParse(_quantityController.text.trim());
    if (magnitude == null || magnitude == 0) return null;
    final absolute = magnitude.abs();

    final baseUnitId = _baseUnitId;
    final displayUnitId = _selectedQtyUnitId ?? baseUnitId;
    final baseMagnitude = baseUnitId == null || displayUnitId == null
        ? absolute
        : qtyInBaseUnit(
            qty: absolute,
            qtyUnitId: displayUnitId,
            baseUnitId: baseUnitId,
            secondaryUnitId: _secondaryUnitIdForQtyConversion(displayUnitId),
            baseToSecondaryRate: _baseToSecondaryRateForDisplay(
              units,
              displayUnitId,
            ),
          );

    return _isAddStock ? baseMagnitude : -baseMagnitude;
  }

  DateTime _adjustmentTimestamp() {
    final now = DateTime.now();
    return DateTime(
      _adjustmentDate.year,
      _adjustmentDate.month,
      _adjustmentDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final units =
        ref.read(inventoryUnitsProvider).value ?? catalogInventoryUnits();
    final delta = _signedQuantityDelta(units);
    if (delta == null) {
      setState(() => _errorMessage = 'Enter a non-zero quantity.');
      return;
    }

    if (_godownId == null) {
      setState(() => _errorMessage = 'Select a godown.');
      return;
    }

    final costText = _costController.text.trim();
    final cost = costText.isEmpty ? null : double.tryParse(costText);
    if (delta > 0 && cost == null) {
      setState(
        () => _errorMessage = 'At price is required when adding stock.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final unitOptions = itemStockQtyUnitOptions(
        allUnits: units,
        baseUnitId: _baseUnitId,
        baseUnitShortName: widget.item.baseUnitShortName,
        secondaryUnitId: _secondaryUnitId,
        additionalUnitIds: _linkedUnitIds,
      );
      final unitShortName = minWholesaleQtyUnitShortName(
        options: unitOptions,
        selectedUnitId: _selectedQtyUnitId,
        fallbackBaseUnitId: _baseUnitId,
      );

      await service.createMovement(
        CreateMovementRequest(
          itemId: widget.item.id,
          godownId: _godownId!,
          movementType: 'adjustment',
          quantityDelta: _formatDecimal(delta),
          costPerUnit: cost != null ? _formatDecimal(cost) : null,
          notes: _notesController.text.trim(),
          unit: unitShortName,
          adjustmentAt: _adjustmentTimestamp(),
        ),
      );

      final currentQty = widget.item.quantity ?? 0;
      ref
          .read(inventoryItemsProvider.notifier)
          .patchItemQuantity(widget.item.id, currentQty + delta);

      await ref
          .read(inventoryItemsProvider.notifier)
          .refreshAfterStockAdjustment(widget.item.id);

      if (!mounted) return;
      widget.onSuccess?.call();
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = InventoryErrorMapper.messageFor(error);
      });
    }
  }

  Future<void> _pickAdjustmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _adjustmentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _adjustmentDate = picked);
    }
  }

  void _syncDefaultGodown(List<GodownModel> godowns) {
    if (_godownId != null) return;
    if (godowns.isEmpty) return;
    final defaultGodown = godowns.where((g) => g.isDefault).firstOrNull;
    _godownId = defaultGodown?.id ?? godowns.first.id;
  }

  void _onQtyUnitSelected(String unitId, List<InventoryUnit> units) {
    final baseUnitId = _baseUnitId;
    if (baseUnitId == null) {
      setState(() => _selectedQtyUnitId = unitId);
      return;
    }

    final fromUnitId = _selectedQtyUnitId ?? baseUnitId;
    final displayQty = double.tryParse(_quantityController.text.trim()) ?? 0;
    final baseQty = qtyInBaseUnit(
      qty: displayQty,
      qtyUnitId: fromUnitId,
      baseUnitId: baseUnitId,
      secondaryUnitId: _secondaryUnitIdForQtyConversion(fromUnitId),
      baseToSecondaryRate: _baseToSecondaryRateForDisplay(units, fromUnitId),
    );
    final newDisplay = qtyFromBaseUnit(
      baseQty: baseQty,
      displayUnitId: unitId,
      baseUnitId: baseUnitId,
      secondaryUnitId: _secondaryUnitIdForQtyConversion(unitId),
      baseToSecondaryRate: _baseToSecondaryRateForDisplay(units, unitId),
    );
    setState(() {
      _selectedQtyUnitId = unitId;
      _quantityController.text = formatItemQtyFieldValue(newDisplay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final godowns = godownsAsync.value ?? [];
    final unitsAsync = ref.watch(inventoryUnitsProvider);
    final units = unitsAsync.value ?? catalogInventoryUnits();
    ref.listen(inventoryUnitsProvider, (_, next) {
      final loaded = next.value;
      if (loaded != null) _hydrateUnitIds(loaded);
    });
    _syncDefaultGodown(godowns);

    if (widget.variant == AdjustStockFormVariant.desktop) {
      return _buildDesktop(context, godownsAsync, units);
    }
    return _buildMobile(godownsAsync);
  }

  Widget _buildMobile(AsyncValue<List<GodownModel>> godownsAsync) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Quantity', style: saleFieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          ],
          decoration: buildSaleFieldDecoration(hint: 'e.g., 5 or 10'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildAddReduceToggle(compact: true),
        const SizedBox(height: AppSpacing.md),
        const Text('Godown', style: saleFieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        _buildGodownField(godownsAsync),
        const SizedBox(height: AppSpacing.md),
        const Text('Cost per unit (for +qty)', style: saleFieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: buildSaleFieldDecoration(
            hint: 'Optional for reductions',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Notes (optional)', style: saleFieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _notesController,
          maxLength: 500,
          maxLines: 2,
          decoration: buildSaleFieldDecoration(hint: 'Reason for adjustment'),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 12, color: saleFieldErrorColor),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: inventoryButtonHeight,
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: inventoryNegativeColor,
              foregroundColor: Colors.white,
            ),
            child: _saveButtonChild('Apply Adjustment'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    AsyncValue<List<GodownModel>> godownsAsync,
    List<InventoryUnit> units,
  ) {
    final unitOptions = itemStockQtyUnitOptions(
      allUnits: units,
      baseUnitId: _baseUnitId,
      baseUnitShortName: widget.item.baseUnitShortName,
      secondaryUnitId: _secondaryUnitId,
      additionalUnitIds: _linkedUnitIds,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackFields = constraints.maxWidth < 720;
        final theme = Theme.of(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDesktopHeader(theme),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: stackFields
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildItemNameField(theme),
                        const SizedBox(height: AppSpacing.md),
                        _buildGodownField(godownsAsync),
                        const SizedBox(height: AppSpacing.md),
                        _buildDateField(theme),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(flex: 5, child: _buildItemNameField(theme)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: _buildGodownField(godownsAsync),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 3, child: _buildDateField(theme)),
                      ],
                    ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: stackFields
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQtyWithUnitRow(
                          unitOptions: unitOptions,
                          units: units,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildAtPriceField(),
                        const SizedBox(height: AppSpacing.md),
                        _buildDetailsField(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 21,
                          child: _buildQtyWithUnitRow(
                            unitOptions: unitOptions,
                            units: units,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 18, child: _buildAtPriceField()),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 32, child: _buildDetailsField()),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  if (_errorMessage != null)
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: saleFieldErrorColor,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  _buildSaveButton(theme),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Stock Adjustment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          _buildAddReduceToggle(compact: false, theme: theme),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildAddReduceToggle({
    required bool compact,
    ThemeData? theme,
  }) {
    final textTheme = theme?.textTheme ?? Theme.of(context).textTheme;
    final addStyle = textTheme.bodyMedium?.copyWith(
      fontSize: compact ? 13 : 14,
      fontWeight: _isAddStock ? FontWeight.w600 : FontWeight.w500,
      color: _isAddStock ? AppColors.primary : AppColors.textSecondary,
    );
    final reduceStyle = textTheme.bodyMedium?.copyWith(
      fontSize: compact ? 13 : 14,
      fontWeight: !_isAddStock ? FontWeight.w600 : FontWeight.w500,
      color: !_isAddStock ? AppColors.primary : AppColors.textSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Add Stock', style: addStyle),
        const SizedBox(width: AppSpacing.sm),
        Transform.scale(
          scale: compact ? 0.8 : 0.85,
          child: Switch.adaptive(
            // Thumb left = Add Stock, thumb right = Reduce Stock.
            value: !_isAddStock,
            onChanged: (value) => setState(() => _isAddStock = !value),
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStatePropertyAll(
              AppColors.primary.withValues(alpha: 0.45),
            ),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Reduce Stock', style: reduceStyle),
      ],
    );
  }

  Widget _buildItemNameField(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Item Name',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGodownField(AsyncValue<List<GodownModel>> godownsAsync) {
    return godownsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (error, _) => Text(
        InventoryErrorMapper.messageFor(error),
        style: const TextStyle(fontSize: 12, color: saleFieldErrorColor),
      ),
      data: (loadedGodowns) {
        if (loadedGodowns.isEmpty) {
          return const Text(
            'No godown found. Add a godown first.',
            style: TextStyle(fontSize: 12, color: saleFieldErrorColor),
          );
        }
        return DropdownButtonFormField<String>(
          value: _godownId,
          isExpanded: true,
          items: loadedGodowns
              .map(
                (godown) => DropdownMenuItem<String>(
                  value: godown.id,
                  child: Text(
                    godown.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _godownId = value),
          decoration: buildSaleFieldDecoration(labelText: 'Godown'),
        );
      },
    );
  }

  Widget _buildDateField(ThemeData theme) {
    return InkWell(
      onTap: _pickAdjustmentDate,
      borderRadius: AppRadius.mdBorder,
      child: InputDecorator(
        decoration: buildSaleFieldDecoration(
          labelText: 'Adjustment Date',
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
        child: Text(
          _displayDateFormat.format(_adjustmentDate),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyField() {
    return TextField(
      controller: _quantityController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(labelText: 'Total Qty'),
    );
  }

  Widget _buildQtyWithUnitRow({
    required List<InventoryUnit> unitOptions,
    required List<InventoryUnit> units,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildQtyField()),
        const SizedBox(width: AppSpacing.sm),
        _buildUnitPicker(unitOptions: unitOptions, units: units),
      ],
    );
  }

  Widget _buildUnitPicker({
    required List<InventoryUnit> unitOptions,
    required List<InventoryUnit> units,
  }) {
    final shortNameOptions = unitOptions
        .map((unit) => unit.shortName)
        .where((name) => name.trim().isNotEmpty)
        .toList();
    if (shortNameOptions.isEmpty) {
      final fallback = widget.item.baseUnitShortName?.trim();
      if (fallback == null || fallback.isEmpty) {
        return const SizedBox.shrink();
      }
      shortNameOptions.add(fallback);
    }

    final selectedShortName =
        minWholesaleQtyUnitShortName(
          options: unitOptions,
          selectedUnitId: _selectedQtyUnitId,
          fallbackBaseUnitId: _baseUnitId,
        ) ??
        shortNameOptions.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: 88,
        child: SaleGenericSelectDropdown(
          borderless: true,
          compact: true,
          triggerHeight: saleFieldHeight - 20,
          value: selectedShortName,
          options: shortNameOptions,
          onSelected: (shortName) {
            final unit = unitOptions.firstWhereOrNull(
              (entry) => entry.shortName == shortName,
            );
            if (unit != null) {
              _onQtyUnitSelected(unit.id, units);
              return;
            }
            final byCatalog = units.firstWhereOrNull(
              (entry) => entry.shortName == shortName,
            );
            if (byCatalog != null) {
              _onQtyUnitSelected(byCatalog.id, units);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAtPriceField() {
    return TextField(
      controller: _costController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(labelText: 'At Price'),
    );
  }

  Widget _buildDetailsField() {
    return TextField(
      controller: _notesController,
      maxLength: 500,
      buildCounter:
          (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => null,
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(labelText: 'Details'),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return FilledButton(
      onPressed: _isLoading ? null : _submit,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        minimumSize: const Size(0, saleFieldHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
      child: _saveButtonChild('Save'),
    );
  }

  Widget _saveButtonChild(String label) {
    if (_isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Text(label);
  }
}
