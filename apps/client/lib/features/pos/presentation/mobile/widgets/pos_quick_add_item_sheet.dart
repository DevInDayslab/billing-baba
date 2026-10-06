import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

const _addCategoryOptionId = '__add_category__';
const _noneCategoryId = '__none__';
const _fieldBorderColor = Color(0xFFE0E0E0);

Future<void> showPosQuickAddItemSheet(BuildContext context) {
  final theme = Theme.of(context);

  return showMobileBottomSheet<void>(
    context: context,
    titleWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Item',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Item will be added with PCS as default unit',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
    builder: (sheetContext) => const _QuickAddItemSheet(),
  );
}

class _QuickAddItemSheet extends ConsumerStatefulWidget {
  const _QuickAddItemSheet();

  @override
  ConsumerState<_QuickAddItemSheet> createState() => _QuickAddItemSheetState();
}

class _QuickAddItemSheetState extends ConsumerState<_QuickAddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final List<PosCategoryOption> _extraCategories = [];

  String? _selectedCategoryId;
  bool _withTax = false;
  String _selectedTaxRate = 'None';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  List<PosCategoryOption> _categoryOptions(
    List<PosCategoryOption> fromProvider,
  ) {
    final options = [...fromProvider];
    for (final extra in _extraCategories) {
      if (!options.any((category) => category.id == extra.id)) {
        options.add(extra);
      }
    }
    return options;
  }

  String _selectedCategoryLabel(List<PosCategoryOption> categories) {
    if (_selectedCategoryId == null) return 'None';
    final match = categories.where((c) => c.id == _selectedCategoryId);
    return match.isEmpty ? 'None' : match.first.name;
  }

  Future<void> _showCategoryPicker(List<PosCategoryOption> categories) async {
    final options = <MobileOption<String>>[
      const MobileOption<String>(
        value: _addCategoryOptionId,
        label: '+ Add new category',
      ),
      const MobileOption<String>(
        value: _noneCategoryId,
        label: 'None',
      ),
      ...categories.map(
        (category) => MobileOption<String>(
          value: category.id,
          label: category.name,
        ),
      ),
    ];

    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'Category',
      options: options,
      selected: _selectedCategoryId ?? _noneCategoryId,
    );

    if (!mounted || selected == null) return;

    if (selected == _addCategoryOptionId) {
      unawaited(_showAddCategoryDialog());
      return;
    }

    setState(
      () => _selectedCategoryId = selected == _noneCategoryId ? null : selected,
    );
  }

  Future<void> _showTaxRatePicker() async {
    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'Tax Rate',
      options: ItemTaxRate.options
          .map((option) => MobileOption<String>(value: option, label: option))
          .toList(),
      selected: _selectedTaxRate,
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedTaxRate = selected);
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    var dialogError = '';

    final category = await showDialog<PosCategoryOption?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Category name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => unawaited(
                      _submitAddCategory(
                        dialogContext,
                        controller,
                        setDialogState,
                        (error) => dialogError = error,
                      ),
                    ),
                  ),
                  if (dialogError.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dialogError,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => unawaited(
                    _submitAddCategory(
                      dialogContext,
                      controller,
                      setDialogState,
                      (error) => dialogError = error,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (!mounted || category == null) return;

    setState(() {
      _selectedCategoryId = category.id;
      if (!_extraCategories.any((item) => item.id == category.id)) {
        _extraCategories.add(category);
      }
    });
  }

  Future<void> _submitAddCategory(
    BuildContext dialogContext,
    TextEditingController controller,
    void Function(void Function()) setDialogState,
    void Function(String error) onError,
  ) async {
    final result = await ref
        .read(inventoryCategoriesProvider.notifier)
        .addCategory(controller.text);

    if (!dialogContext.mounted) return;

    if (result.error != null) {
      setDialogState(() => onError(result.error!));
      return;
    }

    final created = result.category;
    if (created == null) return;

    Navigator.of(dialogContext).pop(
      PosCategoryOption(id: created.id, name: created.name),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
        ),
      );
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final salePrice = _sellingPriceController.text.trim().isEmpty
        ? '0'
        : Validators.normalizeDecimalString(_sellingPriceController.text)!;

    final request = CreateItemRequest(
      name: _nameController.text.trim(),
      baseUnit: 'PCS',
      categoryId: _selectedCategoryId,
      salePrice: salePrice,
      defaultTaxRate: _withTax
          ? ItemTaxRate.toApiValue(_selectedTaxRate)
          : ItemTaxRate.toApiValue('None'),
    );

    try {
      final repository = await ref.read(inventoryRepositoryProvider.future);
      await repository.createItem(request);
      ref.invalidate(inventoryItemsProvider);

      if (!mounted) return;

      _showSnackBar('Item added successfully');
      Navigator.of(context).pop();
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(error.message, isError: true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(
        InventoryErrorMapper.messageForSaveItem(error),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _categoryOptions(ref.watch(posCategoriesProvider));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldSection(
            label: 'Item name *',
            child: _StyledTextFormField(
              controller: _nameController,
              hint: 'e.g. Maggi, Rice Bag 5kg',
              validator: (value) =>
                  Validators.required(value, fieldName: 'Item Name'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldSection(
            label: 'Category',
            child: _PickerField(
              value: _selectedCategoryLabel(categories),
              onTap: () => unawaited(_showCategoryPicker(categories)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldSection(
            label: 'Selling Price',
            child: _StyledTextFormField(
              controller: _sellingPriceController,
              hint: '0.00',
              prefix: '₹',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              validator: Validators.nonNegativeDecimalAmount,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TaxModeToggle(
            withTax: _withTax,
            onChanged: (withTax) => setState(() {
              _withTax = withTax;
              if (!withTax) _selectedTaxRate = 'None';
            }),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: child,
            ),
            child: _withTax
                ? Padding(
                    key: const ValueKey('tax-rate'),
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: _FieldSection(
                      label: 'Tax Rate',
                      child: _PickerField(
                        value: _selectedTaxRate,
                        onTap: () => unawaited(_showTaxRatePicker()),
                      ),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('no-tax-rate'),
                    width: double.infinity,
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isSaving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Add Item',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(height: bottomInset > 0 ? bottomInset : AppSpacing.sm),
        ],
      ),
    );
  }
}

class _FieldSection extends StatelessWidget {
  const _FieldSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _StyledTextFormField extends StatelessWidget {
  const _StyledTextFormField({
    required this.controller,
    required this.hint,
    this.prefix,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixText: prefix,
        prefixStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: _fieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: _fieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: const BorderSide(color: _fieldBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: AppIconSize.md,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxModeToggle extends StatelessWidget {
  const _TaxModeToggle({
    required this.withTax,
    required this.onChanged,
  });

  final bool withTax;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _TaxModeSegment(
                label: 'Without Tax',
                selected: !withTax,
                onTap: () => onChanged(false),
                theme: theme,
              ),
            ),
            Expanded(
              child: _TaxModeSegment(
                label: 'With Tax',
                selected: withTax,
                onTap: () => onChanged(true),
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxModeSegment extends StatelessWidget {
  const _TaxModeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md - 3),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
