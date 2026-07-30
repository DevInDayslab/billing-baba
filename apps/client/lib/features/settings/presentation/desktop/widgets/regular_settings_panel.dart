import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/common_invoice_toggles.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:flutter/material.dart';

class RegularSettingsPanel extends StatelessWidget {
  const RegularSettingsPanel({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final PrintSettings settings;
  final ValueChanged<PrintSettingsUpdater> onUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: listPanelCardBorder),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListView(
          children: [
            const _SectionLabel('Orientation', isFirst: true),
            _PrintSegmentedButton<RegularOrientation>(
              segments: const [
                ButtonSegment(
                  value: RegularOrientation.portrait,
                  label: Text('Portrait'),
                ),
                ButtonSegment(
                  value: RegularOrientation.landscape,
                  label: Text('Landscape'),
                ),
              ],
              selected: {settings.orientation},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                onUpdate((s) => s.copyWith(orientation: selection.first));
              },
            ),
            _TextSizeControl(
              label: 'Invoice Text Size',
              value: settings.invoiceTextSize,
              onChanged: (value) =>
                  onUpdate((s) => s.copyWith(invoiceTextSize: value)),
            ),
            _TextSizeControl(
              label: 'Company Text Size',
              value: settings.companyTextSize,
              onChanged: (value) =>
                  onUpdate((s) => s.copyWith(companyTextSize: value)),
            ),
            CommonInvoiceToggles(settings: settings, onUpdate: onUpdate),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.isFirst = false});

  final String text;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: ListPanelStyles.listHeaderStyle,
      ),
    );
  }
}

class _PrintSegmentedButton<T> extends StatelessWidget {
  const _PrintSegmentedButton({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surface,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: listPanelCardBorder),
            ),
            textStyle: WidgetStateProperty.all(
              AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        ),
      ),
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: segments,
        selected: selected,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class _TextSizeControl extends StatelessWidget {
  const _TextSizeControl({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final PrintTextSize value;
  final ValueChanged<PrintTextSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrintSegmentedButton<PrintTextSize>(
            segments: const [
              ButtonSegment(value: PrintTextSize.small, label: Text('S')),
              ButtonSegment(value: PrintTextSize.medium, label: Text('M')),
              ButtonSegment(value: PrintTextSize.large, label: Text('L')),
            ],
            selected: {value},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}
