import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddItemsBarcodeScreen extends ConsumerStatefulWidget {
  const MobileAddItemsBarcodeScreen({super.key});

  @override
  ConsumerState<MobileAddItemsBarcodeScreen> createState() =>
      _MobileAddItemsBarcodeScreenState();
}

class _MobileAddItemsBarcodeScreenState
    extends ConsumerState<MobileAddItemsBarcodeScreen> {
  final _barcodeController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(barcodeImportProvider.notifier).ensureInitialized();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.length < 3) return;
    final index = ref.read(barcodeImportProvider.notifier).nextEmptyRowIndex;
    ref.read(barcodeImportProvider.notifier).startLookup(index, barcode);
    _barcodeController.clear();
  }

  Future<void> _pasteBarcode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim() ?? '';
    if (pasted.length < 3) return;
    final index = ref.read(barcodeImportProvider.notifier).nextEmptyRowIndex;
    ref.read(barcodeImportProvider.notifier).startLookup(index, pasted);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final categories = ref.read(categoriesProvider);
    final units = ref.read(unitsProvider);
    final error = await ref.read(barcodeImportProvider.notifier).saveItems(
      categories: categories,
      units: units,
    );
    setState(() => _isSaving = false);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items saved')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(barcodeImportProvider);
    final filledRows = rows
        .where((row) => row.itemName.trim().isNotEmpty || row.barcode.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Barcode import',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileFormTextField(
                  label: 'Scan or enter barcode',
                  controller: _barcodeController,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pasteBarcode,
                        child: const Text('Paste'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: _lookupBarcode,
                        child: const Text('Lookup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filledRows.isEmpty
                ? Center(
                    child: Text(
                      'Scan barcodes to add items',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: filledRows.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final row = filledRows[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            row.itemName.isNotEmpty
                                ? row.itemName
                                : 'Unknown item',
                          ),
                          subtitle: Text(row.barcode),
                          trailing: row.status == BarcodeRowStatus.loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save items'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
