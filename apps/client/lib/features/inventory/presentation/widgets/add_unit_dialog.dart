import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<InventoryUnit?> showAddUnitDialog(
  BuildContext context, {
  InventoryUnit? editUnit,
}) {
  return showFormDialog<InventoryUnit>(
    context: context,
    size: FormDialogSize.medium,
    child: AddUnitDialog(editUnit: editUnit),
  );
}

class AddUnitDialog extends ConsumerStatefulWidget {
  const AddUnitDialog({this.editUnit, super.key});

  final InventoryUnit? editUnit;

  @override
  ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
  final _fullNameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editUnit != null;

  @override
  void initState() {
    super.initState();
    if (widget.editUnit != null) {
      _fullNameController.text = widget.editUnit!.fullName;
      _shortNameController.text = widget.editUnit!.shortName;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fullNameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _shortNameController.dispose();
    _fullNameFocusNode.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _clearFields() {
    _fullNameController.clear();
    _shortNameController.clear();
    _fullNameFocusNode.requestFocus();
  }

  Future<void> _saveUnit({required bool saveAndNew}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryUnitsProvider.notifier);
    final result = _isEditing
        ? await notifier.updateUnit(
            id: widget.editUnit!.id,
            fullName: _fullNameController.text,
            shortName: _shortNameController.text,
          )
        : await notifier.addUnit(
            fullName: _fullNameController.text,
            shortName: _shortNameController.text,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    if (!_isEditing) {
      ref.read(selectedUnitIdProvider.notifier).selected = result.unit!.id;
    }

    if (saveAndNew && !_isEditing) {
      setState(() => _errorMessage = null);
      _clearFields();
      return;
    }

    Navigator.of(context).pop(result.unit);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: inventoryNegativeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      minimumSize: const Size(0, inventoryButtonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

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
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Unit' : 'New Unit',
                      style: const TextStyle(
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
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unit Name',
                          style: saleFieldLabelStyle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _fullNameController,
                          focusNode: _fullNameFocusNode,
                          style: saleFieldTextStyle,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => _clearError(),
                          decoration: buildSaleFieldDecoration(
                            hint: 'e.g., Pieces',
                            hasError: hasError,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Short Name',
                          style: saleFieldLabelStyle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _shortNameController,
                          style: saleFieldTextStyle,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => _clearError(),
                          onSubmitted: (_) => _saveUnit(saveAndNew: false),
                          decoration: buildSaleFieldDecoration(
                            hint: 'e.g., Pcs',
                            hasError: hasError,
                          ),
                        ),
                      ],
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
                        : () => _saveUnit(saveAndNew: false),
                    style: buttonStyle,
                    child: Text(
                      _isEditing ? 'Save' : 'Save',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: _isLoading
                          ? null
                          : () => _saveUnit(saveAndNew: true),
                      style: buttonStyle,
                      child: const Text(
                        'Save New',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
    );
  }
}
