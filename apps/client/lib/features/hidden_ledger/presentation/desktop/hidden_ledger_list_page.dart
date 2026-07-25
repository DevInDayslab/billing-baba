import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_filters.dart';
import 'package:billing_baba/features/hidden_ledger/models/paginated_hidden_ledger_entries.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_entry_detail_sheet.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DesktopHiddenLedgerListPage extends ConsumerStatefulWidget {
  const DesktopHiddenLedgerListPage({super.key});

  @override
  ConsumerState<DesktopHiddenLedgerListPage> createState() =>
      _HiddenLedgerListPageState();
}

class _HiddenLedgerListPageState extends ConsumerState<DesktopHiddenLedgerListPage> {
  final _searchController = TextEditingController();
  final _invoiceController = TextEditingController();
  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _searchController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _applyFilters({int page = 1}) {
    final current = ref.read(hiddenLedgerFiltersStateProvider);
    ref.read(hiddenLedgerFiltersStateProvider.notifier).update(
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
    ref.read(hiddenLedgerFiltersStateProvider.notifier).update(
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
    ref.read(hiddenLedgerFiltersStateProvider.notifier).update(
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PartyPageTitleBar(currentRoute: AppRoutes.partyHiddenLedger),
              const SizedBox(height: AppSpacing.md),
              _buildFilterBar(filters),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: listAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _ErrorState(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(hiddenLedgerListProvider),
                  ),
                  data: (page) {
                    if (page.entries.isEmpty) {
                      return const _EmptyState();
                    }
                    return Column(
                      children: [
                        Expanded(child: _buildTable(page.entries)),
                        const SizedBox(height: AppSpacing.sm),
                        _buildPagination(page),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(HiddenLedgerFilters filters) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
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
                ref.read(hiddenLedgerFiltersStateProvider.notifier).update(
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
              TextButton(onPressed: _clearDateRange, child: const Text('Clear dates')),
            FilledButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<HiddenLedgerEntryModel> entries) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 960),
          child: DataTable(
            headingRowColor: const WidgetStatePropertyAll(Color(0xFFF5F7FA)),
            columns: const [
              DataColumn(label: Text('Party')),
              DataColumn(label: Text('Invoice')),
              DataColumn(label: Text('Original'), numeric: true),
              DataColumn(label: Text('Recovered'), numeric: true),
              DataColumn(label: Text('Remaining'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('')),
            ],
            rows: entries.map((entry) {
              return DataRow(
                onSelectChanged: (_) => _openEntryDetail(entry),
                cells: [
                  DataCell(Text(entry.partyName ?? entry.partyId)),
                  DataCell(Text(entry.invoiceNumber ?? '—')),
                  DataCell(Text(_currency.format(entry.amount))),
                  DataCell(Text(_currency.format(entry.recoveredAmount))),
                  DataCell(Text(_currency.format(entry.remainingAmount))),
                  DataCell(_StatusChip(status: entry.status)),
                  DataCell(
                    Text(
                      entry.createdAt != null
                          ? _dateFormat.format(entry.createdAt!.toLocal())
                          : '—',
                    ),
                  ),
                  const DataCell(Icon(Icons.chevron_right, size: 20)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
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
                  ? () => ref.read(hiddenLedgerListProvider.notifier).goToPage(page.page - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page ${page.page} of ${page.totalPages}'),
            IconButton(
              onPressed: page.hasNextPage
                  ? () => ref.read(hiddenLedgerListProvider.notifier).goToPage(page.page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
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

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
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
          Icon(Icons.visibility_off_outlined, size: 48, color: AppColors.textSecondary),
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
