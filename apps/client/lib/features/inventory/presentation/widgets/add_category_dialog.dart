import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 400.0;

Future<void> showAddCategoryDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddCategoryDialog(),
    ),
  );
}

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _createCategory() {
    final result = ref
        .read(inventoryCategoriesProvider.notifier)
        .addCategory(_nameController.text);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    ref
        .read(selectedCategoryIdProvider.notifier)
        .select(result.category!.id);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;

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
                      'Add Category',
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
              const Text(
                'Enter Category Name',
                style: saleFieldLabelStyle,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                focusNode: _focusNode,
                style: saleFieldTextStyle,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                onSubmitted: (_) => _createCategory(),
                decoration: buildSaleFieldDecoration(
                  hint: 'e.g., Grocery',
                  hasError: hasError,
                ),
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
              SizedBox(
                height: inventoryButtonHeight,
                child: FilledButton(
                  onPressed: _createCategory,
                  style: FilledButton.styleFrom(
                    backgroundColor: inventoryNegativeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
