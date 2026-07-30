import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/barcode_save_error_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile flow for bulk-adding inventory items by scanning barcodes with the camera.
class MobileAddItemsBarcodeScreen extends ConsumerStatefulWidget {
  const MobileAddItemsBarcodeScreen({super.key});

  @override
  ConsumerState<MobileAddItemsBarcodeScreen> createState() =>
      _MobileAddItemsBarcodeScreenState();
}

class _MobileAddItemsBarcodeScreenState
    extends ConsumerState<MobileAddItemsBarcodeScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(barcodeImportProvider.notifier).ensureInitialized());
      }
    });
  }

  int get _scannedCount {
    final rows = ref.watch(barcodeImportProvider);
    return rows.where((row) => row.hasData).length;
  }

  Future<void> _handleBarcodeDetected(String barcode) async {
    final notifier = ref.read(barcodeImportProvider.notifier);
    final rowIndex = notifier.nextEmptyRowIndex;
    await notifier.startLookup(rowIndex, barcode);

    if (!mounted) return;

    final row = ref.read(barcodeImportProvider).elementAtOrNull(rowIndex);
    final label = row?.itemName.trim().isNotEmpty == true
        ? row!.itemName
        : barcode;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            row?.status == BarcodeRowStatus.found
                ? 'Found: $label'
                : row?.status == BarcodeRowStatus.loading
                ? 'Looking up $barcode...'
                : 'Barcode $barcode added for manual entry',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleSave({required bool andNew}) async {
    if (_isSaving) return;
    _isSaving = true;
    try {
      final notifier = ref.read(barcodeImportProvider.notifier);
      final errorRows = notifier.getRowsWithErrors();

      if (errorRows.isNotEmpty) {
        final ignore = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BarcodeSaveErrorDialog(errorRows: errorRows),
        );
        if (ignore != true) return;
      }

      final categories = ref.read(categoriesProvider);
      final units = ref.read(unitsProvider);

      final saveError = await notifier.saveItems(
        ignoreErrors: errorRows.isNotEmpty,
        categories: categories,
        units: units,
      );

      if (!mounted) return;

      if (saveError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Items added successfully')),
        );
        if (andNew) {
          ref.read(barcodeImportProvider.notifier).resetToEmpty();
        } else {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save items: $saveError')),
        );
      }
    } finally {
      _isSaving = false;
    }
  }

  Future<void> _showScannedItemsSheet() async {
    final rows = ref.read(barcodeImportProvider).where((row) => row.hasData);
    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan a barcode to get started')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
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
                Text(
                  'Scanned items (${rows.length})',
                  style: AppTypography.inter(
                    fontSize: AppTypography.titleMediumSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = rows.elementAt(index);
                      final subtitle = switch (row.status) {
                        BarcodeRowStatus.found => 'Ready to save',
                        BarcodeRowStatus.notFound => 'Not found — manual entry',
                        BarcodeRowStatus.manualEntry => 'Manual entry',
                        BarcodeRowStatus.loading => 'Looking up...',
                        BarcodeRowStatus.empty => '',
                      };
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          row.itemName.trim().isNotEmpty
                              ? row.itemName
                              : row.barcode,
                        ),
                        subtitle: Text(subtitle),
                        trailing: Text(
                          row.barcode,
                          style: AppTypography.inter(
                            fontSize: AppTypography.captionSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleSave(andNew: true),
                        child: const Text('Save & New'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _handleSave(andNew: false),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannedCount = _scannedCount;

    return Stack(
      children: [
        MobileBarcodeScannerScreen(
          mode: MobileBarcodeScannerMode.continuous,
          onBarcodeDetected: _handleBarcodeDetected,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Material(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: _showScannedItemsSheet,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      scannedCount == 0
                          ? 'Tap to review scanned items'
                          : '$scannedCount item${scannedCount == 1 ? '' : 's'} scanned',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
