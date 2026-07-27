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

/// Grid item for mobile icon-grid bottom sheets.
class MobileMenuGridItem {
  const MobileMenuGridItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.showHighlight = false,
    this.showPremiumBadge = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  /// Orange sparkle accent (e.g. Payment-In, Payment-Out, Expenses).
  final bool showHighlight;

  /// Purple crown accent for premium reports.
  final bool showPremiumBadge;
  final bool enabled;
}

/// Grid item for [showMobileTransactionMenuSheet].
class MobileTransactionMenuItem {
  const MobileTransactionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.showHighlight = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Orange sparkle accent (e.g. Payment-In, Payment-Out, Expenses).
  final bool showHighlight;
  final bool enabled;
}

/// Grouped section for [showMobileTransactionMenuSheet].
class MobileTransactionMenuSection {
  const MobileTransactionMenuSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<MobileTransactionMenuItem> items;
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
