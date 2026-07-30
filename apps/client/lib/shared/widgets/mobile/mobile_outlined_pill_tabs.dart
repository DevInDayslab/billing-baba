import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A single option for [MobileOutlinedPillTabs].
class MobileOutlinedPillTab {
  const MobileOutlinedPillTab({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// Side-by-side outlined pill tabs used on mobile list/filter screens.
class MobileOutlinedPillTabs extends StatelessWidget {
  const MobileOutlinedPillTabs({
    required this.tabs,
    required this.activeTabId,
    required this.onChanged,
    super.key,
    this.activeColor,
    this.activeBackgroundColor,
    this.inactiveBorderColor = const Color(0xFFE3E7ED),
    this.inactiveTextColor,
    this.borderWidth = 1.2,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.gap = AppSpacing.sm,
  });

  final List<MobileOutlinedPillTab> tabs;
  final String activeTabId;
  final ValueChanged<String> onChanged;
  final Color? activeColor;
  final Color? activeBackgroundColor;
  final Color inactiveBorderColor;
  final Color? inactiveTextColor;
  final double borderWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final resolvedActiveColor = activeColor ?? AppColors.error;
    final resolvedActiveBackground =
        activeBackgroundColor ?? resolvedActiveColor.withValues(alpha: 0.08);
    final resolvedInactiveText = inactiveTextColor ?? AppColors.textSecondary;

    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++) ...[
            if (index > 0) SizedBox(width: gap),
            Expanded(
              child: _Pill(
                label: tabs[index].label,
                isActive: tabs[index].id == activeTabId,
                activeColor: resolvedActiveColor,
                activeBackgroundColor: resolvedActiveBackground,
                inactiveBorderColor: inactiveBorderColor,
                inactiveTextColor: resolvedInactiveText,
                borderWidth: borderWidth,
                fontSize: fontSize,
                fontWeight: fontWeight,
                onTap: () => onChanged(tabs[index].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.inactiveBorderColor,
    required this.inactiveTextColor,
    required this.borderWidth,
    required this.fontSize,
    required this.fontWeight,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeBackgroundColor;
  final Color inactiveBorderColor;
  final Color inactiveTextColor;
  final double borderWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeBackgroundColor : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? activeColor : inactiveBorderColor,
              width: borderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.inter(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: isActive ? activeColor : inactiveTextColor,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
