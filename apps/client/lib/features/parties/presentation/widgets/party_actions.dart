import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/payment_in_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

/// Shared party action handlers for the detail header menu and related entry points.
abstract final class PartyActions {
  static bool canReceivePayment(PartyModel party) =>
      PartyTypeFilter.customer.matches(party.partyType);

  static bool canRecordPayment(PartyModel party) =>
      PartyTypeFilter.supplier.matches(party.partyType);

  static Future<void> edit(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final result = await showEditPartyDialog(context, party: party);
    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref.read(partyListProvider.notifier).updateParty(
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

  static Future<void> delete(
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

  static Future<void> duplicate(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final result = await showDuplicatePartyDialog(context, party: party);
    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref.read(partyListProvider.notifier).createParty(result);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Party "${result.partyName}" saved successfully',
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
            'Party saved offline. It will sync when you are back online.',
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

  static Future<void> receivePayment(
    BuildContext context,
    PartyModel party,
  ) async {
    await showPaymentInDialog(
      context,
      initialPartyId: party.id,
      initialPartyName: party.name,
    );
  }

  static Future<void> recordPayment(
    BuildContext context,
    PartyModel party,
  ) async {
    await showPaymentOutDialog(
      context,
      initialPartyId: party.id,
      initialPartyName: party.name,
    );
  }

  static Future<void> viewHistory(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    await ref.read(partyTimelineProvider(party.id).notifier).refresh();
  }

  static Future<void> _offerDeactivateParty(
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
