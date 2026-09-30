import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart'
    show InventoryUnit, resolveDefaultPcsUnit;
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_unit_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_searchable_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Label + gap above unit dropdown triggers (matches [_UnitField]).
const _unitDropdownTopInset = 27.0;

const _conversionLabelStyle = TextStyle(
  fontSize: 14,
  height: 1,
  color: AppColors.textPrimary,
);

class UnitSelection {
  const UnitSelection({this.baseUnitId, this.secondaryUnitId});

  final String? baseUnitId;
  final String? secondaryUnitId;
}

Future<UnitSelection?> showSelectUnitDialog(
  BuildContext context, {
  String? initialBaseUnitId,
  String? initialSecondaryUnitId,
}) {
  return showFormDialog<UnitSelection>(
    context: context,
    size: FormDialogSize.medium,
    child: SelectUnitDialog(
      initialBaseUnitId: initialBaseUnitId,
      initialSecondaryUnitId: initialSecondaryUnitId,
    ),
  );
}

class SelectUnitDialog extends ConsumerStatefulWidget {
  const SelectUnitDialog({
    this.initialBaseUnitId,
    this.initialSecondaryUnitId,
    super.key,
  });

  final String? initialBaseUnitId;
  final String? initialSecondaryUnitId;

  @override
  ConsumerState<SelectUnitDialog> createState() => _SelectUnitDialogState();
}

class _SelectUnitDialogState extends ConsumerState<SelectUnitDialog> {
  final _rateController = TextEditingController(text: '0');

  String? _baseUnitId;
  String? _secondaryUnitId;
  String? _existingConversionId;
  var _conversionStoredFromBase = true;
  String? _errorMessage;
  var _isSaving = false;
  var _loadingConversionRate = false;

  static const _newUnitOption = 'New Unit';

  @override
  void initState() {
    super.initState();
    _baseUnitId = widget.initialBaseUnitId;
    _secondaryUnitId = widget.initialSecondaryUnitId;
    if (_secondaryUnitId != null && _secondaryUnitId == _baseUnitId) {
      _secondaryUnitId = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyDefaultBaseUnitIfNeeded(ref.read(unitsProvider));
      unawaited(_loadConversionRateForPair());
    });
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _createUnit() async {
    final created = await showAddUnitDialog(context);
    if (!mounted || created == null) return;
    setState(() => _baseUnitId = created.id);
    unawaited(_loadConversionRateForPair());
  }

  void _onBaseUnitSelected(List<InventoryUnit> units, String label) {
    if (label == _newUnitOption) {
      unawaited(_createUnit());
      return;
    }
    setState(() {
      _baseUnitId = _unitIdFromOptionLabel(units, label);
      if (_secondaryUnitId == _baseUnitId) {
        _secondaryUnitId = null;
      }
      _clearError();
    });
    unawaited(_loadConversionRateForPair());
  }

  void _onSecondaryUnitSelected(List<InventoryUnit> units, String label) {
    setState(() {
      _secondaryUnitId = _unitIdFromOptionLabel(units, label);
      _clearError();
    });
    unawaited(_loadConversionRateForPair());
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  bool get _unitsConflict =>
      _baseUnitId != null &&
      _secondaryUnitId != null &&
      _baseUnitId == _secondaryUnitId;

  bool get _canSave => _baseUnitId != null && !_unitsConflict && !_isSaving;

  bool get _showConversionRate => _secondaryUnitId != null;

  void _applyDefaultBaseUnitIfNeeded(List<InventoryUnit> units) {
    if (units.isEmpty) return;
    if (_baseUnitId != null || widget.initialBaseUnitId != null) return;
    final defaultUnit = resolveDefaultPcsUnit(units);
    if (defaultUnit == null) return;
    setState(() => _baseUnitId = defaultUnit.id);
  }

  void _applyConversionLookup(UnitPairConversionLookup? lookup) {
    if (lookup == null) {
      _existingConversionId = null;
      _conversionStoredFromBase = true;
      _rateController.text = '0';
      return;
    }
    _existingConversionId = lookup.conversionId;
    _conversionStoredFromBase = lookup.storedFromBase;
    _rateController.text = _formatRate(lookup.displayRate);
  }

  Future<void> _loadConversionRateForPair() async {
    final baseId = _baseUnitId;
    final secondaryId = _secondaryUnitId;
    if (baseId == null || secondaryId == null) {
      setState(() {
        _applyConversionLookup(null);
        _loadingConversionRate = false;
      });
      return;
    }

    setState(() => _loadingConversionRate = true);
    final lookup = await ref
        .read(inventoryUnitsProvider.notifier)
        .lookupConversionForBaseSecondary(
          baseUnitId: baseId,
          secondaryUnitId: secondaryId,
        );
    if (!mounted) return;

    setState(() {
      _loadingConversionRate = false;
      _applyConversionLookup(lookup);
    });
  }

  bool _isExistingPairError(String? message) {
    if (message == null) return false;
    return message.toLowerCase().contains('already exists');
  }

  Future<AddConversionResult> _persistConversion(
    InventoryUnits notifier,
    double displayRate,
  ) async {
    if (_existingConversionId != null) {
      final lookup = UnitPairConversionLookup(
        conversionId: _existingConversionId!,
        displayRate: displayRate,
        storedFromBase: _conversionStoredFromBase,
      );
      return notifier.updateConversion(
        conversionId: _existingConversionId!,
        baseUnitId: _baseUnitId!,
        apiFactor: lookup.apiFactorForDisplayRate(displayRate),
      );
    }
    return notifier.addConversion(
      baseUnitId: _baseUnitId!,
      secondaryUnitId: _secondaryUnitId!,
      rate: displayRate,
    );
  }

  String _formatRate(double factor) {
    if (factor == factor.roundToDouble()) {
      return factor.toInt().toString();
    }
    return factor.toString();
  }

  Future<void> _save() async {
    if (!_canSave) return;

    if (_secondaryUnitId != null) {
      final rate = double.tryParse(_rateController.text.trim());
      if (rate == null || rate <= 0) {
        setState(
          () => _errorMessage =
              'Enter a valid conversion rate greater than 0',
        );
        return;
      }

      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      final notifier = ref.read(inventoryUnitsProvider.notifier);
      var result = await _persistConversion(notifier, rate);

      if (!mounted) return;

      if (!result.isSuccess && _isExistingPairError(result.error)) {
        final lookup = await notifier.lookupConversionForBaseSecondary(
          baseUnitId: _baseUnitId!,
          secondaryUnitId: _secondaryUnitId!,
        );
        if (!mounted) return;
        if (lookup != null) {
          setState(() => _applyConversionLookup(lookup));
          result = await _persistConversion(notifier, rate);
        }
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (!result.isSuccess) {
        setState(() => _errorMessage = result.error);
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      UnitSelection(
        baseUnitId: _baseUnitId,
        secondaryUnitId: _secondaryUnitId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    ref.listen(unitsProvider, (previous, next) {
      _applyDefaultBaseUnitIfNeeded(next);
    });
    final hasUnits = units.isNotEmpty;
    final baseUnit = _unitById(units, _baseUnitId);
    final secondaryUnit = _unitById(units, _secondaryUnitId);
    final secondaryUnitOptions = [
      'None',
      ...units
          .where((unit) => unit.id != _baseUnitId)
          .map(_unitOptionLabel),
    ];
    final hasError = _errorMessage != null;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!hasUnits) ...[
              const Text(
                'No units available.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _createUnit,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'New Unit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UnitField(
                      label: 'BASE UNIT',
                      labelColor: AppColors.primary,
                      value: _unitOptionLabelFromId(units, _baseUnitId),
                      options: [
                        _newUnitOption,
                        ...units.map(_unitOptionLabel),
                      ],
                      onSelected: (label) => _onBaseUnitSelected(units, label),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: _unitDropdownTopInset),
                    child: SizedBox(
                      width: 28,
                      height: saleFieldHeight,
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _UnitField(
                      label: 'SECONDARY UNIT',
                      labelColor: AppColors.textSecondary,
                      value: _unitOptionLabelFromId(units, _secondaryUnitId),
                      options: secondaryUnitOptions,
                      hasError: _unitsConflict,
                      onSelected: (label) => _onSecondaryUnitSelected(units, label),
                    ),
                  ),
                ],
              ),
              if (_unitsConflict) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Base unit and secondary unit cannot be the same.',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],
              if (_showConversionRate && baseUnit != null && secondaryUnit != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Conversion Rates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '1 ${_conversionUnitLabel(baseUnit)} =',
                      style: _conversionLabelStyle,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 88,
                      child: _ConversionRateField(
                        controller: _rateController,
                        enabled: !_isSaving && !_loadingConversionRate,
                        hasError: hasError,
                        onChanged: (_) => _clearError(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _conversionUnitLabel(secondaryUnit),
                      style: _conversionLabelStyle,
                    ),
                  ],
                ),
              ],
              if (hasError) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _canSave ? () => unawaited(_save()) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _unitOptionLabel(InventoryUnit unit) {
    return '${unit.fullName.toUpperCase()} (${unit.shortName})';
  }

  static String _conversionUnitLabel(InventoryUnit unit) {
    return unit.fullName.toUpperCase();
  }

  static InventoryUnit? _unitById(List<InventoryUnit> units, String? unitId) {
    if (unitId == null) return null;
    return units.where((unit) => unit.id == unitId).firstOrNull;
  }

  String _unitOptionLabelFromId(List<InventoryUnit> units, String? unitId) {
    final unit = _unitById(units, unitId);
    if (unit == null) return 'None';
    return _unitOptionLabel(unit);
  }

  String? _unitIdFromOptionLabel(List<InventoryUnit> units, String label) {
    if (label == 'None') return null;
    return units
        .where((unit) => _unitOptionLabel(unit) == label)
        .map((unit) => unit.id)
        .firstOrNull;
  }
}

/// Compact bordered rate input centered with adjacent "1 UNIT =" label text.
class _ConversionRateField extends StatelessWidget {
  const _ConversionRateField({
    required this.controller,
    required this.enabled,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String> onChanged;

  static const _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: _conversionLabelStyle,
      strutStyle: const StrutStyle(
        fontSize: _fontSize,
        height: 1,
        forceStrutHeight: true,
        leading: 0,
      ),
      cursorHeight: _fontSize,
      scrollPadding: EdgeInsets.zero,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        isDense: true,
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: '0',
        hintStyle: TextStyle(
          fontSize: _fontSize,
          height: 1,
          color: Color(0xFFBDBDBD),
        ),
      ),
      onChanged: onChanged,
    );

    return SaleFieldChrome(
      compact: true,
      hasError: hasError,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: _fontSize + 4,
          width: double.infinity,
          child: textField,
        ),
      ),
    );
  }
}

class _UnitField extends StatelessWidget {
  const _UnitField({
    required this.label,
    required this.labelColor,
    required this.value,
    required this.options,
    required this.onSelected,
    this.hasError = false,
  });

  final String label;
  final Color labelColor;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SaleSearchableSelectDropdown(
          value: value,
          options: options,
          onSelected: onSelected,
          hasError: hasError,
          searchHint: 'Type to search',
        ),
      ],
    );
  }
}
