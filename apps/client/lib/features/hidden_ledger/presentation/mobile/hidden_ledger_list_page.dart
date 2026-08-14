import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/shared/chart/chart_axis_formatters.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileHiddenLedgerListPage extends ConsumerWidget {
  const MobileHiddenLedgerListPage({super.key});

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _openEntry(BuildContext context, WidgetRef ref, String entryId) async {
    try {
      final service = await ref.read(hiddenLedgerServiceProvider.future);
      final detail = await service.getEntry(entryId);
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  detail.partyName ?? 'Hidden ledger entry',
                  style: AppTypography.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  label: 'Invoice',
                  value: detail.invoiceNumber ?? '—',
                ),
                _DetailRow(
                  label: 'Amount',
                  value: _currency.format(detail.amount),
                ),
                _DetailRow(
                  label: 'Recovered',
                  value: _currency.format(detail.recoveredAmount),
                ),
                _DetailRow(
                  label: 'Remaining',
                  value: _currency.format(detail.remainingAmount),
                ),
                _DetailRow(label: 'Status', value: detail.statusLabel),
                if (detail.createdAt != null)
                  _DetailRow(
                    label: 'Created',
                    value: _dateFormat.format(detail.createdAt!),
                  ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OfflineUiMessages.messageFor(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(hiddenLedgerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Hidden ledger',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: OfflineUiMessages.messageFor(error),
          onRetry: () => ref.invalidate(hiddenLedgerListProvider),
        ),
        data: (page) {
          if (page.entries.isEmpty) {
            return const Center(
              child: Text(
                'No hidden ledger entries',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hiddenLedgerListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: page.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = page.entries[index];
                return _EntryTile(
                  entry: entry,
                  onTap: () => _openEntry(context, ref, entry.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap});

  final HiddenLedgerEntryModel entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          entry.partyName ?? 'Party',
          style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${entry.invoiceNumber ?? 'No invoice'} · ${entry.statusLabel}',
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          ChartAxisFormatters.formatCurrency(entry.remainingAmount),
          style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w700),
        ),
      ),
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.inter(fontSize: AppTypography.bodySize, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
