import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<GodownModel?> showAddGodownDialog(
  BuildContext context, {
  GodownModel? editGodown,
}) {
  return showFormDialog<GodownModel?>(
    context: context,
    size: FormDialogSize.compact,
    child: AddGodownDialog(editGodown: editGodown),
  );
}

class AddGodownDialog extends ConsumerStatefulWidget {
  const AddGodownDialog({this.editGodown, super.key});

  final GodownModel? editGodown;

  @override
  ConsumerState<AddGodownDialog> createState() => _AddGodownDialogState();
}

class _AddGodownDialogState extends ConsumerState<AddGodownDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editGodown != null;

  @override
  void initState() {
    super.initState();
    if (widget.editGodown != null) {
      _nameController.text = widget.editGodown!.name;
      if (widget.editGodown!.address != null) {
        _addressController.text = widget.editGodown!.address!;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryGodownsProvider.notifier);
    final result = _isEditing
        ? await notifier.updateGodown(
            widget.editGodown!.id,
            _nameController.text,
            address: _addressController.text,
          )
        : await notifier.addGodown(
            _nameController.text,
            address: _addressController.text,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    Navigator.of(context).pop(result.godown);
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
                    _isEditing ? 'Edit Godown' : 'Add Godown',
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
            const Text('Godown Name', style: saleFieldLabelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              focusNode: _focusNode,
              style: saleFieldTextStyle,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              decoration: buildSaleFieldDecoration(
                hint: 'e.g., Main Warehouse',
                hasError: hasError,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Address (optional)', style: saleFieldLabelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              style: saleFieldTextStyle,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: buildSaleFieldDecoration(hint: 'Address'),
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
