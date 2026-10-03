import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/repositories/party_reminder_schedule_repository.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Transaction-related settings panel (mobile adaptation of desktop sidebar).
class MobilePartyTransactionSettingsPanel extends ConsumerWidget {
  const MobilePartyTransactionSettingsPanel({
    required this.party,
    required this.outstandingLabel,
    required this.creditLimitLabel,
    super.key,
  });

  final PartyModel party;
  final String outstandingLabel;
  final String creditLimitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextReminder = ref.watch(partyNextReminderProvider(party.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MobileSectionHeader(
          title: 'Transaction Settings',
          subtitle: 'Billing and payment preferences for this party',
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: MobileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  label: 'Party Type',
                  value: party.partyTypeLabel,
                  icon: LucideIcons.idCard,
                ),
                const _Divider(),
                _SettingsTile(
                  label: 'Outstanding Balance',
                  value: outstandingLabel,
                  icon: LucideIcons.wallet,
                ),
                const _Divider(),
                _SettingsTile(
                  label: 'Credit Limit',
                  value: creditLimitLabel,
                  icon: LucideIcons.creditCard,
                ),
                const _Divider(),
                _SettingsTile(
                  label: 'Default Price Tier',
                  value: PriceTier.labelFor(party.defaultPriceTier),
                  icon: LucideIcons.tag,
                ),
                const _Divider(),
                _SettingsTile(
                  label: 'Payment Reminder',
                  value: _reminderLabel(nextReminder),
                  icon: LucideIcons.bellRing,
                ),
                const _Divider(),
                _SettingsTile(
                  label: 'Status',
                  value: party.isActive ? 'Active' : 'Inactive',
                  icon: LucideIcons.toggleRight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _reminderLabel(PartyReminderSchedule? schedule) {
    if (schedule == null) return 'Not scheduled';
    final dateLabel = DateFormat('dd MMM yyyy').format(schedule.nextReminderAt);
    final suffix = switch (schedule.frequency) {
      PartyReminderFrequency.once => '',
      PartyReminderFrequency.weekly => ' · Weekly',
      PartyReminderFrequency.monthly => ' · Monthly',
    };
    return '$dateLabel$suffix';
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppIconSize.lg, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: AppSpacing.lg);
  }
}
