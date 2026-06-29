import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/providers/auth_session_provider.dart';
import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessBottomBar extends ConsumerWidget {
  const BusinessBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final repository = ref.read(businessRepositoryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'Currently logged in with Phone: '),
                  TextSpan(
                    text: session.phone,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              await repository.restoreBackup();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore backup — coming soon')),
              );
            },
            child: const Text('Restore Backup'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () async {
              await repository.createBusiness();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create business — coming soon')),
              );
            },
            child: const Text('New Business'),
          ),
        ],
      ),
    );
  }
}
