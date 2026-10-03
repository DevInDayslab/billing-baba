import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/item_detail_report_helpers.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/item_detail_display_row.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style mobile item detail stock movement report.
class MobileItemDetailReportScreen extends ConsumerStatefulWidget {
  const MobileItemDetailReportScreen({super.key});

  @override
  ConsumerState<MobileItemDetailReportScreen> createState() =>
      _MobileItemDetailReportScreenState();
}

class _MobileItemDetailReportScreenState
    extends ConsumerState<MobileItemDetailReportScreen> {
  static const _headerTeal = Color(0xFF00695C);
  static const _labelTeal = Color(0xFF00897B);
  static const _itemDetailPageSize = 500;

  late final TextEditingController _itemSearchController;
  bool _hideInactiveDates = false;

  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reportFiltersProvider.notifier).setPageSize(_itemDetailPageSize);
      _syncItemSearchFromFilters();
    });
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    super.dispose();
  }

  void _syncItemSearchFromFilters() {
    final itemId = ref.read(reportFiltersProvider).itemId;
    if (itemId == null) return;
    final items =
        ref.read(inventoryItemsProvider).value?.items ??
        const <InventoryItem>[];
    final item = items.where((entry) => entry.id == itemId).firstOrNull;
    if (item != null) {
      _itemSearchController.text = item.name;
    }
  }

  Future<void> _pickPeriod() async {
    final filters = ref.read(reportFiltersProvider);
    final selected = await showMobileOptionSheet<ReportPeriod>(
      context: context,
      title: 'Period',
      selected: filters.period,
      options: [
        for (final period in [
          ReportPeriod.today,
          ReportPeriod.yesterday,
          ReportPeriod.thisWeek,
          ReportPeriod.lastWeek,
          ReportPeriod.thisMonth,
          ReportPeriod.lastMonth,
          ReportPeriod.thisQuarter,
          ReportPeriod.thisYear,
          ReportPeriod.allTime,
        ])
          MobileOption(value: period, label: period.label),
      ],
    );
    if (selected == null || !mounted) return;
    ref.read(reportFiltersProvider.notifier).setPeriod(selected);
    unawaited(ref.read(itemDetailReportProvider.notifier).refresh());
  }

  Future<void> _pickCustomRange() async {
    final filters = ref.read(reportFiltersProvider);
    final range = filters.effectiveDateRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: range,
    );
    if (picked == null || !mounted) return;
    ref.read(reportFiltersProvider.notifier).setCustomDateRange(picked);
    unawaited(ref.read(itemDetailReportProvider.notifier).refresh());
  }

  Future<void> _openItemPicker() async {
    final items =
        ref.read(inventoryItemsProvider).value?.items ??
        const <InventoryItem>[];
    if (items.isEmpty) return;

    final selected = await showModalBottomSheet<InventoryItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _ItemPickerSheet(items: items);
      },
    );
    if (selected == null || !mounted) return;
    _onItemSelected(selected);
  }

  void _onItemSelected(InventoryItem item) {
    _itemSearchController.text = item.name;
    ref.read(reportFiltersProvider.notifier).setItemId(item.id);
    unawaited(ref.read(itemDetailReportProvider.notifier).refresh());
  }

  List<ItemDetailDisplayRow> _displayRows(ItemDetailReportData? report) {
    final filters = ref.read(reportFiltersProvider);
    if (report == null) return const [];
    return buildItemDetailDisplayRows(
      apiRows: report.rows,
      range: filters.effectiveDateRange,
      hideInactiveDates: _hideInactiveDates,
    );
  }

  void _exportExcel(List<ItemDetailDisplayRow> rows) {
    reportExportTable(
      context: context,
      title: 'Item Detail Report',
      filename: 'item-detail-report',
      headers: const [
        'Date',
        'Sale qty',
        'Purchase qty',
        'Adjust qty',
        'Closing qty',
      ],
      rows: [
        for (final row in rows)
          [
            formatReportDate(row.date),
            row.saleQty.toStringAsFixed(1),
            row.purchaseQty.toStringAsFixed(1),
            row.adjustQty.toStringAsFixed(1),
            row.closingQty.toStringAsFixed(1),
          ],
      ],
    );
  }

  void _exportPdf(List<ItemDetailDisplayRow> rows) {
    reportPrintTable(
      context: context,
      title: 'Item Detail Report',
      headers: const [
        'Date',
        'Sale qty',
        'Purchase qty',
        'Adjust qty',
        'Closing qty',
      ],
      rows: [
        for (final row in rows)
          [
            formatReportDate(row.date),
            row.saleQty.toStringAsFixed(1),
            row.purchaseQty.toStringAsFixed(1),
            row.adjustQty.toStringAsFixed(1),
            row.closingQty.toStringAsFixed(1),
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final reportAsync = ref.watch(itemDetailReportProvider);
    final range = filters.effectiveDateRange;
    final displayRows = reportAsync.maybeWhen(
      data: _displayRows,
      orElse: () => _displayRows(reportAsync.value),
    );
    final hasItem = filters.itemId != null && filters.itemId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _headerTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Item Detail Report',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        actions: [
          _ExportChip(
            label: 'Pdf',
            backgroundColor: const Color(0xFFE53935),
            onTap: () => _exportPdf(displayRows),
          ),
          const Gap(AppSpacing.sm),
          _ExportChip(
            label: 'xls',
            backgroundColor: const Color(0xFF2E7D32),
            onTap: () => _exportExcel(displayRows),
          ),
          const Gap(AppSpacing.sm),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => unawaited(_pickPeriod()),
                    borderRadius: AppRadius.smBorder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              filters.periodLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronDown,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  color: const Color(0xFFE0E0E0),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => unawaited(_pickCustomRange()),
                    borderRadius: AppRadius.smBorder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const Gap(AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${formatReportDate(range.start)} to ${formatReportDate(range.end)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Checkbox(
                  value: _hideInactiveDates,
                  activeColor: _labelTeal,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) {
                    setState(() => _hideInactiveDates = value ?? false);
                  },
                ),
                const Text(
                  'Hide inactive dates',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Item Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _labelTeal,
                  ),
                ),
                const Gap(AppSpacing.xs),
                TextField(
                  controller: _itemSearchController,
                  readOnly: true,
                  onTap: () => unawaited(_openItemPicker()),
                  decoration: const InputDecoration(
                    hintText: 'Enter Name',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _labelTeal, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _TableHeader(),
          Expanded(
            child: reportAsync.when(
              loading: () => hasItem
                  ? const Center(child: CircularProgressIndicator())
                  : const MobileEmptyState(
                      title: 'Select an item',
                      message: 'Choose an item to view daily stock movement.',
                      icon: LucideIcons.package,
                    ),
              error: (error, _) => AppError(
                message: error.toString(),
                onRetry: () =>
                    ref.read(itemDetailReportProvider.notifier).refresh(),
              ),
              data: (_) {
                if (!hasItem) {
                  return const MobileEmptyState(
                    title: 'Select an item',
                    message: 'Choose an item to view daily stock movement.',
                    icon: LucideIcons.package,
                  );
                }
                if (displayRows.isEmpty) {
                  return const MobileEmptyState(
                    title: 'No data',
                    message: 'No movement for the selected period.',
                    icon: LucideIcons.chartBar,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: displayRows.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final row = displayRows[index];
                    return _TableRow(row: row);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportChip extends StatelessWidget {
  const _ExportChip({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
      decoration: TextDecoration.underline,
    );

    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Date', style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('Sale qty', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Purchase qty',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Adjust qty', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Closing qty',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.row});

  final ItemDetailDisplayRow row;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(formatReportDate(row.date), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.saleQty.toStringAsFixed(1),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.purchaseQty.toStringAsFixed(1),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.adjustQty.toStringAsFixed(1),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.closingQty.toStringAsFixed(1),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  const _ItemPickerSheet({required this.items});

  final List<InventoryItem> items;

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Item',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search item',
                prefixIcon: Icon(LucideIcons.search, size: 20),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const Gap(AppSpacing.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    title: Text(item.name),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
