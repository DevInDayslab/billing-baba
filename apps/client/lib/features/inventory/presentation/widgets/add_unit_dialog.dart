import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 480.0;

Future<void> showAddUnitDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddUnitDialog(),
    ),
  );
}

class AddUnitDialog extends ConsumerStatefulWidget {
  const AddUnitDialog({super.key});

  @override
  ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
  final _fullNameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

  bool _createUnit({required bool saveAndNew}) {
    final result = ref
        .read(inventoryUnitsProvider.notifier)
        .addUnit(
          fullName: _fullNameController.text,
          shortName: _shortNameController.text,
        );

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return false;
    }

    ref.read(selectedUnitIdProvider.notifier).selected = result.unit!.id;

    if (saveAndNew) {
      setState(() => _errorMessage = null);
      _clearFields();
      return true;
    }

    Navigator.of(context).pop();
    return true;
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
                      'New Unit',
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
                          onSubmitted: (_) => _createUnit(saveAndNew: false),
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
                    onPressed: () => _createUnit(saveAndNew: false),
                    style: buttonStyle,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => _createUnit(saveAndNew: true),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
