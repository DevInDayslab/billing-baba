import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilePartyGroupsPage extends ConsumerWidget {
  const MobilePartyGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(partyGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Party groups',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: groups.isEmpty
          ? const Center(
              child: Text(
                'No party groups',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    title: Text(
                      group,
                      style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
