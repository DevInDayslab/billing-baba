import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReportExportChip extends StatelessWidget {
  const ReportExportChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ReportTextActionButton extends StatelessWidget {
  const ReportTextActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class ReportIconActionButton extends StatelessWidget {
  const ReportIconActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      color: AppColors.textSecondary,
      tooltip: tooltip,
    );
  }
}

class ReportXlsChip extends StatelessWidget {
  const ReportXlsChip({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ReportExportChip(
      label: 'xls',
      backgroundColor: const Color(0xFFE8F5E9),
      foregroundColor: const Color(0xFF2E7D32),
      onTap: onTap,
    );
  }
}

class ReportPdfChip extends StatelessWidget {
  const ReportPdfChip({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ReportExportChip(
      label: 'Pdf',
      backgroundColor: const Color(0xFFFFEBEE),
      foregroundColor: const Color(0xFFC62828),
      onTap: onTap,
    );
  }
}
