import 'dart:math' as math;

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_filters.dart';
import 'package:billing_baba/features/hidden_ledger/models/paginated_hidden_ledger_entries.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_entry_detail_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_page_title_bar.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _minTableWidth = 960.0;

class DesktopHiddenLedgerListPage extends ConsumerStatefulWidget {
  const DesktopHiddenLedgerListPage({super.key});

  @override
  ConsumerState<DesktopHiddenLedgerListPage> createState() =>
      _HiddenLedgerListPageState();
}

class _HiddenLedgerListPageState
    extends ConsumerState<DesktopHiddenLedgerListPage> {
  final _searchController = TextEditingController();
  final _invoiceController = TextEditingController();
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _searchController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _applyFilters({int page = 1}) {
    final current = ref.read(hiddenLedgerFiltersStateProvider);
    ref
        .read(hiddenLedgerFiltersStateProvider.notifier)
        .update(
          current.copyWith(
            searchQuery: _searchController.text,
            invoiceNumber: _invoiceController.text,
            page: page,
          ),
        );
    ref.invalidate(hiddenLedgerListProvider);
  }

  Future<void> _pickDateRange() async {
    final current = ref.read(hiddenLedgerFiltersStateProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: current.from != null && current.to != null
          ? DateTimeRange(start: current.from!, end: current.to!)
          : null,
    );
    if (range == null) return;

    final filters = ref.read(hiddenLedgerFiltersStateProvider);
    ref
        .read(hiddenLedgerFiltersStateProvider.notifier)
        .update(
          filters.copyWith(
            from: range.start,
            to: range.end,
            page: 1,
          ),
        );
    ref.invalidate(hiddenLedgerListProvider);
  }

  void _clearDateRange() {
    final filters = ref.read(hiddenLedgerFiltersStateProvider);
    ref
        .read(hiddenLedgerFiltersStateProvider.notifier)
        .update(
          filters.copyWith(clearFrom: true, clearTo: true, page: 1),
        );
    ref.invalidate(hiddenLedgerListProvider);
  }

  Future<void> _openEntryDetail(HiddenLedgerEntryModel entry) async {
    await showHiddenLedgerEntryDetailSheet(context, entryId: entry.id);
    if (!mounted) return;
    ref.invalidate(hiddenLedgerListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(hiddenLedgerFiltersStateProvider);
    final listAsync = ref.watch(hiddenLedgerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PartyPageTitleBar(
                currentRoute: AppRoutes.partyHiddenLedger,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _buildContentShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _buildFilterBar(filters),
                      ),
                      const Divider(height: 1, thickness: 1),
                      Expanded(
                        child: listAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => _ErrorState(
                            message: OfflineUiMessages.messageFor(error),
                            onRetry: () =>
                                ref.invalidate(hiddenLedgerListProvider),
                          ),
                          data: (page) {
                            if (page.entries.isEmpty) {
                              return const _EmptyState();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildTable(page.entries),
                                ),
                                const Divider(height: 1, thickness: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: _buildPagination(page),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentShell({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: inventoryCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: child,
      ),
    );
  }

  Widget _buildFilterBar(HiddenLedgerFilters filters) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search party or invoice',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        SizedBox(
          width: 180,
          child: TextField(
            controller: _invoiceController,
            decoration: const InputDecoration(
              labelText: 'Invoice number',
              isDense: true,
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        DropdownMenu<String?>(
          initialSelection: filters.status,
          label: const Text('Status'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: null, label: 'All'),
            DropdownMenuEntry(value: 'pending', label: 'Pending'),
            DropdownMenuEntry(value: 'partial', label: 'Partial'),
            DropdownMenuEntry(value: 'recovered', label: 'Recovered'),
          ],
          onSelected: (value) {
            final current = ref.read(hiddenLedgerFiltersStateProvider);
            ref
                .read(hiddenLedgerFiltersStateProvider.notifier)
                .update(
                  current.copyWith(
                    status: value,
                    clearStatus: value == null,
                    page: 1,
                  ),
                );
            ref.invalidate(hiddenLedgerListProvider);
          },
        ),
        OutlinedButton.icon(
          onPressed: _pickDateRange,
          icon: const Icon(Icons.date_range, size: 18),
          label: Text(
            filters.from != null && filters.to != null
                ? '${_dateFormat.format(filters.from!)} – ${_dateFormat.format(filters.to!)}'
                : 'Date range',
          ),
        ),
        if (filters.from != null || filters.to != null)
          TextButton(
            onPressed: _clearDateRange,
            child: const Text('Clear dates'),
          ),
        FilledButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildTable(List<HiddenLedgerEntryModel> entries) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.isFinite
            ? math.max(constraints.maxWidth, _minTableWidth)
            : _minTableWidth;

        final table = SizedBox(
          width: tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HiddenLedgerTableHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < entries.length; i++)
                        InventoryListTableRow(
                          index: i,
                          onTap: () => _openEntryDetail(entries[i]),
                          child: _HiddenLedgerTableRow(
                            entry: entries[i],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        if (constraints.maxWidth >= _minTableWidth) {
          return table;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: constraints.maxHeight,
            child: table,
          ),
        );
      },
    );
  }

  Widget _buildPagination(PaginatedHiddenLedgerEntries page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${page.entries.length} of ${page.total} entries',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Row(
          children: [
            IconButton(
              onPressed: page.hasPreviousPage
                  ? () => ref
                        .read(hiddenLedgerListProvider.notifier)
                        .goToPage(page.page - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page ${page.page} of ${page.totalPages}'),
            IconButton(
              onPressed: page.hasNextPage
                  ? () => ref
                        .read(hiddenLedgerListProvider.notifier)
                        .goToPage(page.page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _HiddenLedgerTableHeader extends StatelessWidget {
  const _HiddenLedgerTableHeader();

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F7FA),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: const [
            Expanded(flex: 3, child: Text('PARTY', style: _headerStyle)),
            Expanded(flex: 2, child: Text('INVOICE', style: _headerStyle)),
            Expanded(
              flex: 2,
              child: Text(
                'ORIGINAL',
                style: _headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'RECOVERED',
                style: _headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'REMAINING',
                style: _headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
            Expanded(
              flex: 2,
              child: Text(
                'CREATED',
                style: _headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}

class _HiddenLedgerTableRow extends StatelessWidget {
  const _HiddenLedgerTableRow({required this.entry});

  final HiddenLedgerEntryModel entry;

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _dateFormat = DateFormat('dd MMM yyyy');

  static const _cellStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppEllipsisText(
              entry.partyName ?? entry.partyId,
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: AppEllipsisText(
              entry.invoiceNumber ?? '—',
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: AppEllipsisText(
              _currency.format(entry.amount),
              textAlign: TextAlign.right,
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: AppEllipsisText(
              _currency.format(entry.recoveredAmount),
              textAlign: TextAlign.right,
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: AppEllipsisText(
              _currency.format(entry.remainingAmount),
              textAlign: TextAlign.right,
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusChip(status: entry.status),
          ),
          Expanded(
            flex: 2,
            child: AppEllipsisText(
              entry.createdAt != null
                  ? _dateFormat.format(entry.createdAt!.toLocal())
                  : '—',
              textAlign: TextAlign.right,
              style: _cellStyle,
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'partial' => ('Partial', Colors.orange),
      'recovered' => ('Recovered', Colors.green),
      _ => ('Pending', Colors.amber.shade800),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: color.withValues(alpha: 0.12),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.sm),
          Text('No hidden ledger entries found'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
