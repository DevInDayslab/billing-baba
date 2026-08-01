import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_catalog.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_items_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route-driven wrapper around [MobileTransactionPage].
///
/// Use for sales, purchases, and other transaction list screens on mobile.
class MobileScopedTransactionPage extends ConsumerWidget {
  const MobileScopedTransactionPage({
    required this.route,
    super.key,
    this.titleOverride,
  });

  final String route;
  final String? titleOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final definition = MobileTransactionCatalog.definitionForRoute(route);
    if (definition == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(titleOverride ?? 'Transactions')),
        body: const MobileEmptyState(
          title: 'Unsupported route',
          message: 'No mobile transaction list is configured for this page.',
          icon: Icons.error_outline_rounded,
        ),
      );
    }

    final config = definition.config(context, titleOverride: titleOverride);
    final itemsAsync = ref.watch(
      mobileTransactionItemsProvider(definition.scopeId),
    );

    return MobileTransactionPage(
      config: config,
      itemsAsync: itemsAsync,
      filterMatcher: MobileTransactionCatalog.statusFilterMatcher,
      onRefresh: () => refreshMobileTransactionItems(ref, definition.route),
      onItemTap: (item) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.title} — details coming soon')),
        );
      },
    );
  }
}
