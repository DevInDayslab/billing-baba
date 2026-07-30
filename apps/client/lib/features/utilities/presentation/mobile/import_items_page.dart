import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_provider.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/widgets/mobile_import_excel_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _ImportItemsMethod { barcode, excel }

/// Mobile import items — method picker and Excel flow.
class MobileImportItemsPage extends ConsumerStatefulWidget {
  const MobileImportItemsPage({super.key});

  @override
  ConsumerState<MobileImportItemsPage> createState() =>
      _MobileImportItemsPageState();
}

class _MobileImportItemsPageState extends ConsumerState<MobileImportItemsPage> {
  _ImportItemsMethod _selectedMethod = _ImportItemsMethod.barcode;
  bool _showExcelFlow = false;

  @override
  Widget build(BuildContext context) {
    if (_showExcelFlow) {
      return MobileImportExcelContent(
        onBack: () => setState(() => _showExcelFlow = false),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        showBackButton: true,
        title: 'Import Items',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Select Import Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MethodCard(
            isSelected: _selectedMethod == _ImportItemsMethod.barcode,
            showRecommended: true,
            icon: Icons.qr_code_scanner_outlined,
            title: 'Import From Barcode',
            description:
                'Scan barcodes to fetch item details from our library of '
                '100 Mn+ standard products.',
            onTap: () => setState(
              () => _selectedMethod = _ImportItemsMethod.barcode,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MethodCard(
            isSelected: _selectedMethod == _ImportItemsMethod.excel,
            icon: Icons.table_chart_outlined,
            title: 'Import From Excel',
            description: 'Import item data from Excel files on your device.',
            onTap: () => setState(
              () => _selectedMethod = _ImportItemsMethod.excel,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: MobileHomeAddSaleFab.accentRed,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    switch (_selectedMethod) {
      case _ImportItemsMethod.barcode:
        context.push(AppRoutes.utilitiesAddItemsBarcode);
      case _ImportItemsMethod.excel:
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isSelected ? _activeBlue : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _activeBlue),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showRecommended)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              _SelectionRadio(isSelected: isSelected),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF1976D2) : const Color(0xFFBDBDBD),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
