import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ServicesTabContent extends ConsumerWidget {
  const ServicesTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final selectedId = ref.watch(selectedServiceIdProvider);

    return servicesAsync.when(
      loading: () => InventorySplitLayout(
        listPanel: _ServicesListPanel(
          services: const [],
          selectedId: selectedId,
          isLoading: true,
          onSearchChanged: (query) =>
              ref.read(serviceSearchQueryProvider.notifier).update(query),
          onItemSelected: (id) =>
              ref.read(selectedServiceIdProvider.notifier).select(id),
          onAddService: () => showAddItemDialog(
            context,
            initialType: ItemType.service,
          ),
        ),
        detailPanel: const InventoryDetailPlaceholder(
          message: 'Select a service to view details',
        ),
      ),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (services) => InventorySplitLayout(
        listPanel: _ServicesListPanel(
          services: services,
          selectedId: selectedId,
          onSearchChanged: (query) =>
              ref.read(serviceSearchQueryProvider.notifier).update(query),
          onItemSelected: (id) =>
              ref.read(selectedServiceIdProvider.notifier).select(id),
          onAddService: () => showAddItemDialog(
            context,
            initialType: ItemType.service,
          ),
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
      ),
    );
  }

}

class _ServicesListPanel extends StatelessWidget {
  const _ServicesListPanel({
    required this.services,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onItemSelected,
    required this.onAddService,
    this.isLoading = false,
  });

  final List<InventoryItem> services;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddService;
  final bool isLoading;

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
                showDropdown: true,
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
          child: isLoading
              ? const InventoryListEmptyState(message: 'Loading...')
              : services.isEmpty
              ? const InventoryListEmptyState(message: 'No services found')
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final item = services[index];
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
                            const Padding(
                              padding: EdgeInsets.only(right: AppSpacing.sm),
                              child: InventoryListRowMenu(),
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
        ],
      ),
    );
  }
}
