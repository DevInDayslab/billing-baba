import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_sales_history_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-page sales history (e.g. deep links). Prefer [PosSalesHistoryPanel] on
/// the sale screen with the tab-bar history toggle.
class DesktopPosSalesHistoryPage extends ConsumerWidget {
  const DesktopPosSalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: const PosSalesHistoryPanel(),
    );
  }
}
