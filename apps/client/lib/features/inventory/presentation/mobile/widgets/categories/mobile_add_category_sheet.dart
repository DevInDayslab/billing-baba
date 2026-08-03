import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile bottom sheet for creating or editing a category (Vyapar-style).
Future<InventoryCategory?> showMobileAddCategorySheet(
  BuildContext context, {
  InventoryCategory? editCategory,
}) {
  return showModalBottomSheet<InventoryCategory>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: AppColors.surface,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: _AddCategorySheetBody(
                sheetContext: sheetContext,
                editCategory: editCategory,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AddCategorySheetBody extends ConsumerStatefulWidget {
  const _AddCategorySheetBody({
    required this.sheetContext,
    this.editCategory,
  });

  final BuildContext sheetContext;
  final InventoryCategory? editCategory;

  @override
  ConsumerState<_AddCategorySheetBody> createState() =>
      _AddCategorySheetBodyState();
}

class _AddCategorySheetBodyState extends ConsumerState<_AddCategorySheetBody> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editCategory != null;

  static const _fieldBorderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editCategory?.name ?? '',
    );
    _nameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.75),
        fontSize: 14,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(_fieldBorderColor),
      enabledBorder: border(_fieldBorderColor),
      focusedBorder: border(AppColors.primary, width: 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
    );
  }

  Future<void> _save() async {
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

    Navigator.of(widget.sheetContext).pop(result.category);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Category' : 'Add Category';
    final actionLabel = _isEditing ? 'Save' : 'Create';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(widget.sheetContext).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _fieldDecoration('Enter Category Name'),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
            onSubmitted: (_) => _save(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: MobileHomeAddSaleFab.accentRed,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: _isLoading ? null : _save,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
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
                          actionLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
