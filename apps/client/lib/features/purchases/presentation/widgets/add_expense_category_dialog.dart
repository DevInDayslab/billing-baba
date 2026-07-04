import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _addCategoryLabel = '+ Add Category';

/// Category dropdown with an option to add a new expense category.
class ExpenseCategoryDropdown extends ConsumerWidget {
  const ExpenseCategoryDropdown({
    required this.value,
    required this.onSelected,
    this.hasError = false,
    super.key,
  });

  final String value;
  final void Function(String id, String name) onSelected;
  final bool hasError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <ExpenseCategoryModel>[],
    );
    final options = [
      ...categories.map((c) => c.name),
      _addCategoryLabel,
    ];

    return SaleGenericSelectDropdown(
      value: value,
      options: options,
      hintText: 'Select category',
      hasError: hasError,
      onSelected: (selected) async {
        if (selected == _addCategoryLabel) {
          final created = await showAddExpenseCategoryDialog(context);
          if (created != null) {
            onSelected(created.id, created.name);
          }
          return;
        }
        final category = categories
            .where((c) => c.name == selected)
            .firstOrNull;
        if (category != null) {
          onSelected(category.id, category.name);
        }
      },
    );
  }
}

Future<ExpenseCategoryModel?> showAddExpenseCategoryDialog(
  BuildContext context,
) {
  return showDialog<ExpenseCategoryModel>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddExpenseCategoryDialog(),
    ),
  );
}

class AddExpenseCategoryDialog extends ConsumerStatefulWidget {
  const AddExpenseCategoryDialog({super.key});

  @override
  ConsumerState<AddExpenseCategoryDialog> createState() =>
      _AddExpenseCategoryDialogState();
}

class _AddExpenseCategoryDialogState
    extends ConsumerState<AddExpenseCategoryDialog> {
  final _nameController = TextEditingController();
  String _expenseType = 'Indirect Expense';
  bool _showError = false;

  static const _expenseTypes = ['Direct Expense', 'Indirect Expense'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    final error = await ref
        .read(expenseCategoriesProvider.notifier)
        .addCategory(name);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final categories = ref.read(expenseCategoriesProvider).value ?? [];
    final created = categories.where((c) => c.name == name).firstOrNull;
    if (created != null) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
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
                      'Add Expense Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Expense Category', style: saleFieldLabelStyle),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  hint: 'e.g. Transport',
                  hasError: _showError,
                ),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
              ),
              if (_showError)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Category name is required',
                    style: TextStyle(fontSize: 11, color: saleFieldErrorColor),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              const Text('Expense Type', style: saleFieldLabelStyle),
              const SizedBox(height: 4),
              SaleGenericSelectDropdown(
                value: _expenseType,
                options: _expenseTypes,
                onSelected: (value) => setState(() => _expenseType = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _handleSave,
                    child: const Text('Save'),
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
