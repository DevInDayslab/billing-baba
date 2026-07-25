import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportPartyTypeFilter extends ConsumerWidget {
  const ReportPartyTypeFilter({super.key});

  static const _labels = ['All Parties', 'Customers', 'Suppliers'];
  static const List<String?> _values = [null, 'customer', 'supplier'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final selected = switch (filters.partyType) {
      'customer' => 'Customers',
      'supplier' => 'Suppliers',
      _ => 'All Parties',
    };

    return SaleFilterDropdown(
      label: selected,
      options: _labels,
      selected: selected,
      onSelected: (value) {
        final index = _labels.indexOf(value);
        notifier.setPartyType(index >= 0 ? _values[index] : null);
      },
    );
  }
}

class ReportPartyGroupFilter extends ConsumerWidget {
  const ReportPartyGroupFilter({super.key});

  static const _labels = [
    'All Groups',
    'Customer',
    'Retailer',
    'Wholesaler',
    'Manufacturer',
    'Custom',
  ];
  static const List<String?> _values = [
    null,
    'customer',
    'retailer',
    'wholesaler',
    'manufacturer',
    'custom',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final selected = switch (filters.partyGroup) {
      'customer' => 'Customer',
      'retailer' => 'Retailer',
      'wholesaler' => 'Wholesaler',
      'manufacturer' => 'Manufacturer',
      'custom' => 'Custom',
      _ => 'All Groups',
    };

    return SaleFilterDropdown(
      label: selected,
      options: _labels,
      selected: selected,
      onSelected: (value) {
        final index = _labels.indexOf(value);
        notifier.setPartyGroup(index >= 0 ? _values[index] : null);
      },
    );
  }
}

class ReportPartyStatusFilter extends ConsumerWidget {
  const ReportPartyStatusFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final selected = switch (filters.status) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      _ => 'All Status',
    };

    return SaleFilterDropdown(
      label: selected,
      options: const ['All Status', 'Active', 'Inactive'],
      selected: selected,
      onSelected: (value) {
        notifier.setStatus(switch (value) {
          'Active' => 'active',
          'Inactive' => 'inactive',
          _ => null,
        });
      },
    );
  }
}

class ReportDisabledBusinessFilter extends StatelessWidget {
  const ReportDisabledBusinessFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Multi-business filtering is not available.',
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.55,
          child: SaleFilterDropdown(
            label: 'All Businesses',
            options: const ['All Businesses'],
            selected: 'All Businesses',
            onSelected: (_) {},
          ),
        ),
      ),
    );
  }
}

class ReportPageSizeFilter extends ConsumerWidget {
  const ReportPageSizeFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageSize = ref.watch(reportFiltersProvider).pageSize;
    final notifier = ref.read(reportFiltersProvider.notifier);
    final label = '$pageSize / page';

    return SaleFilterDropdown(
      label: label,
      options: const ['10 / page', '20 / page', '50 / page', '100 / page'],
      selected: label,
      onSelected: (value) {
        final size = int.tryParse(value.split(' ').first) ?? 20;
        notifier.setPageSize(size);
      },
    );
  }
}

class ReportCategoryFilter extends ConsumerWidget {
  const ReportCategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);

    final options = ['All Categories', ...categories.map((c) => c.name)];
    final selected = _selectedCategoryName(categories, filters.categoryId);

    return SaleFilterDropdown(
      label: selected,
      options: options,
      selected: selected,
      onSelected: (value) {
        if (value == 'All Categories') {
          notifier.setCategoryId(null);
          return;
        }
        final category = categories.firstWhere((c) => c.name == value);
        notifier.setCategoryId(category.id);
      },
    );
  }

  String _selectedCategoryName(List<InventoryCategory> categories, String? id) {
    if (id == null) return 'All Categories';
    for (final category in categories) {
      if (category.id == id) return category.name;
    }
    return 'All Categories';
  }
}

class ReportGodownFilter extends ConsumerWidget {
  const ReportGodownFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final godowns = ref.watch(inventoryGodownsProvider).value ?? [];
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);

    final options = ['All Godowns', ...godowns.map((g) => g.name)];
    final selected = _selectedGodownName(godowns, filters.godownId);

    return SaleFilterDropdown(
      label: selected,
      options: options,
      selected: selected,
      onSelected: (value) {
        if (value == 'All Godowns') {
          notifier.setGodownId(null);
          return;
        }
        final godown = godowns.firstWhere((g) => g.name == value);
        notifier.setGodownId(godown.id);
      },
    );
  }

  String _selectedGodownName(List<GodownModel> godowns, String? id) {
    if (id == null) return 'All Godowns';
    for (final godown in godowns) {
      if (godown.id == id) return godown.name;
    }
    return 'All Godowns';
  }
}

class ReportTransactionTypeFilter extends ConsumerWidget {
  const ReportTransactionTypeFilter({super.key});

  static const _labels = [
    'All Transaction',
    'Sale',
    'Purchase',
    'Payment In',
    'Payment Out',
  ];
  static const List<String?> _values = [
    null,
    'sale',
    'purchase',
    'payment_in',
    'payment_out',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final selected = switch (filters.documentType) {
      'sale' => 'Sale',
      'purchase' => 'Purchase',
      'payment_in' => 'Payment In',
      'payment_out' => 'Payment Out',
      _ => 'All Transaction',
    };

    return SaleFilterDropdown(
      label: selected,
      options: _labels,
      selected: selected,
      onSelected: (value) {
        final index = _labels.indexOf(value);
        notifier.setDocumentType(index >= 0 ? _values[index] : null);
      },
    );
  }
}

class ReportDisabledDateFilter extends StatelessWidget {
  const ReportDisabledDateFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'As-of date filtering requires inventory history support.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Checkbox(
            value: false,
            onChanged: null,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            'Date filter',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
