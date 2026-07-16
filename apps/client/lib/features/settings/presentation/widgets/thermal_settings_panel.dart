import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/presentation/widgets/common_invoice_toggles.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:flutter/material.dart';

class ThermalSettingsPanel extends StatelessWidget {
  const ThermalSettingsPanel({
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
            const _SectionLabel('Page Size', isFirst: true),
            _PrintSegmentedButton<ThermalPageSize>(
              segments: const [
                ButtonSegment(
                  value: ThermalPageSize.twoInch,
                  label: Text('2 inch'),
                ),
                ButtonSegment(
                  value: ThermalPageSize.threeInch,
                  label: Text('3 inch'),
                ),
                ButtonSegment(
                  value: ThermalPageSize.fourInch,
                  label: Text('4 inch'),
                ),
              ],
              selected: {settings.thermalPageSize},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                onUpdate((s) => s.copyWith(thermalPageSize: selection.first));
              },
            ),
            const _SectionLabel('Paper Settings'),
            _CounterControl(
              label: 'Number of Copies',
              value: settings.numberOfCopies,
              min: 1,
              max: 10,
              onChanged: (value) =>
                  onUpdate((s) => s.copyWith(numberOfCopies: value)),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: listPanelCardBorder,
            ),
            _CounterControl(
              label: 'Extra Lines at End',
              value: settings.extraLinesAtEnd,
              min: 0,
              max: 10,
              onChanged: (value) =>
                  onUpdate((s) => s.copyWith(extraLinesAtEnd: value)),
            ),
            const _SectionLabel('Print Options'),
            _ToggleRow(
              label: 'Bold Text Styling',
              value: settings.useTextStylingBold,
              onChanged: (value) =>
                  onUpdate((s) => s.copyWith(useTextStylingBold: value)),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: listPanelCardBorder,
            ),
            _ToggleRow(
              label: 'Auto-cut Paper',
              value: settings.autoCutPaperAfterPrinting,
              onChanged: (value) => onUpdate(
                (s) => s.copyWith(autoCutPaperAfterPrinting: value),
              ),
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _CounterControl extends StatelessWidget {
  const _CounterControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: listPanelCardBorder),
          borderRadius: AppRadius.smBorder,
          color: AppColors.surface,
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
