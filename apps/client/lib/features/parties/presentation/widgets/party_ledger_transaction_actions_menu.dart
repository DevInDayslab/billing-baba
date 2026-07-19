import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_transaction_table_actions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _menuMinWidth = 220.0;
const _menuBorderColor = Color(0xFFE0E0E0);

/// Instant ⋮ menu for a ledger row. Opens synchronously via [SalesActionMenuButton];
/// document resolution runs only after the user selects an action.
class PartyLedgerTransactionActionsMenu extends ConsumerWidget {
  const PartyLedgerTransactionActionsMenu({
    required this.transaction,
    super.key,
  });

  final PartyLedgerTransactionModel transaction;

  /// Opens the same action menu as the row overflow button at [globalPosition].
  static Future<void> showAtPosition({
    required BuildContext context,
    required WidgetRef ref,
    required PartyLedgerTransactionModel transaction,
    required Offset globalPosition,
  }) async {
    final referenceId = transaction.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) {
      return;
    }

    final menuItems = PartyLedgerTransactionTableActions.buildMenuItems(
      transaction: transaction,
      context: context,
      ref: ref,
    );
    if (menuItems.isEmpty || !context.mounted) {
      return;
    }

    final overlay =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()!
            as RenderBox;

    final selectedIndex = await showMenu<int>(
      context: context,
      useRootNavigator: true,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      color: AppColors.surface,
      shadowColor: Colors.black26,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: const BorderSide(color: _menuBorderColor),
      ),
      constraints: const BoxConstraints(minWidth: _menuMinWidth),
      items: _popupMenuEntries(menuItems),
    );

    if (selectedIndex == null || !context.mounted) {
      return;
    }

    await menuItems[selectedIndex].onSelected();
  }

  static List<PopupMenuEntry<int>> _popupMenuEntries(
    List<SalesActionMenuItem> items,
  ) {
    final entries = <PopupMenuEntry<int>>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item.dividerBefore) {
        entries.add(const PopupMenuDivider(height: 1));
      }
      entries.add(
        PopupMenuItem<int>(
          value: index,
          height: 44,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: item.isDestructive
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
        ),
      );
    }
    return entries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceId = transaction.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) {
      return const SizedBox(width: 32, height: 32);
    }

    return SalesActionMenuButton(
      items: PartyLedgerTransactionTableActions.buildMenuItems(
        transaction: transaction,
        context: context,
        ref: ref,
      ),
    );
  }
}
