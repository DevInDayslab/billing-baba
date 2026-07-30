import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Seller-only summary of hidden ledger balance for a party.
class HiddenLedgerSummaryTile extends ConsumerWidget {
  const HiddenLedgerSummaryTile({
    required this.partyId,
    super.key,
  });

  final String partyId;

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(partyHiddenLedgerSummaryProvider(partyId));

    return summaryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        if (summary.hiddenLedgerBalance <= 0 && summary.pendingEntries <= 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _SummaryCard(summary: summary),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final HiddenLedgerPartySummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.visibility_off_outlined, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hidden Ledger (seller only)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Hidden balance: ${HiddenLedgerSummaryTile._currency.format(summary.hiddenLedgerBalance)}'
                    ' · ${summary.pendingEntries} open ${summary.pendingEntries == 1 ? 'entry' : 'entries'}',
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
