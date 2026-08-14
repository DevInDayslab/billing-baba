import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/utilities/application/barcode_generator_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileBarcodeGeneratorPage extends ConsumerStatefulWidget {
  const MobileBarcodeGeneratorPage({super.key});

  @override
  ConsumerState<MobileBarcodeGeneratorPage> createState() =>
      _MobileBarcodeGeneratorPageState();
}

class _MobileBarcodeGeneratorPageState
    extends ConsumerState<MobileBarcodeGeneratorPage> {
  final _itemNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _labelCountController = TextEditingController(text: '1');

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _labelCountController.dispose();
    super.dispose();
  }

  void _syncControllers(BarcodeGeneratorDraft draft) {
    if (_itemNameController.text != draft.itemName) {
      _itemNameController.text = draft.itemName;
    }
    if (_itemCodeController.text != draft.itemCode) {
      _itemCodeController.text = draft.itemCode;
    }
    if (_labelCountController.text != draft.noOfLabels) {
      _labelCountController.text = draft.noOfLabels;
    }
  }

  void _updateDraft({
    String? itemName,
    String? itemCode,
    String? noOfLabels,
  }) {
    final draft = ref.read(barcodeGeneratorProvider).draft;
    ref.read(barcodeGeneratorProvider.notifier).updateDraft(
      draft.copyWith(
        itemName: itemName,
        itemCode: itemCode,
        noOfLabels: noOfLabels,
      ),
    );
  }

  void _addLabel() {
    final added = ref.read(barcodeGeneratorProvider.notifier).addEntry();
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill item name, code, and label count')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(barcodeGeneratorProvider);
    final draft = state.draft;
    _syncControllers(draft);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Barcode generator',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          MobileFormTextField(
            label: 'Item name',
            controller: _itemNameController,
            onChanged: (value) => _updateDraft(itemName: value),
            errorText: draft.itemNameError,
          ),
          MobileFormTextField(
            label: 'Item code / barcode',
            controller: _itemCodeController,
            onChanged: (value) => _updateDraft(itemCode: value),
            errorText: draft.itemCodeError,
          ),
          MobileFormTextField(
            label: 'Number of labels',
            controller: _labelCountController,
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateDraft(noOfLabels: value),
            errorText: draft.noOfLabelsError,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _addLabel,
            child: const Text('Add to label list'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Labels (${state.entries.length})',
            style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.entries.isEmpty)
            Text(
              'No labels yet',
              style: AppTypography.inter(fontSize: AppTypography.bodySize, color: AppColors.textSecondary),
            )
          else
            for (final entry in state.entries)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(entry.itemName),
                  subtitle: Text(entry.itemCode),
                  trailing: Text('${entry.labelCount}×'),
                ),
              ),
        ],
      ),
    );
  }
}
