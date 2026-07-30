import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _summaryBannerColor = Color(0xFFFFF8E1);
const _errorAccent = Color(0xFFD32F2F);

final _decimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);

/// Manufacturing tab content for products.
class ManufacturingSection extends StatelessWidget {
  const ManufacturingSection({
    required this.form,
    required this.rawControllerFor,
    required this.onUpdateRawMaterial,
    required this.onRemoveRawMaterial,
    required this.onAddRawMaterial,
    required this.onAddAdditionalCost,
    required this.onUpdateAdditionalCost,
    required this.onRemoveAdditionalCost,
    required this.additionalCostControllers,
    super.key,
  });

  final AddItemFormState form;
  final TextEditingController Function(String id, String initial)
  rawControllerFor;
  final void Function(
    String id, {
    String? itemName,
    double? qty,
    String? unitLabel,
    double? purchasePrice,
  })
  onUpdateRawMaterial;
  final ValueChanged<String> onRemoveRawMaterial;
  final VoidCallback onAddRawMaterial;
  final VoidCallback onAddAdditionalCost;
  final void Function(String id, {String? description, double? amount})
  onUpdateAdditionalCost;
  final ValueChanged<String> onRemoveAdditionalCost;
  final Map<String, TextEditingController> additionalCostControllers;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return FormSection(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raw Material',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < 560
                  ? 560.0
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _cardBorder),
                      borderRadius: FormSpacing.cardBorderRadius,
                    ),
                    child: Column(
                      children: [
                        const _ManufacturingTableHeader(),
                        ...form.rawMaterials.asMap().entries.map(
                          (entry) => _RawMaterialRow(
                            index: entry.key + 1,
                            row: entry.value,
                            nameController: rawControllerFor(
                              entry.value.id,
                              entry.value.itemName,
                            ),
                            onChanged: onUpdateRawMaterial,
                            onRemove: () => onRemoveRawMaterial(entry.value.id),
                            canRemove: form.rawMaterials.length > 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: onAddRawMaterial,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Add Row',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'TOTAL: ${currency.format(form.rawMaterialTotal)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAddAdditionalCost,
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Add Additional Cost',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (form.additionalCosts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...form.additionalCosts.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: FormSpacing.inputHeight,
                        child: TextField(
                          controller: additionalCostControllers.putIfAbsent(
                            row.id,
                            () => TextEditingController(text: row.description),
                          ),
                          style: saleFieldTextStyle,
                          decoration: buildSaleFieldDecoration(
                            hint: 'Description',
                          ),
                          onChanged: (v) => onUpdateAdditionalCost(
                            row.id,
                            description: v,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FormSpacing.gutter),
                    Expanded(
                      child: SizedBox(
                        height: FormSpacing.inputHeight,
                        child: TextField(
                          style: saleFieldTextStyle,
                          decoration: buildSaleFieldDecoration(hint: 'Amount'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [_decimalInputFormatter],
                          onChanged: (v) => onUpdateAdditionalCost(
                            row.id,
                            amount: double.tryParse(v) ?? 0,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemoveAdditionalCost(row.id),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: _errorAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _summaryBannerColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Total Estimated Cost (Raw Material + Additional Cost) = '
              '${currency.format(form.totalEstimatedCost)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManufacturingTableHeader extends StatelessWidget {
  const _ManufacturingTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: _tableHeaderStyle)),
          Expanded(
            flex: 3,
            child: Text('RAW MATERIAL', style: _tableHeaderStyle),
          ),
          Expanded(child: Text('QTY', style: _tableHeaderStyle)),
          Expanded(child: Text('UNIT', style: _tableHeaderStyle)),
          Expanded(
            flex: 2,
            child: Text('PURCHASE PRICE/UNIT (₹)', style: _tableHeaderStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('ESTIMATED COST (₹)', style: _tableHeaderStyle),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
  letterSpacing: 0.3,
);

class _RawMaterialRow extends StatelessWidget {
  const _RawMaterialRow({
    required this.index,
    required this.row,
    required this.nameController,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
  });

  final int index;
  final RawMaterialRow row;
  final TextEditingController nameController;
  final void Function(
    String id, {
    String? itemName,
    double? qty,
    String? unitLabel,
    double? purchasePrice,
  })
  onChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(
                hint: 'Search item...',
                compact: true,
              ),
              onChanged: (v) => onChanged(row.id, itemName: v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(compact: true),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_decimalInputFormatter],
              onChanged: (v) => onChanged(row.id, qty: double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SaleGenericSelectDropdown(
              value: row.unitLabel,
              options: const ['None', 'PCS', 'Kg', 'Ltr'],
              onSelected: (v) => onChanged(row.id, unitLabel: v),
              compact: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(compact: true),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_decimalInputFormatter],
              onChanged: (v) =>
                  onChanged(row.id, purchasePrice: double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              currency.format(row.estimatedCost),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: canRemove
                ? IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: _errorAccent,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
