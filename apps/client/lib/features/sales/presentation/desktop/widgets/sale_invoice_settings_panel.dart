import 'dart:async';
import 'dart:math' as math;

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/transaction_settings_editors.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _panelBorder = Color(0xFFE0E0E0);
const _sectionHeaderBg = Color(0xFFF5F5F5);
const _footerBg = Color(0xFFFAFAFA);

/// Vyapar-style slide-in panel for quick sale invoice settings (desktop).
Future<void> showSaleInvoiceSettingsPanel({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Sale invoice settings',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) {
      return Align(
        alignment: Alignment.centerRight,
        child: _SaleInvoiceSettingsPanel(
          onClose: () => Navigator.of(dialogContext).pop(),
          onMoreSettings: () {
            Navigator.of(dialogContext).pop();
            unawaited(
              context.push(
                AppRoutes.settingsTab(SettingsTab.transactionMessages.id),
              ),
            );
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

class _SaleInvoiceSettingsPanel extends ConsumerStatefulWidget {
  const _SaleInvoiceSettingsPanel({
    required this.onClose,
    required this.onMoreSettings,
  });

  final VoidCallback onClose;
  final VoidCallback onMoreSettings;

  @override
  ConsumerState<_SaleInvoiceSettingsPanel> createState() =>
      _SaleInvoiceSettingsPanelState();
}

class _SaleInvoiceSettingsPanelState
    extends ConsumerState<_SaleInvoiceSettingsPanel> {
  var _isSavingDueDates = false;

  Future<void> _setDueDatesAndPaymentTerms(bool enabled) async {
    if (_isSavingDueDates) return;
    setState(() => _isSavingDueDates = true);
    try {
      await ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
        (settings) => settings.copyWith(dueDatesAndPaymentTerms: enabled),
      );
    } finally {
      if (mounted) setState(() => _isSavingDueDates = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = math.min(400.0, math.max(280.0, screenWidth * 0.34));

    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return Material(
      color: AppColors.surface,
      elevation: 12,
      shadowColor: Colors.black26,
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
                        'Sale Invoice Settings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _panelBorder),
              Expanded(
                child: settingsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load settings',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(saleInvoiceSettingsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (settings) => ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        width: double.infinity,
                        color: _sectionHeaderBg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          'General',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DueDatesPaymentTermsRow(
                              value: settings.dueDatesAndPaymentTerms,
                              isLoading:
                                  _isSavingDueDates || settingsAsync.isLoading,
                              onChanged: (value) =>
                                  unawaited(_setDueDatesAndPaymentTerms(value)),
                            ),
                            TextButton(
                                onPressed: () => showPaymentTermsEditor(
                                  context: context,
                                  initial: settings.formExtras.paymentTerms,
                                  onSave: (terms) => ref
                                      .read(
                                        saleInvoiceSettingsProvider.notifier,
                                      )
                                      .updateSettings(
                                        (s) => s.copyWith(
                                          formExtras: s.formExtras.copyWith(
                                            paymentTerms: terms,
                                          ),
                                        ),
                                      ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Set Payment Terms',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: _panelBorder),
              Material(
                color: _footerBg,
                child: SafeArea(
                  top: false,
                  child: InkWell(
                    onTap: widget.onMoreSettings,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.settings,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'More Settings',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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

class _DueDatesPaymentTermsRow extends StatelessWidget {
  const _DueDatesPaymentTermsRow({
    required this.value,
    required this.onChanged,
    required this.isLoading,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLoading;

  static const _helpMessage =
      'Show due date and payment terms on sale invoices and related forms.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Due Dates & Payment Terms',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message: _helpMessage,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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
            activeTrackColor: AppColors.primary.withValues(alpha: 0.55),
            activeThumbColor: AppColors.primary,
          ),
      ],
    );
  }
}
