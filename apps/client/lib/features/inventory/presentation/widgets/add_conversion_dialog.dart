import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 720.0;

Future<void> showAddConversionDialog(
  BuildContext context, {
  required String initialBaseUnitId,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddConversionDialog(initialBaseUnitId: initialBaseUnitId),
    ),
  );
}

class AddConversionDialog extends ConsumerStatefulWidget {
  const AddConversionDialog({required this.initialBaseUnitId, super.key});

  final String initialBaseUnitId;

  @override
  ConsumerState<AddConversionDialog> createState() =>
      _AddConversionDialogState();
}

class _AddConversionDialogState extends ConsumerState<AddConversionDialog> {
  final _rateController = TextEditingController(text: '0');
  final _rateFocusNode = FocusNode();

  late String _baseUnitId;
  String? _secondaryUnitId;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _baseUnitId = widget.initialBaseUnitId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rateFocusNode.requestFocus();
      _rateController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _rateController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _rateController.dispose();
    _rateFocusNode.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _resetForm() {
    _rateController.text = '0';
    _secondaryUnitId = null;
    _rateFocusNode.requestFocus();
    _rateController.selection = const TextSelection(
      baseOffset: 0,
      extentOffset: 1,
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    if (_isLoading) return;
    final rate = double.tryParse(_rateController.text.trim());
    if (rate == null || rate <= 0) {
      setState(() => _errorMessage = 'Enter a valid rate greater than 0');
      return;
    }
    if (_secondaryUnitId == null) {
      setState(() => _errorMessage = 'Select a secondary unit');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref
        .read(inventoryUnitsProvider.notifier)
        .addConversion(
          baseUnitId: _baseUnitId,
          secondaryUnitId: _secondaryUnitId!,
          rate: rate,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    ref.read(selectedUnitIdProvider.notifier).selected = _baseUnitId;

    if (saveAndNew) {
      setState(() => _errorMessage = null);
      _resetForm();
      return;
    }

    Navigator.of(context).pop();
  }

  String _baseUnitOptionLabel(InventoryUnit unit) {
    return '1${unit.fullName} (${unit.shortName})';
  }

  List<String> _baseUnitOptions(List<InventoryUnit> units) {
    return units.map(_baseUnitOptionLabel).toList();
  }

  String _baseUnitSelectedLabel(List<InventoryUnit> units) {
    final unit = units.where((u) => u.id == _baseUnitId).firstOrNull;
    if (unit == null) return 'Select';
    return _baseUnitOptionLabel(unit);
  }

  void _onBaseUnitSelected(List<InventoryUnit> units, String label) {
    final unit = units
        .where((u) => _baseUnitOptionLabel(u) == label)
        .firstOrNull;
    if (unit == null) return;
    setState(() {
      _baseUnitId = unit.id;
      if (_secondaryUnitId == _baseUnitId) {
        _secondaryUnitId = null;
      }
      _clearError();
    });
  }

  List<String> _secondaryUnitOptions(List<InventoryUnit> units) {
    return [
      'None',
      ...units
          .where((unit) => unit.id != _baseUnitId)
          .map((unit) => unit.fullName),
    ];
  }

  String _secondaryUnitSelectedLabel(List<InventoryUnit> units) {
    if (_secondaryUnitId == null) return 'None';
    return units
            .where((unit) => unit.id == _secondaryUnitId)
            .map((unit) => unit.fullName)
            .firstOrNull ??
        'None';
  }

  void _onSecondaryUnitSelected(List<InventoryUnit> units, String label) {
    setState(() {
      if (label == 'None') {
        _secondaryUnitId = null;
      } else {
        _secondaryUnitId = units
            .where((unit) => unit.fullName == label)
            .map((unit) => unit.id)
            .firstOrNull;
      }
      _clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    final hasError = _errorMessage != null;
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      minimumSize: const Size(0, inventoryButtonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              color: inventorySelectedRowColor,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Conversion',
                      style: TextStyle(
                        fontSize: 16,
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
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ConversionField(
                          label: 'BASE UNIT',
                          labelColor: AppColors.primary,
                          child: SaleGenericSelectDropdown(
                            value: _baseUnitSelectedLabel(units),
                            options: _baseUnitOptions(units),
                            onSelected: (label) =>
                                _onBaseUnitSelected(units, label),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          0,
                          AppSpacing.sm,
                          12,
                        ),
                        child: Text(
                          '=',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _ConversionField(
                          label: 'RATE',
                          labelColor: AppColors.textSecondary,
                          child: TextField(
                            controller: _rateController,
                            focusNode: _rateFocusNode,
                            style: saleFieldTextStyle,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            onChanged: (_) => _clearError(),
                            decoration: buildSaleFieldDecoration(
                              hint: '0',
                              hasError: hasError,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 3,
                        child: _ConversionField(
                          label: 'SECONDARY UNIT',
                          labelColor: AppColors.textSecondary,
                          child: SaleGenericSelectDropdown(
                            value: _secondaryUnitSelectedLabel(units),
                            options: _secondaryUnitOptions(units),
                            onSelected: (label) =>
                                _onSecondaryUnitSelected(units, label),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: saleFieldErrorColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: _isLoading
                            ? null
                            : () => _save(saveAndNew: false),
                        style: buttonStyle,
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: _isLoading
                            ? null
                            : () => _save(saveAndNew: true),
                        style: buttonStyle,
                        child: const Text(
                          'SAVE & NEW',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversionField extends StatelessWidget {
  const _ConversionField({
    required this.label,
    required this.labelColor,
    required this.child,
  });

  final String label;
  final Color labelColor;
  final Widget child;

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
        child,
      ],
    );
  }
}
