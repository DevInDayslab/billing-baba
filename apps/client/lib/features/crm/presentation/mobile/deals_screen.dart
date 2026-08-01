import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/deals_provider.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/shared/chart/chart_axis_formatters.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileDealsScreen extends ConsumerWidget {
  const MobileDealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(dealsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Deals',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: dealsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: error.toString(),
          onRetry: () => ref.read(dealsProvider.notifier).refresh(),
        ),
        data: (deals) {
          if (deals.isEmpty) {
            return const MobileEmptyState(
              title: 'No deals yet',
              message: 'Deals in your pipeline will appear here.',
              icon: Icons.handshake_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(dealsProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: deals.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final deal = deals[index];
                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    title: Text(
                      deal.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                        deal.stage.label,
                        deal.accountName,
                      ].whereType<String>().where((v) => v.isNotEmpty).join(' · '),
                    ),
                    trailing: Text(
                      ChartAxisFormatters.formatCurrency(deal.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
