import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<BrandModel?> showAddBrandDialog(
  BuildContext context, {
  BrandModel? editBrand,
}) {
  return showFormDialog<BrandModel?>(
    context: context,
    size: FormDialogSize.compact,
    child: AddBrandDialog(editBrand: editBrand),
  );
}

class AddBrandDialog extends ConsumerStatefulWidget {
  const AddBrandDialog({this.editBrand, super.key});

  final BrandModel? editBrand;

  @override
  ConsumerState<AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends ConsumerState<AddBrandDialog> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editBrand != null;

  @override
  void initState() {
    super.initState();
    if (widget.editBrand != null) {
      _nameController.text = widget.editBrand!.name;
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

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryBrandsProvider.notifier);
    final result = _isEditing
        ? await notifier.updateBrand(widget.editBrand!.id, _nameController.text)
        : await notifier.addBrand(_nameController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    final brand = result.brand;
    if (!_isEditing && brand != null) {
      ref.read(selectedBrandIdProvider.notifier).selected = brand.id;
    }

    Navigator.of(context).pop(brand);
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
                    _isEditing ? 'Edit Brand' : 'Add Brand',
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
            const Text('Enter Brand Name', style: saleFieldLabelStyle),
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
              onSubmitted: (_) => _save(),
              decoration: buildSaleFieldDecoration(
                hint: 'e.g., Amul',
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
                onPressed: _isLoading ? null : _save,
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
