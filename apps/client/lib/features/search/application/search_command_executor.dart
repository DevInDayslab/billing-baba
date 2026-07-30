import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_dialog.dart';
import 'package:billing_baba/features/search/application/recent_search_storage.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Executes a selected search item (navigation or command).
Future<void> executeSearchItem(
  BuildContext context,
  WidgetRef ref,
  SearchItem item,
) async {
  if (item.trackAsRecentPage && item.isPage) {
    await ref.read(recentSearchStorageProvider).recordPageVisit(item.id);
  }

  if (!context.mounted) return;

  final action = item.action;
  if (item.isCommand && action != null) {
    await _executeCommand(context, ref, item, action);
    return;
  }

  if (action == SearchActionKind.openReport) {
    final intent = item.reportIntent;
    if (intent != null) {
      ref.read(reportsNavIntentProvider.notifier).setIntent(intent);
    }
    if (context.mounted) context.go(AppRoutes.reports);
    return;
  }

  final route = item.route;
  if (route != null && context.mounted) {
    context.go(route);
  }
}

Future<void> _executeCommand(
  BuildContext context,
  WidgetRef ref,
  SearchItem item,
  SearchActionKind action,
) async {
  switch (action) {
    case SearchActionKind.routeGo:
      if (item.route != null && context.mounted) {
        context.go(item.route!);
      }
    case SearchActionKind.routePush:
      if (item.route != null && context.mounted) {
        await context.push(item.route!);
      }
    case SearchActionKind.showAddPartyDialog:
      if (context.mounted) await showAddPartyDialog(context);
    case SearchActionKind.showAddItemDialog:
      if (context.mounted) await showAddItemDialog(context);
    case SearchActionKind.showPaymentInDialog:
      if (context.mounted) unawaited(showPaymentInDialog(context));
    case SearchActionKind.showPaymentOutDialog:
      if (context.mounted) unawaited(showPaymentOutDialog(context));
    case SearchActionKind.openReport:
      final intent = item.reportIntent;
      if (intent != null) {
        ref.read(reportsNavIntentProvider.notifier).setIntent(intent);
      }
      if (context.mounted) context.go(AppRoutes.reports);
    case SearchActionKind.switchCompany:
      if (context.mounted) context.go(AppRoutes.businessList);
  }
}
