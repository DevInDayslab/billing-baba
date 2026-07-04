import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ServicesTabContent extends ConsumerStatefulWidget {
  const ServicesTabContent({super.key});

  @override
  ConsumerState<ServicesTabContent> createState() => _ServicesTabContentState();
}

class _ServicesTabContentState extends ConsumerState<ServicesTabContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(serviceSearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(serviceBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref.read(inventoryItemsProvider.notifier).refresh(
          searchQuery: trimmed.isEmpty ? null : trimmed,
        ),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context, InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .deleteItem(item.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final selectedId = ref.watch(selectedServiceIdProvider);

    return InventorySplitLayout(
      listPanel: _ServicesListPanel(
        services: services,
        itemsAsync: itemsAsync,
        selectedId: selectedId,
        onSearchChanged: _onSearchChanged,
        onRefresh: () => ref.read(inventoryItemsProvider.notifier).refresh(
          searchQuery: ref.read(serviceBackendSearchProvider),
        ),
        onItemSelected: (id) =>
            ref.read(selectedServiceIdProvider.notifier).selected = id,
        onAddService: () => showAddItemDialog(
          context,
          initialType: ItemType.service,
        ),
        onMenuSelected: (value, item) {
          switch (value) {
            case 'Edit':
              showAddItemDialog(
                context,
                initialType: ItemType.service,
                editItem: item,
              );
            case 'Delete':
              unawaited(_confirmDelete(context, item));
          }
        },
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select a service to view details',
            )
          : services.any((s) => s.id == selectedId)
          ? _ServiceDetailPanel(
              item: services.firstWhere((s) => s.id == selectedId),
            )
          : const InventoryDetailPlaceholder(
              message: 'Select a service to view details',
            ),
    );
  }
}

class _ServicesListPanel extends StatelessWidget {
  const _ServicesListPanel({
    required this.services,
    required this.itemsAsync,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onItemSelected,
    required this.onAddService,
    required this.onMenuSelected,
  });

  final List<InventoryItem> services;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddService;
  final void Function(String value, InventoryItem item) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              InventorySearchField(
                hint: 'Search services...',
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              InventoryPrimaryButton(
                label: 'Add Service',
                onPressed: onAddService,
              ),
            ],
          ),
        ),
        const InventoryListHeader(
          columns: [
            InventoryListColumn(label: 'SERVICE NAME'),
            InventoryListColumn(label: 'SALE PRICE'),
          ],
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: itemsAsync,
            items: services,
            onRefresh: onRefresh,
            emptyMessage: 'No services found',
            itemBuilder: (context, item) {
              final isSelected = item.id == selectedId;
              return Material(
                color: isSelected
                    ? inventorySelectedRowColor
                    : Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: inventoryCardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onItemSelected(item.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.salePrice != null
                                        ? currency.format(item.salePrice)
                                        : '-',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: InventoryListRowMenu(
                          onSelected: (value) => onMenuSelected(value, item),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceDetailPanel extends StatelessWidget {
  const _ServiceDetailPanel({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name.toUpperCase(), style: InventoryStyles.panelTitleStyle),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Sale Price: ${item.salePrice != null ? currency.format(item.salePrice) : '-'}',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              item.description!,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (item.hsnCode != null && item.hsnCode!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'HSN: ${item.hsnCode}',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
