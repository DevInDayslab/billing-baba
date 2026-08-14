import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_unit_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String? _baseUnitId;
  String? _secondaryUnitId;

  @override
  void initState() {
    super.initState();
    _baseUnitId = widget.initialBaseUnitId;
    _secondaryUnitId = widget.initialSecondaryUnitId;
  }

  Future<void> _createUnit() async {
    final created = await showAddUnitDialog(context);
    if (!mounted || created == null) return;
    setState(() => _baseUnitId = created.id);
  }

  void _onBaseUnitSelected(List<InventoryUnit> units, String label) {
    if (label == _newUnitOption) {
      unawaited(_createUnit());
      return;
    }
    setState(() {
      _baseUnitId = _unitIdFromLabel(units, label);
    });
  }

  static const _newUnitOption = 'New Unit';

  bool get _canSave => _baseUnitId != null;

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    final hasUnits = units.isNotEmpty;

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
                  onPressed: () => Navigator.of(context).pop(),
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
                      value: _unitLabel(units, _baseUnitId),
                      options: [
                        _newUnitOption,
                        ...units.map((unit) => unit.shortName),
                      ],
                      onSelected: (label) => _onBaseUnitSelected(units, label),
                      onAdd: _createUnit,
                      addTooltip: 'New unit',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _UnitField(
                      label: 'SECONDARY UNIT',
                      labelColor: AppColors.textSecondary,
                      value: _unitLabel(units, _secondaryUnitId),
                      options: [
                        'None',
                        ...units.map((unit) => unit.shortName),
                      ],
                      onSelected: (label) {
                        setState(() {
                          _secondaryUnitId = _unitIdFromLabel(units, label);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _canSave
                    ? () => Navigator.of(context).pop(
                        UnitSelection(
                          baseUnitId: _baseUnitId,
                          secondaryUnitId: _secondaryUnitId,
                        ),
                      )
                    : null,
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
                child: const Text(
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

  String _unitLabel(List<InventoryUnit> units, String? unitId) {
    if (unitId == null) return 'None';
    return units
            .where((unit) => unit.id == unitId)
            .map((unit) => unit.shortName)
            .firstOrNull ??
        'None';
  }

  String? _unitIdFromLabel(List<InventoryUnit> units, String label) {
    if (label == 'None') return null;
    return units
        .where((unit) => unit.shortName == label)
        .map((unit) => unit.id)
        .firstOrNull;
  }
}

class _UnitField extends StatelessWidget {
  const _UnitField({
    required this.label,
    required this.labelColor,
    required this.value,
    required this.options,
    required this.onSelected,
    this.onAdd,
    this.addTooltip,
  });

  final String label;
  final Color labelColor;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAdd;
  final String? addTooltip;

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
        Row(
          children: [
            Expanded(
              child: SaleGenericSelectDropdown(
                value: value,
                options: options,
                onSelected: onSelected,
              ),
            ),
            if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                tooltip: addTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ],
    );
  }
}
