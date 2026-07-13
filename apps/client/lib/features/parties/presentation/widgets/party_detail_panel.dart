import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_ledger_transactions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          _PartyDetailHeader(
            party: party,
            onBack: onBack,
            onEdit: () => _editParty(context, ref, party),
            onDelete: () => _confirmDeleteParty(context, ref, party),
          ),
          Expanded(
            child: _PartyTransactionsBody(partyId: party.id),
          ),
        ],
      ),
    );
  }

  Future<void> _editParty(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
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

  Future<void> _confirmDeleteParty(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete party?'),
        content: Text(
          'Are you sure you want to delete "${party.name}"?\n\n'
          'If this party is linked to invoices or purchases, it will be '
          'deactivated instead. Transaction history will be preserved.',
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
    } on PartyHasDependenciesException {
      if (!context.mounted) return;
      await _offerDeactivateParty(context, ref, party, messenger);
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
    } on Object catch (_) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Failed to delete party. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _offerDeactivateParty(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
    ScaffoldMessengerState? messenger,
  ) async {
    final deactivate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate party instead?'),
        content: Text(
          '"${party.name}" is linked to invoices or other documents and '
          'cannot be permanently deleted.\n\n'
          'Deactivate it to hide it from active lists. You can view inactive '
          'parties using the list filter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (deactivate != true || !context.mounted) return;

    try {
      await ref.read(partyListProvider.notifier).deactivateParty(party.id);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Party "${party.name}" deactivated',
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
            'Deactivation saved offline. It will sync when you are back online.',
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
    } on Object catch (_) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Failed to deactivate party. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PartyDetailHeader extends StatelessWidget {
  const _PartyDetailHeader({
    required this.party,
    required this.onEdit,
    required this.onDelete,
    this.onBack,
  });

  final PartyModel party;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: 'Back to list',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    party.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Edit party',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ),
          _HeaderActionIcon(
            icon: Icons.chat_bubble_outline,
            tooltip: 'Message',
            onTap: () => _showComingSoon(context, 'Messaging'),
          ),
          _HeaderActionIcon(
            icon: Icons.phone_in_talk_outlined,
            tooltip: 'WhatsApp',
            onTap: () => _showComingSoon(context, 'WhatsApp'),
          ),
          _HeaderActionIcon(
            icon: Icons.schedule_outlined,
            tooltip: 'Reminders',
            onTap: () => _showComingSoon(context, 'Reminders'),
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: AppColors.textSecondary,
            ),
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete party')),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: AppColors.textSecondary,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _PartyTransactionsBody extends ConsumerWidget {
  const _PartyTransactionsBody({required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(partyLedgerProvider(partyId));

    return ledgerAsync.when(
      loading: () => const PartyLedgerTransactionsSection(
        transactions: [],
        isLoading: true,
      ),
      error: (error, _) => PartyLedgerTransactionsSection(
        transactions: const [],
        errorMessage: PartyErrorMapper.messageFor(error),
        onRetry: () => ref.invalidate(partyLedgerProvider(partyId)),
      ),
      data: (ledger) => PartyLedgerTransactionsSection(
        transactions: ledger.transactions,
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
