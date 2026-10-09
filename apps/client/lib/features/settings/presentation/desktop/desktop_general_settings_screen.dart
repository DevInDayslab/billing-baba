import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_profile_sync.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/edit_business_dialog.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';
import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/general_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/general_settings_passcode_dialog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:billing_baba/shared/business/business_currency_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Vyapar-style general settings — three columns, no close button.
class DesktopGeneralSettingsScreen extends ConsumerStatefulWidget {
  const DesktopGeneralSettingsScreen({super.key});

  static const _uiScaleSteps = [70, 80, 90, 100, 110, 115, 120, 130];

  @override
  ConsumerState<DesktopGeneralSettingsScreen> createState() =>
      _DesktopGeneralSettingsScreenState();
}

class _DesktopGeneralSettingsScreenState
    extends ConsumerState<DesktopGeneralSettingsScreen> {
  int? _draftUiScalePercent;

  int _uiScaleDraft(GeneralSettings settings) =>
      _draftUiScalePercent ?? settings.desktopUiScalePercent;

  int _scaleStepIndex(int percent) {
    final steps = DesktopGeneralSettingsScreen._uiScaleSteps;
    final exact = steps.indexOf(percent);
    if (exact >= 0) return exact;
    var best = 0;
    var bestDelta = (steps[0] - percent).abs();
    for (var i = 1; i < steps.length; i++) {
      final delta = (steps[i] - percent).abs();
      if (delta < bestDelta) {
        best = i;
        bestDelta = delta;
      }
    }
    return best;
  }

  Future<void> _patch(GeneralSettingsUpdater update) {
    return ref.read(generalSettingsProvider.notifier).patch(update);
  }

  Future<void> _onPasscodeChanged(bool? enabled) async {
    if (enabled != true) {
      await _patch(
        (s) => s.copyWith(enablePasscode: false, appPasscode: ''),
      );
      return;
    }
    final code = await showGeneralPasscodeSetupDialog(context);
    if (!mounted || code == null) return;
    await _patch(
      (s) => s.copyWith(enablePasscode: true, appPasscode: code),
    );
  }

  Future<void> _onCurrencyChanged(String? code) async {
    if (code == null) return;
    final profile = ref.read(businessProfileProvider).asData?.value;
    if (profile == null || profile.currency == code) return;
    final updated = profile.copyWith(currency: code);
    ref.read(businessProfileProvider.notifier).replaceWith(updated);
    await propagateBusinessProfileListUpdate(ref, updated);
  }

  Future<void> _selectFirm(BusinessModel business) async {
    await _patch((s) => s.copyWith(selectedFirmBusinessId: business.id));
    final currentId = ref.read(currentBusinessProvider)?.id;
    if (currentId != business.id) {
      await ref.read(authProvider.notifier).selectBusiness(business.id);
    }
  }

  Future<void> _applyUiScale(GeneralSettings settings) async {
    final percent = _uiScaleDraft(settings);
    await _patch((s) => s.copyWith(desktopUiScalePercent: percent));
    if (mounted) setState(() => _draftUiScalePercent = null);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(generalSettingsProvider);
    final profile = ref.watch(businessProfileProvider).asData?.value;
    final businesses = ref.watch(businessListProvider).asData?.value ?? [];
    final lastBackupAsync = ref.watch(lastLocalBackupAtProvider);
    final currencyCode = profile?.currency ?? 'INR';

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load settings: $error',
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (settings) {
        final selectedFirmId = settings.selectedFirmBusinessId.isNotEmpty
            ? settings.selectedFirmBusinessId
            : (ref.read(currentBusinessProvider)?.id ?? '');
        final firms = settings.multiFirmEnabled
            ? businesses
            : businesses
                .where((b) => b.id == selectedFirmId)
                .toList();
        final displayFirms = firms.isEmpty && selectedFirmId.isNotEmpty
            ? [
                BusinessModel(
                  id: selectedFirmId,
                  name: profile?.name ?? 'Current business',
                  syncStatus: SyncStatus.off,
                  isCurrent: true,
                ),
              ]
            : firms;

        final scaleDraft = _uiScaleDraft(settings);
        final scaleIndex = _scaleStepIndex(scaleDraft);
        final lastBackup = lastBackupAsync.asData?.value;

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useThreeColumns = constraints.maxWidth >= 1100;
                final col1 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ApplicationColumn(
                      settings: settings,
                      currencyCode: currencyCode,
                      onPasscodeChanged: _onPasscodeChanged,
                      onCurrencyChanged: _onCurrencyChanged,
                      onDecimalPlaces: (v) => _patch(
                        (s) => s.copyWith(amountDecimalPlaces: v),
                      ),
                      onPatch: _patch,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MoreTransactionsColumn(settings: settings, onPatch: _patch),
                  ],
                );
                final col2 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MultiFirmColumn(
                      settings: settings,
                      firms: displayFirms,
                      selectedFirmId: selectedFirmId,
                      onMultiFirmChanged: (v) => _patch(
                        (s) => s.copyWith(multiFirmEnabled: v ?? false),
                      ),
                      onSelectFirm: _selectFirm,
                      onEditFirm: (id) => showEditBusinessModal(
                        context,
                        businessId: id,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _GodownColumn(
                      settings: settings,
                      onGodownChanged: (v) => ref
                          .read(generalSettingsProvider.notifier)
                          .setGodownStockTransferEnabled(v ?? false),
                    ),
                  ],
                );
                final col3 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BackupColumn(
                      settings: settings,
                      lastBackup: lastBackup,
                      onPatch: _patch,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CustomizeColumn(
                      scaleIndex: scaleIndex,
                      scalePercent:
                          DesktopGeneralSettingsScreen._uiScaleSteps[scaleIndex],
                      onScaleChanged: (index) {
                        setState(
                          () => _draftUiScalePercent =
                              DesktopGeneralSettingsScreen._uiScaleSteps[index],
                        );
                      },
                      onApply: () => _applyUiScale(settings),
                    ),
                  ],
                );

                if (useThreeColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: col1),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: col2),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: col3),
                    ],
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

class _ApplicationColumn extends StatelessWidget {
  const _ApplicationColumn({
    required this.settings,
    required this.currencyCode,
    required this.onPasscodeChanged,
    required this.onCurrencyChanged,
    required this.onDecimalPlaces,
    required this.onPatch,
  });

  final GeneralSettings settings;
  final String currencyCode;
  final ValueChanged<bool?> onPasscodeChanged;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<int> onDecimalPlaces;
  final Future<void> Function(GeneralSettingsUpdater) onPatch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GeneralSettingsSectionCard(
          title: 'Application',
          children: [
            GeneralSettingsCheckboxRow(
              label: 'Enable Passcode',
              value: settings.enablePasscode,
              onChanged: onPasscodeChanged,
              infoKey: GeneralSettingsInfoKey.enablePasscode,
            ),
            GeneralSettingsLabeledField(
              label: 'Business Currency',
              infoKey: GeneralSettingsInfoKey.businessCurrency,
              child: DropdownButtonFormField<String>(
                value: currencyCode,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: listPanelCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: listPanelCardBorder),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                items: [
                  for (final code in BusinessCurrencyOptions.codes)
                    DropdownMenuItem(
                      value: code,
                      child: Text(BusinessCurrencyOptions.labelFor(code)),
                    ),
                ],
                onChanged: onCurrencyChanged,
              ),
            ),
            GeneralSettingsLabeledField(
              label: 'Amount (upto Decimal Places)',
              infoKey: GeneralSettingsInfoKey.amountDecimalPlaces,
              child: GeneralSettingsDecimalField(
                value: settings.amountDecimalPlaces,
                onSubmitted: onDecimalPlaces,
              ),
            ),
            GeneralSettingsCheckboxRow(
              label: 'GSTIN Number',
              value: settings.enableGstinOnParty,
              onChanged: (v) => onPatch(
                (s) => s.copyWith(enableGstinOnParty: v ?? false),
              ),
              infoKey: GeneralSettingsInfoKey.gstinNumber,
            ),
            GeneralSettingsCheckboxRow(
              label: 'Stop Sale on Negative Stock',
              value: settings.stopSaleOnNegativeStock,
              onChanged: (v) => onPatch(
                (s) => s.copyWith(stopSaleOnNegativeStock: v ?? false),
              ),
              infoKey: GeneralSettingsInfoKey.stopSaleOnNegativeStock,
            ),
            GeneralSettingsCheckboxRow(
              label: 'Block New Items from Txn Form',
              value: settings.blockNewItemsFromTxnForm,
              onChanged: (v) => onPatch(
                (s) => s.copyWith(blockNewItemsFromTxnForm: v ?? false),
              ),
              infoKey: GeneralSettingsInfoKey.blockNewItemsFromTxnForm,
            ),
            GeneralSettingsCheckboxRow(
              label: 'Block New Parties from Txn Form',
              value: settings.blockNewPartiesFromTxnForm,
              onChanged: (v) => onPatch(
                (s) => s.copyWith(blockNewPartiesFromTxnForm: v ?? false),
              ),
              infoKey: GeneralSettingsInfoKey.blockNewPartiesFromTxnForm,
            ),
          ],
        ),
      ],
    );
  }
}

class _MoreTransactionsColumn extends StatelessWidget {
  const _MoreTransactionsColumn({
    required this.settings,
    required this.onPatch,
  });

  final GeneralSettings settings;
  final Future<void> Function(GeneralSettingsUpdater) onPatch;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'More Transactions',
      children: [
        GeneralSettingsCheckboxRow(
          label: 'Estimate/Quotation',
          value: settings.enableEstimateQuotation,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableEstimateQuotation: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.estimateQuotation,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Proforma Invoice',
          value: settings.enableProformaInvoice,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableProformaInvoice: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.proformaInvoice,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Sale/Purchase Order',
          value: settings.enableSalePurchaseOrder,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableSalePurchaseOrder: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.salePurchaseOrder,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Other Income',
          value: settings.enableOtherIncome,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableOtherIncome: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.otherIncome,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Fixed Assets (FA)',
          value: settings.enableFixedAssets,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableFixedAssets: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.fixedAssets,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Delivery Challan',
          value: settings.enableDeliveryChallan,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(enableDeliveryChallan: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.deliveryChallan,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Goods return on Delivery Challan',
          value:
              settings.enableDeliveryChallan &&
              settings.deliveryChallanGoodsReturn,
          onChanged: settings.enableDeliveryChallan
              ? (v) => onPatch(
                  (s) => s.copyWith(deliveryChallanGoodsReturn: v ?? false),
                )
              : null,
          infoKey: GeneralSettingsInfoKey.deliveryChallanGoodsReturn,
        ),
        GeneralSettingsCheckboxRow(
          label: 'Print amount in Delivery Challan',
          value:
              settings.enableDeliveryChallan &&
              settings.deliveryChallanPrintAmount,
          onChanged: settings.enableDeliveryChallan
              ? (v) => onPatch(
                  (s) => s.copyWith(deliveryChallanPrintAmount: v ?? false),
                )
              : null,
          infoKey: GeneralSettingsInfoKey.deliveryChallanPrintAmount,
        ),
      ],
    );
  }
}

class _MultiFirmColumn extends StatelessWidget {
  const _MultiFirmColumn({
    required this.settings,
    required this.firms,
    required this.selectedFirmId,
    required this.onMultiFirmChanged,
    required this.onSelectFirm,
    required this.onEditFirm,
  });

  final GeneralSettings settings;
  final List<BusinessModel> firms;
  final String selectedFirmId;
  final ValueChanged<bool?> onMultiFirmChanged;
  final Future<void> Function(BusinessModel) onSelectFirm;
  final Future<bool?> Function(String businessId) onEditFirm;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Multi Firm',
      children: [
        GeneralSettingsCheckboxRow(
          label: 'Multi Firm',
          value: settings.multiFirmEnabled,
          onChanged: onMultiFirmChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final firm in firms)
          _FirmSelectRow(
            firm: firm,
            selected: firm.id == selectedFirmId,
            onSelect: () => onSelectFirm(firm),
            onEdit: () => onEditFirm(firm.id),
          ),
      ],
    );
  }
}

class _FirmSelectRow extends StatelessWidget {
  const _FirmSelectRow({
    required this.firm,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
  });

  final BusinessModel firm;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: AppRadius.smBorder,
        border: Border.all(
          color: selected ? AppColors.primary : listPanelCardBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: AppRadius.smBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: (_) => onSelect(),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  firm.name,
                  style: AppTypography.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: AppTypography.bodyMediumSize,
                  ),
                ),
              ),
              if (firm.isCurrent)
                _FirmTag(label: 'DEFAULT', color: AppColors.textSecondary),
              if (firm.syncStatus == SyncStatus.on) ...[
                const SizedBox(width: AppSpacing.xs),
                _FirmTag(label: 'ALL DEVICES', color: AppColors.primary),
              ],
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppColors.primary,
                tooltip: 'Edit firm',
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirmTag extends StatelessWidget {
  const _FirmTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _GodownColumn extends StatelessWidget {
  const _GodownColumn({
    required this.settings,
    required this.onGodownChanged,
  });

  final GeneralSettings settings;
  final ValueChanged<bool?> onGodownChanged;

  @override
  Widget build(BuildContext context) {
    final sections = GeneralSettingsInfoCatalog.sectionsFor(
      GeneralSettingsInfoKey.stockTransferGodowns,
    );
    final description = sections.isNotEmpty ? sections.first.body : '';

    return GeneralSettingsSectionCard(
      title: 'Stock Transfer Between Godowns',
      children: [
        Text(
          description,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GeneralSettingsCheckboxRow(
          label: 'Godown management & Stock transfer',
          value: settings.godownStockTransferEnabled,
          onChanged: onGodownChanged,
          infoKey: GeneralSettingsInfoKey.stockTransferGodowns,
        ),
      ],
    );
  }
}

class _BackupColumn extends StatelessWidget {
  const _BackupColumn({
    required this.settings,
    required this.lastBackup,
    required this.onPatch,
  });

  final GeneralSettings settings;
  final DateTime? lastBackup;
  final Future<void> Function(GeneralSettingsUpdater) onPatch;

  @override
  Widget build(BuildContext context) {
    final backupLabel = lastBackup == null
        ? 'No backup recorded yet'
        : 'Last Backup ${DateFormat('dd/MM/yyyy | hh:mm a').format(lastBackup!.toLocal())}';

    return GeneralSettingsSectionCard(
      title: 'Backup & History',
      children: [
        GeneralSettingsCheckboxRow(
          label: 'Auto Backup',
          value: settings.autoBackupEnabled,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(autoBackupEnabled: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.autoBackup,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  backupLabel,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySmallSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SettingsInfoIconButton(
                heading: 'Last Backup',
                infoKey: GeneralSettingsInfoKey.lastBackup,
              ),
            ],
          ),
        ),
        GeneralSettingsCheckboxRow(
          label: 'Audit Trail',
          value: settings.auditTrailEnabled,
          onChanged: (v) => onPatch(
            (s) => s.copyWith(auditTrailEnabled: v ?? false),
          ),
          infoKey: GeneralSettingsInfoKey.auditTrail,
        ),
      ],
    );
  }
}

class _CustomizeColumn extends StatelessWidget {
  const _CustomizeColumn({
    required this.scaleIndex,
    required this.scalePercent,
    required this.onScaleChanged,
    required this.onApply,
  });

  final int scaleIndex;
  final int scalePercent;
  final ValueChanged<int> onScaleChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Customize Your View',
      children: [
        Text(
          'Choose Your Screen Zoom/Scale',
          style: AppTypography.inter(
            fontWeight: FontWeight.w600,
            fontSize: AppTypography.bodyMediumSize,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You can use this setting to resize the Billing Baba screen, making it larger or smaller to fit your preferences.',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Slider(
          value: scaleIndex.toDouble(),
          min: 0,
          max: (DesktopGeneralSettingsScreen._uiScaleSteps.length - 1)
              .toDouble(),
          divisions: DesktopGeneralSettingsScreen._uiScaleSteps.length - 1,
          label: '$scalePercent%',
          onChanged: (v) => onScaleChanged(v.round()),
        ),
        Row(
          children: [
            for (final step in DesktopGeneralSettingsScreen._uiScaleSteps)
              Expanded(
                child: Text(
                  '$step%',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: 10,
                    color: step == scalePercent
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: step == scalePercent
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: onApply,
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}
