import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showHiddenLedgerEntryDetailSheet(
  BuildContext context, {
  required String entryId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => HiddenLedgerEntryDetailSheet(entryId: entryId),
  );
}

class HiddenLedgerEntryDetailSheet extends ConsumerWidget {
  const HiddenLedgerEntryDetailSheet({required this.entryId, super.key});

  final String entryId;

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(hiddenLedgerEntryDetailProvider(entryId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: detailAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load entry: $error'),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(hiddenLedgerEntryDetailProvider(entryId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (entry) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Hidden Ledger Entry',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(label: 'Party', value: entry.partyName ?? entry.partyId),
                _DetailRow(
                  label: 'Invoice',
                  value: entry.invoiceNumber ?? '—',
                ),
                _DetailRow(
                  label: 'Original amount',
                  value: _currency.format(entry.amount),
                ),
                _DetailRow(
                  label: 'Recovered amount',
                  value: _currency.format(entry.recoveredAmount),
                ),
                _DetailRow(
                  label: 'Remaining amount',
                  value: _currency.format(entry.remainingAmount),
                ),
                _DetailRow(label: 'Status', value: entry.statusLabel),
                _DetailRow(
                  label: 'Created',
                  value: entry.createdAt != null
                      ? _dateTimeFormat.format(entry.createdAt!.toLocal())
                      : '—',
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Recovery History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (entry.recoveries.isEmpty)
                  const Text(
                    'No recoveries recorded yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...entry.recoveries.map(
                    (recovery) => _RecoveryTile(
                      recovery: recovery,
                      currency: _currency,
                      dateTimeFormat: _dateTimeFormat,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryTile extends StatelessWidget {
  const _RecoveryTile({
    required this.recovery,
    required this.currency,
    required this.dateTimeFormat,
  });

  final HiddenLedgerRecoveryModel recovery;
  final NumberFormat currency;
  final DateFormat dateTimeFormat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: const Icon(Icons.restore, color: Colors.green),
        title: Text(currency.format(recovery.recoveredAmount)),
        subtitle: Text(
          recovery.createdAt != null
              ? dateTimeFormat.format(recovery.createdAt!.toLocal())
              : 'Recovery recorded',
        ),
        trailing: recovery.saleId != null
            ? const Tooltip(
                message: 'Linked to sale markup recovery',
                child: Icon(Icons.receipt_long_outlined, size: 20),
              )
            : null,
      ),
    );
  }
}
