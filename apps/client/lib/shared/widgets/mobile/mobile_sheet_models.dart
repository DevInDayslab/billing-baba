import 'package:flutter/material.dart';

/// Row action for [showMobileMoreActionsSheet] and [showMobileMenuSheet].
class MobileSheetAction {
  const MobileSheetAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
    this.enabled = true,
    this.showChevron = false,
  });

  final String label;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool enabled;
  final bool showChevron;
}

/// Icon grid item for [showMobileQuickActionsSheet].
class MobileQuickAction {
  const MobileQuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool enabled;
}

/// Create-new option for [showMobileAddOptionsSheet].
class MobileAddOption {
  const MobileAddOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool enabled;
}
