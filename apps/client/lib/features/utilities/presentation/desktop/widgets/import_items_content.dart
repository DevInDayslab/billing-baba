import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_provider.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/widgets/import_items_excel_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);

enum ImportItemsMethod { barcode, excel }

class ImportItemsContent extends ConsumerStatefulWidget {
  const ImportItemsContent({super.key});

  @override
  ConsumerState<ImportItemsContent> createState() => _ImportItemsContentState();
}

class _ImportItemsContentState extends ConsumerState<ImportItemsContent> {
  ImportItemsMethod _selectedMethod = ImportItemsMethod.barcode;
  bool _showExcelFlow = false;

  @override
  Widget build(BuildContext context) {
    if (_showExcelFlow) {
      return ImportItemsExcelContent(
        onBack: () => setState(() => _showExcelFlow = false),
      );
    }

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
                      'Import Items',
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
                        const Text(
                          'Select Import Method',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _MethodCard(
                                  isSelected:
                                      _selectedMethod ==
                                      ImportItemsMethod.barcode,
                                  showRecommended: true,
                                  icon: Icons.qr_code_scanner_outlined,
                                  title: 'Import From Barcode',
                                  description:
                                      'Import item details by scanning barcodes. '
                                      'Billing Baba uses a library of 100 Mn+ '
                                      'standard barcodes to fetch all details of '
                                      'your items in seconds.',
                                  onTap: () => setState(
                                    () => _selectedMethod =
                                        ImportItemsMethod.barcode,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _MethodCard(
                                  isSelected:
                                      _selectedMethod ==
                                      ImportItemsMethod.excel,
                                  icon: Icons.table_chart_outlined,
                                  title: 'Import From Excel',
                                  description:
                                      'Import item data from excel files in your system',
                                  onTap: () => setState(
                                    () => _selectedMethod =
                                        ImportItemsMethod.excel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: inventoryPrimaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  void _onContinue() {
    switch (_selectedMethod) {
      case ImportItemsMethod.barcode:
        context.push(AppRoutes.utilitiesAddItemsBarcode);
      case ImportItemsMethod.excel:
        ref.read(importItemsExcelProvider.notifier).reset();
        setState(() => _showExcelFlow = true);
    }
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.showRecommended = false,
  });

  final bool isSelected;
  final bool showRecommended;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  static const _activeBlue = Color(0xFF1976D2);
  static const _cardBorder = Color(0xFFE0E0E0);
  static const _iconBackground = Color(0xFFE3F2FD);
  static const _recommendedGreen = Color(0xFF2E7D32);
  static const _recommendedBackground = Color(0xFFE8F5E9);
  static const _recommendedBadgeHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: isSelected ? _activeBlue : _cardBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _recommendedBadgeHeight,
                    child: showRecommended
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _recommendedBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _recommendedGreen,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: _activeBlue, size: 26),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _SelectionRadio(isSelected: isSelected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionRadio extends StatelessWidget {
  const _SelectionRadio({required this.isSelected});

  final bool isSelected;

  static const _activeBlue = Color(0xFF1976D2);
  static const _cardBorder = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _activeBlue : _cardBorder,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _activeBlue,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
