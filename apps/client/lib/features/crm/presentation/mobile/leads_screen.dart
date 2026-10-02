import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/leads_provider.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLeadsScreen extends ConsumerWidget {
  const MobileLeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Leads',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: leadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: error.toString(),
          onRetry: () => ref.read(leadsProvider.notifier).refresh(),
        ),
        data: (leads) {
          if (leads.isEmpty) {
            return const MobileEmptyState(
              title: 'No leads yet',
              message: 'New leads will appear here.',
              icon: Icons.person_search_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(leadsProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: leads.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final lead = leads[index];
                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    title: Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                            lead.company,
                            lead.phone,
                            _leadStatusLabel(lead.status),
                          ]
                          .whereType<String>()
                          .where((v) => v.isNotEmpty)
                          .join(' · '),
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

  String _leadStatusLabel(LeadStatus status) => switch (status) {
    LeadStatus.newLead => 'New',
    LeadStatus.contacted => 'Contacted',
    LeadStatus.qualified => 'Qualified',
    LeadStatus.converted => 'Converted',
    LeadStatus.lost => 'Lost',
  };
}
