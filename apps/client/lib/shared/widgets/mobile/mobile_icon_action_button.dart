import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact circular icon button for mobile app bars and tool rows.
class MobileIconActionButton extends StatelessWidget {
  const MobileIconActionButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.badgeCount,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final int? badgeCount;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: iconColor ?? AppColors.textPrimary,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: _buildIcon(),
    );

    if (tooltip == null) return button;
    return button;
  }

  Widget _buildIcon() {
    final iconWidget = Icon(icon, size: AppIconSize.lg);

    final count = badgeCount;
    if (count == null || count <= 0) return iconWidget;

    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      child: iconWidget,
    );
  }
}
