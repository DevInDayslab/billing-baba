import 'package:collection/collection.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddItemPage extends ConsumerStatefulWidget {
  const MobileAddItemPage({super.key});

  @override
  ConsumerState<MobileAddItemPage> createState() => _MobileAddItemPageState();
}

class _MobileAddItemPageState extends ConsumerState<MobileAddItemPage> {
  final _nameController = TextEditingController();
  final _salePriceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory(AddItemForm notifier) async {
    final categories = ref.read(categoriesProvider);
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final category in categories)
              ListTile(
                title: Text(category.name),
                onTap: () => Navigator.pop(context, category.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) notifier.setCategory(picked);
  }

  Future<void> _pickUnit(AddItemForm notifier) async {
    final units = ref.read(unitsProvider);
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final unit in units)
              ListTile(
                title: Text(unit.fullName),
                onTap: () => Navigator.pop(context, unit.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) notifier.setUnits(baseUnitId: picked);
  }

  Future<void> _save() async {
    final notifier = ref.read(addItemFormProvider.notifier);
    if (!notifier.validate()) return;

    setState(() => _isSaving = true);
    final form = ref.read(addItemFormProvider);
    try {
      final item = await ref
          .read(inventoryItemsProvider.notifier)
          .addItemFromForm(form);
      if (!mounted) return;
      if (item == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save item')),
        );
        return;
      }
      showMobileFormResult(
        context,
        error: null,
        successMessage: 'Item saved',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addItemFormProvider);
    final notifier = ref.read(addItemFormProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final units = ref.watch(unitsProvider);

    if (_nameController.text != form.itemName) {
      _nameController.text = form.itemName;
    }
    final salePriceText = form.salePrice > 0
        ? form.salePrice.toStringAsFixed(2)
        : '';
    if (_salePriceController.text != salePriceText) {
      _salePriceController.text = salePriceText;
    }

    final categoryName = categories
        .where((c) => c.id == form.categoryId)
        .map((c) => c.name)
        .firstOrNull ??
        '';
    final unitName = units
        .where((u) => u.id == form.baseUnitId)
        .map((u) => u.fullName)
        .firstOrNull ??
        '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Add item',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              MobileFormTextField(
                label: 'Item name',
                controller: _nameController,
                onChanged: notifier.updateItemName,
                errorText: form.itemNameError ? 'Required' : null,
              ),
              MobileFormPickerField(
                label: 'Type',
                value: form.itemType == ItemType.product ? 'Product' : 'Service',
                onTap: () async {
                  final type = await showModalBottomSheet<ItemType>(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Product'),
                            onTap: () =>
                                Navigator.pop(context, ItemType.product),
                          ),
                          ListTile(
                            title: const Text('Service'),
                            onTap: () =>
                                Navigator.pop(context, ItemType.service),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (type != null) notifier.setItemType(type);
                },
              ),
              MobileFormPickerField(
                label: 'Category',
                value: categoryName,
                onTap: () => _pickCategory(notifier),
              ),
              MobileFormPickerField(
                label: 'Unit',
                value: unitName,
                onTap: () => _pickUnit(notifier),
              ),
              MobileFormTextField(
                label: 'Sale price',
                controller: _salePriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) {
                  notifier.updateSalePrice(double.tryParse(value) ?? 0);
                },
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save item'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
