import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/features/crm/application/lead_error_mapper.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_provider.dart';
import 'package:billing_baba/features/crm/presentation/providers/leads_selection_providers.dart';
import 'package:billing_baba/features/crm/presentation/widgets/lead_status_chip.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _checkboxColWidth = 40.0;
const _companyColWidth = 140.0;
const _emailColWidth = 160.0;
const _phoneColWidth = 110.0;
const _sourceColWidth = 120.0;
const _actionsColWidth = 48.0;
const _rowHoverColor = Color(0xFFF5F5F5);

const double _minTableWidth =
    _checkboxColWidth +
    _companyColWidth +
    _emailColWidth +
    _phoneColWidth +
    _sourceColWidth +
    _actionsColWidth +
    salesTableColGap * 6 +
    180;

class LeadsTable extends ConsumerWidget {
  const LeadsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);
    final paginated = ref.watch(paginatedLeadsProvider);
    final notifier = ref.read(leadsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: salesCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Spacer(),
                ExpandableTableSearchField(
                  hint: 'Search Lead Name',
                  initialQuery: ref.read(leadSearchQueryProvider),
                  onQueryChanged: (query) {
                    ref.read(leadSearchQueryProvider.notifier).query = query;
                    ref.read(leadFiltersProvider.notifier).setSearchQuery(query);
                    unawaited(notifier.refresh());
                  },
                ),
                IconButton(
                  onPressed: notifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: salesCardBorder),
          leadsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const SalesLoadingState(),
            error: (error, _) => SalesErrorState(
              message: LeadErrorMapper.messageFor(error),
              onRetry: notifier.refresh,
            ),
            data: (_) {
              if (paginated.totalItems == 0) {
                return const _LeadsEmptyState();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth.clamp(
                    _minTableWidth,
                    double.infinity,
                  );

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LeadsHeaderRow(
                            pageLeadIds: paginated.items.map((l) => l.id),
                          ),
                          for (var i = 0; i < paginated.items.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, color: salesCardBorder),
                            _LeadTableRow(lead: paginated.items[i]),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const Divider(height: 1, color: salesCardBorder),
          _LeadsPaginationRow(paginated: paginated),
        ],
      ),
    );
  }
}

class _LeadsHeaderRow extends ConsumerWidget {
  const _LeadsHeaderRow({
    required this.pageLeadIds,
  });

  final Iterable<String> pageLeadIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(leadFiltersProvider);
    final filtersNotifier = ref.read(leadFiltersProvider.notifier);
    final selectedIds = ref.watch(selectedLeadIdsProvider);
    final pageIds = pageLeadIds.toList();
    final allSelectedOnPage =
        pageIds.isNotEmpty && pageIds.every(selectedIds.contains);
    final someSelectedOnPage = pageIds.any(selectedIds.contains);
    final headerCheckboxValue = allSelectedOnPage
        ? true
        : (someSelectedOnPage ? null : false);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SalesTableCell(
            width: _checkboxColWidth,
            gapAfter: salesTableColGap,
            child: Checkbox(
              value: headerCheckboxValue,
              tristate: true,
              onChanged: pageIds.isEmpty
                  ? null
                  : (_) => ref
                        .read(selectedLeadIdsProvider.notifier)
                        .toggleAll(pageIds),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(
            child: _LeadsSortableHeaderCell(
              label: 'Lead Name',
              column: LeadSortColumn.name,
              filters: filters,
              onSort: filtersNotifier.toggleSort,
            ),
          ),
          _LeadsSortableHeaderCell(
            label: 'Company',
            column: LeadSortColumn.company,
            filters: filters,
            onSort: filtersNotifier.toggleSort,
            width: _companyColWidth,
          ),
          _LeadsSortableHeaderCell(
            label: 'Email',
            column: LeadSortColumn.email,
            filters: filters,
            onSort: filtersNotifier.toggleSort,
            width: _emailColWidth,
          ),
          _LeadsSortableHeaderCell(
            label: 'Phone',
            column: LeadSortColumn.phone,
            filters: filters,
            onSort: filtersNotifier.toggleSort,
            width: _phoneColWidth,
          ),
          _LeadsSortableHeaderCell(
            label: 'Lead Source',
            column: LeadSortColumn.leadSource,
            filters: filters,
            onSort: filtersNotifier.toggleSort,
            width: _sourceColWidth,
          ),
          const SalesTableHeaderCell(
            label: 'Actions',
            width: _actionsColWidth,
            gapAfter: 0,
          ),
        ],
      ),
    );
  }
}

class _LeadsSortableHeaderCell extends StatelessWidget {
  const _LeadsSortableHeaderCell({
    required this.label,
    required this.column,
    required this.filters,
    required this.onSort,
    this.width,
  });

  final String label;
  final LeadSortColumn column;
  final LeadFiltersState filters;
  final ValueChanged<LeadSortColumn> onSort;
  final double? width;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  @override
  Widget build(BuildContext context) {
    final isActive = filters.sortColumn == column;
    final sortIcon = switch (filters.sortDirection) {
      LeadSortDirection.ascending when isActive => Icons.arrow_upward,
      LeadSortDirection.descending when isActive => Icons.arrow_downward,
      _ => Icons.swap_vert,
    };

    final child = InkWell(
      onTap: () => onSort(column),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: _headerStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            sortIcon,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );

    if (width != null) {
      return SalesTableCell(width: width, child: child);
    }

    return SalesTableCell(child: child);
  }
}

class _LeadTableRow extends ConsumerStatefulWidget {
  const _LeadTableRow({required this.lead});

  final Lead lead;

  @override
  ConsumerState<_LeadTableRow> createState() => _LeadTableRowState();
}

class _LeadTableRowState extends ConsumerState<_LeadTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final selectedIds = ref.watch(selectedLeadIdsProvider);
    final isSelected = selectedIds.contains(lead.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ColoredBox(
        color: _isHovered ? _rowHoverColor : Colors.transparent,
        child: SalesTableDataRow(
          children: [
            SalesTableCell(
              width: _checkboxColWidth,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => ref
                    .read(selectedLeadIdsProvider.notifier)
                    .toggle(lead.id),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(
              child: SalesTableCell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    LeadStatusChip(status: lead.status),
                  ],
                ),
              ),
            ),
            SalesTableCell(
              width: _companyColWidth,
              child: _MutedOrDashText(lead.displayCompany),
            ),
            SalesTableCell(
              width: _emailColWidth,
              child: _MutedOrDashText(lead.displayEmail),
            ),
            SalesTableCell(
              width: _phoneColWidth,
              child: _MutedOrDashText(lead.displayPhone),
            ),
            SalesTableCell(
              width: _sourceColWidth,
              child: lead.leadSource == null
                  ? const _MutedOrDashText('—')
                  : LeadSourceBadge(source: lead.leadSource),
            ),
            SalesTableCell(
              width: _actionsColWidth,
              gapAfter: 0,
              child: SalesActionMenuButton(
                items: [
                  SalesActionMenuItem(
                    label: 'Edit',
                    onSelected: () async {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit lead is not available yet'),
                        ),
                      );
                    },
                  ),
                  SalesActionMenuItem(
                    label: 'Delete',
                    onSelected: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete lead?'),
                          content: Text(
                            'Are you sure you want to delete "${lead.name}"?',
                          ),
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
                      await ref
                          .read(leadsProvider.notifier)
                          .deleteLead(lead.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MutedOrDashText extends StatelessWidget {
  const _MutedOrDashText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '—';
    return Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: isDash ? AppColors.textSecondary : AppColors.textPrimary,
      ),
    );
  }
}

class _LeadsEmptyState extends StatelessWidget {
  const _LeadsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No leads found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadsPaginationRow extends ConsumerWidget {
  const _LeadsPaginationRow({required this.paginated});

  final PaginatedLeads paginated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersNotifier = ref.read(leadFiltersProvider.notifier);
    final canGoPrevious = paginated.currentPage > 1;
    final canGoNext = paginated.currentPage < paginated.totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Total Records: ${paginated.totalItems}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (paginated.totalItems > 0)
            Text(
              '${paginated.rangeStart} to ${paginated.rangeEnd}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          IconButton(
            onPressed: canGoPrevious
                ? () => filtersNotifier.setPage(paginated.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          IconButton(
            onPressed: canGoNext
                ? () => filtersNotifier.setPage(paginated.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}
