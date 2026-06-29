import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/core/widgets/app_loader.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_card.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_empty_state.dart';
import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessList extends ConsumerWidget {
  const BusinessList({required this.onOpenBusiness, super.key});

  final ValueChanged<BusinessModel> onOpenBusiness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessListProvider);
    final selectedBusiness = ref.watch(selectedBusinessProvider);
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.45);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: businessesAsync.when(
        loading: () => const AppLoader(message: 'Loading businesses...'),
        error: (error, _) => AppError(
          message: 'Unable to load businesses. Please try again.',
          onRetry: () => ref.read(businessListProvider.notifier).refresh(),
        ),
        data: (businesses) {
          if (businesses.isEmpty) {
            return const BusinessEmptyState();
          }

          return ListView.separated(
            key: ValueKey(businesses.length),
            itemCount: businesses.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: dividerColor),
            itemBuilder: (context, index) {
              final business = businesses[index];
              return BusinessCard(
                business: business,
                isSelected: selectedBusiness?.id == business.id,
                onSelect: () {
                  ref.read(selectedBusinessProvider.notifier).select(business);
                },
                onOpen: () => onOpenBusiness(business),
              );
            },
          );
        },
      ),
    );
  }
}
