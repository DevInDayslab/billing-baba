import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_delete_status_service.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/delete_status_dto.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_delete_dialogs.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_dialog.dart';
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
    await showEditPartyDialog(context, party: party);
  }

  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    PartyModel party, {
    VoidCallback? onSuccess,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    deleteFlow:
    while (context.mounted) {
      try {
        final deleteStatusService = await ref.read(
          partyDeleteStatusServiceProvider.future,
        );
        final status = await deleteStatusService.getDeleteStatus(party.id);
        if (!context.mounted) return;

        final confirmed = status.canDelete
            ? await showPartyDeleteDialog(context, partyName: party.name)
            : await showPartyInactiveDialog(
                context,
                references: status.references!,
              );

        if (confirmed != true || !context.mounted) return;

        final action = await ref
            .read(partyListProvider.notifier)
            .deleteParty(party.id);

        if (!context.mounted) return;
        onSuccess?.call();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              action == PartyDeleteAction.deleted
                  ? 'Party deleted successfully.'
                  : 'Party marked as inactive.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: _successSnackBarColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
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
        return;
      } on PartyException catch (e) {
        if (!context.mounted) return;
        messenger?.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      } on Object catch (_) {
        if (!context.mounted) return;
        final retry = await showPartyDeleteErrorDialog(
          context,
          message: 'Unable to delete party.',
          showRetry: true,
        );
        if (retry == true) {
          continue deleteFlow;
        }
        return;
      }
    }
  }

  static Future<void> restore(
    BuildContext context,
    WidgetRef ref,
    PartyModel party,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref.read(partyListProvider.notifier).restoreParty(party.id);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Party restored successfully.',
            style: TextStyle(
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
            'Restore saved offline. It will sync when you are back online.',
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
          content: Text('Something went wrong.'),
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
    await showDuplicatePartyDialog(context, party: party);
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
}
