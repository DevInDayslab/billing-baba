import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 480.0;

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
  return showDialog<UnitSelection>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SelectUnitDialog(
        initialBaseUnitId: initialBaseUnitId,
        initialSecondaryUnitId: initialSecondaryUnitId,
      ),
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

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UnitField(
                      label: 'BASE UNIT',
                      labelColor: AppColors.primary,
                      value: _unitLabel(units, _baseUnitId),
                      options: _unitOptions(units),
                      onSelected: (label) {
                        setState(() {
                          _baseUnitId = _unitIdFromLabel(units, label);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _UnitField(
                      label: 'SECONDARY UNIT',
                      labelColor: AppColors.textSecondary,
                      value: _unitLabel(units, _secondaryUnitId),
                      options: _unitOptions(units),
                      onSelected: (label) {
                        setState(() {
                          _secondaryUnitId = _unitIdFromLabel(units, label);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    UnitSelection(
                      baseUnitId: _baseUnitId,
                      secondaryUnitId: _secondaryUnitId,
                    ),
                  ),
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
      ),
    );
  }

  List<String> _unitOptions(List<InventoryUnit> units) {
    return ['None', ...units.map((unit) => unit.shortName)];
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
  });

  final String label;
  final Color labelColor;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

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
        SaleGenericSelectDropdown(
          value: value,
          options: options,
          onSelected: onSelected,
        ),
      ],
    );
  }
}
