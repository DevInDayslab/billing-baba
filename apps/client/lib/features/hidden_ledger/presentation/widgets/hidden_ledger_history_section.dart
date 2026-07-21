import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/widgets/hidden_ledger_entry_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Seller-only history of hidden ledger entries and recoveries for a party.
class HiddenLedgerHistorySection extends ConsumerWidget {
  const HiddenLedgerHistorySection({required this.partyId, super.key});

  final String partyId;

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(partyHiddenLedgerEntriesProvider(partyId));

    return entriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Card(
            color: const Color(0xFFFFF8E1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.visibility_off_outlined, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Hidden Ledger History',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.partyHiddenLedger),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...entries.take(5).map((entry) => _EntryRow(entry: entry)),
                  if (entries.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        '+ ${entries.length - 5} more entries',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry});

  final HiddenLedgerEntryModel entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => showHiddenLedgerEntryDetailSheet(
        context,
        entryId: entry.id,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.invoiceNumber ?? 'No invoice',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${entry.statusLabel} · '
                    '${HiddenLedgerHistorySection._dateFormat.format(entry.createdAt?.toLocal() ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  HiddenLedgerHistorySection._currency.format(entry.amount),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Remaining ${HiddenLedgerHistorySection._currency.format(entry.remainingAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
