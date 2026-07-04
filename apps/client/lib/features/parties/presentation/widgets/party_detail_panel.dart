import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class PartyDetailPanel extends ConsumerWidget {
  const PartyDetailPanel({
    required this.partyId,
    this.onBack,
    super.key,
  });

  final String partyId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(partyDetailProvider(partyId));
    final usingCache = ref.watch(partiesUsingCacheProvider);

    return detailAsync.when(
      loading: () => const _PartyDetailLoading(),
      error: (error, _) => _PartyDetailError(
        message: PartyErrorMapper.messageFor(error),
        onRetry: () => ref.invalidate(partyDetailProvider(partyId)),
      ),
      data: (party) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (usingCache)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: _OfflineBanner(),
            ),
          Expanded(
            child: _PartyDetailContent(
              party: party,
              onBack: onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyDetailContent extends ConsumerWidget {
  const _PartyDetailContent({
    required this.party,
    this.onBack,
  });

  final PartyModel party;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFlexibleSummary = constraints.maxHeight < 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (useFlexibleSummary)
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: _PartySummaryHeader(
                    party: party,
                    onBack: onBack,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                child: _PartySummaryHeader(
                  party: party,
                  onBack: onBack,
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'TRANSACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: _TransactionsEmptyState(),
            ),
          ],
        );
      },
    );
  }
}

class _PartySummaryHeader extends ConsumerWidget {
  const _PartySummaryHeader({
    required this.party,
    this.onBack,
  });

  final PartyModel party;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessName = ref.watch(sidebarBusinessProvider).name;
    final detailRows = _buildDetailRows(businessName);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to list',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  party.name,
                  style: ListPanelStyles.panelTitleStyle,
                ),
              ),
              IconButton(
                onPressed: () => _editParty(context, ref),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit party',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () => _confirmDeleteParty(context, ref),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                tooltip: 'Delete party',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryCards(party: party),
          const SizedBox(height: AppSpacing.md),
          _PartyDetailsTable(rows: detailRows),
        ],
      ),
    );
  }

  List<_PartyDetailItem> _buildDetailRows(String businessName) {
    return [
      _PartyDetailItem(
        label: 'Phone',
        value: PartyModel.displayOrDash(party.phone),
      ),
      _PartyDetailItem(
        label: 'Email',
        value: PartyModel.displayOrDash(party.email),
      ),
      _PartyDetailItem(
        label: 'GSTIN',
        value: PartyModel.displayOrDash(party.gstin),
      ),
      _PartyDetailItem(label: 'Type', value: party.partyTypeLabel),
      _PartyDetailItem(
        label: 'Notes',
        value: PartyModel.displayOrDash(party.notes),
      ),
      _PartyDetailItem(
        label: 'Created Date',
        value: PartyModel.displayDate(party.createdAt),
      ),
      _PartyDetailItem(
        label: 'Updated Date',
        value: PartyModel.displayDate(party.updatedAt),
      ),
      _PartyDetailItem(
        label: 'Business Name',
        value: PartyModel.displayOrDash(businessName),
      ),
    ];
  }

  Future<void> _editParty(BuildContext context, WidgetRef ref) async {
    final result = await showEditPartyDialog(context, party: party);
    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref
          .read(partyListProvider.notifier)
          .updateParty(
            party.id,
            result,
            isActive: party.isActive,
          );
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Party "${result.partyName}" updated successfully',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: _successSnackBarColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PartyOfflineException {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Update saved offline. It will sync when you are back online.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiValidationException catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PartyException catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteParty(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete party?'),
        content: Text(
          'Are you sure you want to delete "${party.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref.read(partyListProvider.notifier).deleteParty(party.id);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Party "${party.name}" deleted',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: _successSnackBarColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PartyOfflineException {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Delete queued offline. It will sync when you are back online.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PartyException catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.party});

  final PartyModel party;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _SummaryCard(
          label: 'Opening Balance',
          value: PartyModel.displayCurrency(party.openingBalance),
        ),
        _SummaryCard(
          label: 'Outstanding',
          value: party.balance == 0
              ? '—'
              : NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹',
                  decimalDigits: 2,
                ).format(party.balance.abs()),
        ),
        _SummaryCard(
          label: 'Credit Limit',
          value: party.hasCustomCreditLimit
              ? PartyModel.displayCurrency(
                  double.tryParse(party.creditLimit),
                )
              : '—',
        ),
        _SummaryCard(
          label: 'Status',
          value: party.statusLabel,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: listPanelCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyDetailItem {
  const _PartyDetailItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _PartyDetailsTable extends StatelessWidget {
  const _PartyDetailsTable({required this.rows});

  final List<_PartyDetailItem> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(140),
        1: FlexColumnWidth(),
      },
      children: [
        for (final row in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  row.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  row.value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No transactions available.',
              style: ListPanelStyles.emptyStateStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyDetailLoading extends StatelessWidget {
  const _PartyDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _PartyDetailError extends StatelessWidget {
  const _PartyDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Colors.orange.shade800,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Network unavailable. Showing cached data.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
