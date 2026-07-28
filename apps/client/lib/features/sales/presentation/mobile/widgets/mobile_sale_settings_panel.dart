import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/sale_invoice_settings_subpages.dart';
import 'package:billing_baba/features/settings/application/transaction_message_settings_provider.dart';
import 'package:billing_baba/features/settings/models/transaction_message_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _panelBlue = Color(0xFF42A5F5);
const _badgeRed = Color(0xFFE53935);

enum MobileSaleBillingType {
  fullSale,
  mobilePos,
}

/// Vyapar-style slide-in settings panel for the mobile sale form.
Future<void> showMobileSaleSettingsPanel({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Sale settings',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) {
      return Align(
        alignment: Alignment.centerRight,
        child: _MobileSaleSettingsPanel(
          onClose: () => Navigator.of(dialogContext).pop(),
          onMoreSettings: () {
            Navigator.of(dialogContext).pop();
            unawaited(context.push(AppRoutes.saleInvoiceMoreSettings));
          },
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offset, child: child);
    },
  );
}

class _MobileSaleSettingsPanel extends ConsumerStatefulWidget {
  const _MobileSaleSettingsPanel({
    required this.onClose,
    required this.onMoreSettings,
  });

  final VoidCallback onClose;
  final VoidCallback onMoreSettings;

  @override
  ConsumerState<_MobileSaleSettingsPanel> createState() =>
      _MobileSaleSettingsPanelState();
}

class _MobileSaleSettingsPanelState
    extends ConsumerState<_MobileSaleSettingsPanel> {
  MobileSaleBillingType _billingType = MobileSaleBillingType.fullSale;
  bool _isSavingSms = false;
  bool _isSavingPrefix = false;

  Future<void> _setTransactionSms(bool enabled) async {
    if (_isSavingSms) return;
    setState(() => _isSavingSms = true);

    try {
      final current = await ref.read(transactionMessageSettingsProvider.future);
      final updated = current.copyWith(
        autoSend: {
          ...current.autoSend,
          TransactionMessageType.sale: enabled,
        },
      );
      await ref
          .read(transactionMessageSettingsProvider.notifier)
          .save(updated);
    } finally {
      if (mounted) setState(() => _isSavingSms = false);
    }
  }

  Future<void> _setSalePrefix(bool enabled) async {
    if (_isSavingPrefix) return;
    setState(() => _isSavingPrefix = true);

    try {
      await ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
        (settings) => settings.copyWith(salePrefixEnabled: enabled),
      );
    } finally {
      if (mounted) setState(() => _isSavingPrefix = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelWidth = MediaQuery.sizeOf(context).width * 0.78;
    final settingsAsync = ref.watch(transactionMessageSettingsProvider);
    final saleSettingsAsync = ref.watch(saleInvoiceSettingsProvider);
    final transactionSmsEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.isAutoSendEnabled(TransactionMessageType.sale),
      orElse: () => true,
    );
    final salePrefixEnabled = saleSettingsAsync.maybeWhen(
      data: (settings) => settings.salePrefixEnabled,
      orElse: () => false,
    );

    return Material(
      color: AppColors.surface,
      elevation: 16,
      child: SafeArea(
        child: SizedBox(
          width: panelWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary.withValues(alpha: 0.75),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [
                    _ToggleSettingTile(
                      title: 'Sale Prefix',
                      description:
                          'Customize the Prefix to your Sale Invoice.Ex: INV',
                      value: salePrefixEnabled,
                      isLoading:
                          _isSavingPrefix || saleSettingsAsync.isLoading,
                      onChanged: (value) => unawaited(_setSalePrefix(value)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ToggleSettingTile(
                      title: 'Transaction SMS',
                      description:
                          'Send an automatic SMS to your Customer with details of the Sale.',
                      value: transactionSmsEnabled,
                      isLoading: _isSavingSms || settingsAsync.isLoading,
                      onChanged: (value) => unawaited(_setTransactionSms(value)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _NavigationSettingTile(
                      title: 'Additional Fields',
                      description:
                          'Add extra fields to the Sale, like License Number, PAN Number, Additional Dates etc.',
                      onTap: () {
                        widget.onClose();
                        unawaited(
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const SaleInvoiceAdditionalFieldsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _NavigationSettingTile(
                      title: 'Additional Charges',
                      showBadge: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Additional charges coming soon'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Billing Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BillingTypeOption(
                      label: 'Full Sale',
                      isSelected: _billingType == MobileSaleBillingType.fullSale,
                      onTap: () => setState(
                        () => _billingType = MobileSaleBillingType.fullSale,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BillingTypeOption(
                      label: 'Mobile POS',
                      isSelected:
                          _billingType == MobileSaleBillingType.mobilePos,
                      onTap: () => setState(
                        () => _billingType = MobileSaleBillingType.mobilePos,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: TextButton.icon(
                  onPressed: widget.onMoreSettings,
                  icon: const Icon(Icons.settings_outlined, color: _panelBlue),
                  label: Text(
                    'More Settings',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _panelBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSettingTile extends StatelessWidget {
  const _ToggleSettingTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.isLoading = false,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        if (isLoading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _panelBlue,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.25),
          ),
      ],
    );
  }
}

class _NavigationSettingTile extends StatelessWidget {
  const _NavigationSettingTile({
    required this.title,
    required this.onTap,
    this.description,
    this.showBadge = false,
  });

  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _badgeRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingTypeOption extends StatelessWidget {
  const _BillingTypeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? _panelBlue
                    : AppColors.textSecondary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
