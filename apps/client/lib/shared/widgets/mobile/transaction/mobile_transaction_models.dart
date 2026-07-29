import 'package:billing_baba/shared/widgets/mobile/mobile_widgets.dart'
    show MobileTransactionPage;
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_page.dart'
    show MobileTransactionPage;
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_widgets.dart'
    show MobileTransactionPage;
import 'package:flutter/material.dart';

/// Display model for a row on [MobileTransactionPage].
class MobileTransactionListItem {
  const MobileTransactionListItem({
    required this.id,
    required this.title,
    required this.amountLabel,
    this.subtitle,
    this.dateLabel,
    this.statusLabel,
    this.amountColor,
    this.statusColor,
    this.leadingIcon,
    this.isHighlighted = false,
    this.sortAmount = 0,
    this.sortDate,
    this.sortTitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String amountLabel;
  final String? dateLabel;
  final String? statusLabel;
  final Color? amountColor;
  final Color? statusColor;
  final IconData? leadingIcon;
  final bool isHighlighted;

  /// Optional values used by the default client-side sorter.
  final double sortAmount;
  final DateTime? sortDate;
  final String? sortTitle;
}

/// A tappable action shown in toolbars or more-actions sheets.
class MobileTransactionAction {
  const MobileTransactionAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? subtitle;
}

/// Empty-state copy shown when the transaction list has no rows.
class MobileTransactionEmptyStateConfig {
  const MobileTransactionEmptyStateConfig({
    required this.title,
    this.message,
    this.icon = Icons.receipt_long_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
}

enum MobileTransactionSortDirection { none, ascending, descending }

/// Active sort selection for a transaction list scope.
class MobileTransactionSortState {
  const MobileTransactionSortState({
    this.fieldKey = 'date',
    this.direction = MobileTransactionSortDirection.descending,
  });

  final String fieldKey;
  final MobileTransactionSortDirection direction;

  bool get isActive => direction != MobileTransactionSortDirection.none;

  String labelFor(Map<String, String> fieldLabels) {
    return fieldLabels[fieldKey] ?? fieldKey;
  }

  MobileTransactionSortState copyWith({
    String? fieldKey,
    MobileTransactionSortDirection? direction,
  }) {
    return MobileTransactionSortState(
      fieldKey: fieldKey ?? this.fieldKey,
      direction: direction ?? this.direction,
    );
  }

  MobileTransactionSortState toggleField(String key) {
    if (fieldKey == key) {
      final nextDirection = switch (direction) {
        MobileTransactionSortDirection.none =>
          MobileTransactionSortDirection.descending,
        MobileTransactionSortDirection.descending =>
          MobileTransactionSortDirection.ascending,
        MobileTransactionSortDirection.ascending =>
          MobileTransactionSortDirection.none,
      };
      return copyWith(direction: nextDirection);
    }

    return MobileTransactionSortState(
      fieldKey: key,
    );
  }
}

/// Configuration for [MobileTransactionPage].
class MobileTransactionPageConfig {
  const MobileTransactionPageConfig({
    required this.scopeId,
    required this.title,
    this.searchHint = 'Search transactions',
    this.filterOptions = const [],
    this.defaultFilterKey,
    this.sortFieldOptions = const {
      'date': 'Date',
      'amount': 'Amount',
      'title': 'Name',
    },
    this.defaultSort = const MobileTransactionSortState(),
    this.emptyState = const MobileTransactionEmptyStateConfig(
      title: 'No transactions found',
      message: 'Create a new transaction to get started.',
    ),
    this.fabTooltip = 'Add',
    this.fabIcon = Icons.add_rounded,
    this.onFabPressed,
    this.moreActions = const [],
    this.showBusinessHeader = false,
    this.showNotification = false,
    this.appBarActions,
    this.onSettingsTap,
  });

  /// Unique key for Riverpod list state (e.g. `sale-invoices`).
  final String scopeId;
  final String title;
  final String searchHint;
  final List<MobileFilterOption> filterOptions;
  final String? defaultFilterKey;
  final Map<String, String> sortFieldOptions;
  final MobileTransactionSortState defaultSort;
  final MobileTransactionEmptyStateConfig emptyState;
  final String fabTooltip;
  final IconData fabIcon;
  final VoidCallback? onFabPressed;
  final List<MobileTransactionAction> moreActions;
  final bool showBusinessHeader;
  final bool showNotification;
  final List<Widget>? appBarActions;
  final VoidCallback? onSettingsTap;
}

/// Filter option for the reusable transaction filter sheet.
class MobileFilterOption {
  const MobileFilterOption({
    required this.key,
    required this.label,
    this.subtitle,
  });

  final String key;
  final String label;
  final String? subtitle;

  static const allKey = 'all';
}
