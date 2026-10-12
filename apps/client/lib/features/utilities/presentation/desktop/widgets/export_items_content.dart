import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/export_actions.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/utilities/application/export_items_excel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

/// Utilities page to export the full item catalog to Excel.
class ExportItemsContent extends ConsumerStatefulWidget {
  const ExportItemsContent({super.key});

  @override
  ConsumerState<ExportItemsContent> createState() => _ExportItemsContentState();
}

class _ExportItemsContentState extends ConsumerState<ExportItemsContent> {
  var _isExporting = false;

  Future<void> _exportToExcel() async {
    if (_isExporting) return;

    final items = ref.read(inventoryItemListProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to export')),
      );
      return;
    }

    final categories = ref.read(inventoryCategoriesProvider).value ?? [];
    final brands = ref.read(inventoryBrandsProvider).value ?? [];
    final categoryNamesById = <String, String>{
      for (final category in categories) category.id: category.name,
    };
    final brandNamesById = <String, String>{
      for (final brand in brands) brand.id: brand.name,
    };

    setState(() => _isExporting = true);
    try {
      final sheet = ExportItemsExcelService.buildSheet(
        items: items,
        categoryNamesById: categoryNamesById,
        brandNamesById: brandNamesById,
      );
      await ExportActions.exportXlsx(
        context,
        sheet: sheet,
        filenameBase: 'billing_baba_items',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ref.watch(inventoryItemListProvider).length;

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: _cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Text(
                      'Export Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Download all $itemCount item${itemCount == 1 ? '' : 's'} '
                          'into a single Excel workbook.',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'The sheet uses the same columns as item import '
                          '(name, type, prices, tax, unit, HSN/SAC, opening '
                          'quantity) plus barcode, MRP, description, category, '
                          'brand, and other item fields.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _isExporting ? null : _exportToExcel,
                            style: FilledButton.styleFrom(
                              backgroundColor: inventoryPrimaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload_outlined, size: 20),
                            label: Text(
                              _isExporting
                                  ? 'Exporting…'
                                  : 'Export to Excel',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
