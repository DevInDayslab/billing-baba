import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_purchase.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showSubscriptionHistoryDialog(
  BuildContext context, {
  required List<SubscriptionHistoryModel> history,
}) {
  final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 520),
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Purchase History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('No purchase history yet'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: history.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.event),
                            subtitle: Text(
                              '${formatSubscriptionPlanLabel(item.oldPlan)} → ${formatSubscriptionPlanLabel(item.newPlan)}',
                            ),
                            trailing: Text(
                              dateFormat.format(item.createdAt.toLocal()),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
