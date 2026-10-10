import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/accounting_settings_provider.dart';
import 'package:billing_baba/features/settings/models/accounting_settings.dart';
import 'package:billing_baba/features/settings/models/accounting_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/models/accounting_settings_labels.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/accounting_settings_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopAccountingSettingsScreen extends ConsumerWidget {
  const DesktopAccountingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(accountingSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load accounting settings: $error',
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (settings) {
        Future<void> patch(AccountingSettingsUpdater update) {
          return ref.read(accountingSettingsProvider.notifier).patch(update);
        }

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AccountingSettingsLabels.sectionTitle,
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: AppSpacing.lg),
                    AccountingSettingsCheckboxRow(
                      label: AccountingSettingsLabels.enableModule,
                      value: settings.enableAccountingModule,
                      infoKey: AccountingSettingsInfoKey.enableAccountingModule,
                      onChanged: (enabled) => patch(
                        (s) => s.withAccountingModuleEnabled(enabled ?? false),
                      ),
                    ),
                    AccountingSettingsCheckboxRow(
                      label: AccountingSettingsLabels.allowJournalEntries,
                      value: settings.allowJournalEntries,
                      infoKey: AccountingSettingsInfoKey.allowJournalEntries,
                      muted: !settings.isJournalEntriesApplicable,
                      onChanged: (enabled) => patch(
                        (s) => s.withAllowJournalEntries(enabled ?? false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
