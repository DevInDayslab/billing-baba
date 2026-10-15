import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<IncomeCatalogItemModel?> showAddExpenseItemDialog(
  BuildContext context,
) {
  return showFormDialog<IncomeCatalogItemModel>(
    context: context,
    size: FormDialogSize.compact,
    barrierDismissible: false,
    child: const AddExpenseItemDialog(),
  );
}

class AddExpenseItemDialog extends ConsumerStatefulWidget {
  const AddExpenseItemDialog({super.key});

  @override
  ConsumerState<AddExpenseItemDialog> createState() =>
      _AddExpenseItemDialogState();
}

class _AddExpenseItemDialogState extends ConsumerState<AddExpenseItemDialog> {
  final _nameController = TextEditingController();
  final _hsnController = TextEditingController();
  final _priceController = TextEditingController();
  var _priceIsTaxInclusive = false;
  var _taxRate = 0.0;
  var _saving = false;
  var _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    setState(() {
      _saving = true;
      _showNameError = false;
    });

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final created = await ref
        .read(incomeCatalogItemsProvider.notifier)
        .createItem(
          CreateIncomeItemRequest(
            name: name,
            hsnSac: _hsnController.text.trim().isEmpty
                ? null
                : _hsnController.text.trim(),
            price: price.toStringAsFixed(4),
            priceIsTaxInclusive: _priceIsTaxInclusive,
            taxRate: _taxRate.toStringAsFixed(4),
          ),
        );

    if (!mounted) return;
    if (created == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save expense item')),
      );
      return;
    }
    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Text(
                    'Add Other Income Item',
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
            const Text('Item Name', style: saleFieldLabelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(
                hint: 'e.g. Office maintenance',
                hasError: _showNameError,
              ),
              onChanged: (_) {
                if (_showNameError) setState(() => _showNameError = false);
              },
            ),
            if (_showNameError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Item name is required',
                  style: TextStyle(fontSize: 11, color: saleFieldErrorColor),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const Text('Item HSN / SAC', style: saleFieldLabelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _hsnController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Optional'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    style: saleFieldTextStyle,
                    decoration: buildSaleFieldDecoration(hint: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SaleGenericSelectDropdown(
                    value: _priceIsTaxInclusive ? 'Tax Included' : 'Tax Excluded',
                    options: const ['Tax Excluded', 'Tax Included'],
                    onSelected: (value) => setState(
                      () => _priceIsTaxInclusive = value == 'Tax Included',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SaleGenericSelectDropdown(
              value: _taxRate == 0 ? 'NONE' : '${_taxRate.toInt()}%',
              options: SaleDropdownOptions.taxSlabs,
              onSelected: (value) {
                setState(() {
                  _taxRate = value == 'NONE'
                      ? 0
                      : double.tryParse(value.replaceAll('%', '')) ?? 0;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
