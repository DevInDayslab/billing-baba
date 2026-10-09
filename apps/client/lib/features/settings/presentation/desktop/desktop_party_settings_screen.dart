import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/party_settings_provider.dart';
import 'package:billing_baba/features/settings/models/party_settings.dart';
import 'package:billing_baba/features/settings/models/party_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/general_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/party_reminder_message_dialog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/party_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/transaction_settings_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopPartySettingsScreen extends ConsumerWidget {
  const DesktopPartySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(partySettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load party settings: $error',
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (settings) {
        Future<void> patch(PartySettingsUpdater update) {
          return ref.read(partySettingsProvider.notifier).patch(update);
        }

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useThreeColumns = constraints.maxWidth >= 1100;
                final col1 = _PartySettingsColumn(
                  settings: settings,
                  onPatch: patch,
                );
                final col2 = _AdditionalFieldsColumn(
                  settings: settings,
                  onPatch: patch,
                );
                final col3 = _LoyaltyColumn(settings: settings, onPatch: patch);

                if (useThreeColumns) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: col1),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: col2),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: col3),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    col1,
                    const SizedBox(height: AppSpacing.md),
                    col2,
                    const SizedBox(height: AppSpacing.md),
                    col3,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PartySettingsColumn extends StatelessWidget {
  const _PartySettingsColumn({
    required this.settings,
    required this.onPatch,
  });

  final PartySettings settings;
  final Future<void> Function(PartySettingsUpdater update) onPatch;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Party Settings',
      children: [
        PartySettingsCheckboxRow(
          label: 'Party Grouping',
          value: settings.partyGroupingEnabled,
          infoKey: PartySettingsInfoKey.partyGrouping,
          onChanged: (v) =>
              onPatch((s) => s.copyWith(partyGroupingEnabled: v ?? false)),
        ),
        PartySettingsCheckboxRow(
          label: 'Shipping Address',
          value: settings.shippingAddressEnabled,
          infoKey: PartySettingsInfoKey.shippingAddress,
          onChanged: (v) =>
              onPatch((s) => s.copyWith(shippingAddressEnabled: v ?? false)),
        ),
        PartySettingsCheckboxRow(
          label: 'Print Shipping Address',
          value: settings.printShippingAddressEnabled,
          infoKey: PartySettingsInfoKey.printShippingAddress,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(printShippingAddressEnabled: v ?? false),
          ),
        ),
        PartySettingsCheckboxRow(
          label: 'Manage Party Status',
          value: settings.managePartyStatusEnabled,
          infoKey: PartySettingsInfoKey.managePartyStatus,
          onChanged: (v) =>
              onPatch((s) => s.copyWith(managePartyStatusEnabled: v ?? false)),
        ),
        PartySettingsCheckboxRow(
          label: 'Enable Payment Reminder',
          value: settings.paymentReminderEnabled,
          infoKey: PartySettingsInfoKey.enablePaymentReminder,
          onChanged: (v) =>
              onPatch((s) => s.copyWith(paymentReminderEnabled: v ?? false)),
        ),
        if (settings.paymentReminderEnabled) ...[
          const SizedBox(height: AppSpacing.xs),
          _PaymentReminderDueRow(
            days: settings.paymentReminderDueDays,
            onDaysChanged: (days) => onPatch(
              (s) => s.copyWith(paymentReminderDueDays: days),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: PartySettingsRowMetrics.checkboxLeadingWidth,
            ),
            child: TransactionSettingsLinkButton(
              label: 'Reminder Message >',
              onTap: () async {
                final saved = await showPartyReminderMessageDialog(
                  context: context,
                  initialAdditionalMessage: settings.reminderAdditionalMessage,
                );
                if (saved == null) return;
                await onPatch(
                  (s) => s.copyWith(reminderAdditionalMessage: saved),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _PaymentReminderDueRow extends StatelessWidget {
  const _PaymentReminderDueRow({
    required this.days,
    required this.onDaysChanged,
  });

  final int days;
  final ValueChanged<int> onDaysChanged;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTypography.inter(
      fontSize: AppTypography.bodyMediumSize,
      color: AppColors.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: PartySettingsRowMetrics.checkboxLeadingWidth),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Remind me for payment due in', style: bodyStyle),
                _PaymentReminderDaysStepper(
                  days: days,
                  onChanged: onDaysChanged,
                ),
                Text(
                  '(days)',
                  style: bodyStyle.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const PartySettingsSectionInfoIcon(
            heading: 'Remind me for payment due in',
            infoKey: PartySettingsInfoKey.paymentReminderDueDays,
          ),
        ],
      ),
    );
  }
}

class _PaymentReminderDaysStepper extends StatelessWidget {
  const _PaymentReminderDaysStepper({
    required this.days,
    required this.onChanged,
  });

  final int days;
  final ValueChanged<int> onChanged;

  void _bump(int delta) {
    onChanged((days + delta).clamp(1, 365));
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.inter(
      fontSize: AppTypography.bodyMediumSize,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ).copyWith(
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$days', style: valueStyle),
        const SizedBox(width: 2),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepArrowButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: days < 365 ? () => _bump(1) : null,
            ),
            _StepArrowButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: days > 1 ? () => _bump(-1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepArrowButton extends StatelessWidget {
  const _StepArrowButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 18,
          height: 11,
          child: Icon(
            icon,
            size: 14,
            color: onPressed == null
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _AdditionalFieldsColumn extends StatelessWidget {
  const _AdditionalFieldsColumn({
    required this.settings,
    required this.onPatch,
  });

  final PartySettings settings;
  final Future<void> Function(PartySettingsUpdater update) onPatch;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Additional fields',
      titleTrailing: PartySettingsSectionInfoIcon(
        heading: 'Additional fields',
        infoKey: PartySettingsInfoKey.additionalFields,
      ),
      children: [
        for (var i = 0; i < PartyAdditionalFieldCatalog.fieldCount; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _AdditionalFieldRow(
            index: i,
            config: settings.fieldAt(i),
            onChanged: (field) => onPatch((s) => s.updateField(i, field)),
          ),
        ],
      ],
    );
  }
}

class _AdditionalFieldRow extends StatelessWidget {
  const _AdditionalFieldRow({
    required this.index,
    required this.config,
    required this.onChanged,
  });

  final int index;
  final PartyAdditionalFieldConfig config;
  final ValueChanged<PartyAdditionalFieldConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDateField = index == 3;
    final defaultLabel = PartyAdditionalFieldCatalog.defaultLabelForIndex(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: config.enabled,
              onChanged: (v) =>
                  onChanged(config.copyWith(enabled: v ?? false)),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: isDateField ? 3 : 1,
                    child: TextFormField(
                      initialValue: config.label,
                      enabled: config.enabled,
                      decoration: InputDecoration(
                        hintText: defaultLabel,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.smBorder,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) => onChanged(config.copyWith(label: v)),
                    ),
                  ),
                  if (isDateField) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: config.dateFormatId,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.smBorder,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          for (final option
                              in PartyAdditionalFieldCatalog.dateFormatOptions)
                            DropdownMenuItem(
                              value: option.id,
                              child: Text(
                                option.label,
                                style: AppTypography.inter(
                                  fontSize: AppTypography.bodySmallSize,
                                ),
                              ),
                            ),
                        ],
                        onChanged: config.enabled
                            ? (id) {
                                if (id != null) {
                                  onChanged(
                                    config.copyWith(
                                      dateFormatId: id,
                                      valueKind:
                                          PartyAdditionalFieldValueKind.date,
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Show In Print',
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Switch(
                value: config.showInPrint,
                onChanged: config.enabled
                    ? (v) => onChanged(config.copyWith(showInPrint: v))
                    : null,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoyaltyColumn extends StatelessWidget {
  const _LoyaltyColumn({
    required this.settings,
    required this.onPatch,
  });

  final PartySettings settings;
  final Future<void> Function(PartySettingsUpdater update) onPatch;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Enable Loyalty Point',
      children: [
        PartySettingsCheckboxRow(
          label: 'Enable Loyalty Point',
          value: settings.loyaltyPointsEnabled,
          infoKey: PartySettingsInfoKey.enableLoyaltyPoint,
          onChanged: (v) =>
              onPatch((s) => s.copyWith(loyaltyPointsEnabled: v ?? false)),
        ),
      ],
    );
  }
}
