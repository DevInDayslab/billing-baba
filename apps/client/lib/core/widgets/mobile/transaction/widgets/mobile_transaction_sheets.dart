import 'package:billing_baba/core/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';

/// Opens the reusable transaction filter bottom sheet.
Future<String?> showMobileTransactionFilterSheet({
  required BuildContext context,
  required List<MobileFilterOption> options,
  String? selectedKey,
}) {
  final allOptions = [
    const MobileOption(
      value: MobileFilterOption.allKey,
      label: 'All',
      subtitle: 'Show all transactions',
    ),
    ...options.map(
      (option) => MobileOption(
        value: option.key,
        label: option.label,
        subtitle: option.subtitle,
      ),
    ),
  ];

  return showMobileFilterSheet<String>(
    context: context,
    title: 'Filter',
    selected: selectedKey ?? MobileFilterOption.allKey,
    options: allOptions,
  );
}

/// Opens sort field then direction sheets for transaction lists.
Future<MobileTransactionSortState?> showMobileTransactionSortSheet({
  required BuildContext context,
  required MobileTransactionSortState selected,
  required Map<String, String> fieldOptions,
}) async {
  final fieldEntries = fieldOptions.entries.toList();
  final field = await showMobileFilterSheet<String>(
    context: context,
    title: 'Sort By',
    selected: selected.fieldKey,
    options: [
      for (final entry in fieldEntries)
        MobileOption(value: entry.key, label: entry.value),
    ],
  );
  if (!context.mounted || field == null) return null;

  final direction = await showMobileFilterSheet<MobileTransactionSortDirection>(
    context: context,
    title: 'Sort Direction',
    selected: selected.direction == MobileTransactionSortDirection.none
        ? MobileTransactionSortDirection.descending
        : selected.direction,
    options: const [
      MobileOption(
        value: MobileTransactionSortDirection.descending,
        label: 'Descending',
      ),
      MobileOption(
        value: MobileTransactionSortDirection.ascending,
        label: 'Ascending',
      ),
    ],
  );
  if (!context.mounted || direction == null) return null;

  return MobileTransactionSortState(fieldKey: field, direction: direction);
}

/// More actions bottom sheet for transaction list screens.
Future<void> showMobileTransactionMoreActionsSheet({
  required BuildContext context,
  required List<MobileTransactionAction> actions,
  String title = 'More Actions',
}) {
  if (actions.isEmpty) return Future.value();

  return showMobileMoreActionsSheet(
    context: context,
    title: title,
    actions: [
      for (final action in actions)
        MobileSheetAction(
          icon: action.icon,
          label: action.label,
          subtitle: action.subtitle,
          isDestructive: action.isDestructive,
          onTap: action.onTap,
        ),
    ],
  );
}
