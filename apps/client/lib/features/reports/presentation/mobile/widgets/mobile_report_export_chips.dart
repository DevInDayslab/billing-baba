import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Compact export action chips for mobile report app bars.
class MobileReportExportChips extends StatelessWidget {
  const MobileReportExportChips({
    required this.onPdf,
    required this.onExcel,
    super.key,
    this.onShareWithCa,
    this.showCa = true,
  });

  final VoidCallback onPdf;
  final VoidCallback onExcel;
  final VoidCallback? onShareWithCa;
  final bool showCa;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCa) ...[
          MobileReportExportChip(
            label: 'CA',
            backgroundColor: MobileReportTheme.exportCa,
            onTap: onShareWithCa,
          ),
          const Gap(AppSpacing.xs),
        ],
        MobileReportExportChip(
          label: 'Pdf',
          backgroundColor: MobileReportTheme.exportPdf,
          onTap: onPdf,
        ),
        const Gap(AppSpacing.xs),
        MobileReportExportChip(
          label: 'xls',
          backgroundColor: MobileReportTheme.exportExcel,
          onTap: onExcel,
        ),
      ],
    );
  }
}

class MobileReportExportChip extends StatelessWidget {
  const MobileReportExportChip({
    required this.label,
    required this.backgroundColor,
    super.key,
    this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: backgroundColor.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
