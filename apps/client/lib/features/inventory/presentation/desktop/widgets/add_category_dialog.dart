import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAddCategoryDialog(
  BuildContext context, {
  InventoryCategory? editCategory,
}) {
  return showFormDialog<void>(
    context: context,
    size: FormDialogSize.compact,
    child: AddCategoryDialog(editCategory: editCategory),
  );
}

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({this.editCategory, super.key});

  final InventoryCategory? editCategory;

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editCategory != null;

  @override
  void initState() {
    super.initState();
    if (widget.editCategory != null) {
      _nameController.text = widget.editCategory!.name;
    }
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

  Future<void> _saveCategory() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final notifier = ref.read(inventoryCategoriesProvider.notifier);
    final result = _isEditing
        ? await notifier.updateCategory(
            widget.editCategory!.id,
            _nameController.text,
          )
        : await notifier.addCategory(_nameController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    if (!_isEditing) {
      ref.read(selectedCategoryIdProvider.notifier).selected =
          result.category!.id;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Category' : 'Add Category',
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
              onSubmitted: (_) => _saveCategory(),
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
                onPressed: _isLoading ? null : _saveCategory,
                style: FilledButton.styleFrom(
                  backgroundColor: inventoryNegativeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save' : 'Create',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
