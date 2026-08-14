import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:flutter/material.dart';

/// Top-level grouping shown in the mobile Menu hub.
enum MobileMenuSection {
  business('Business', useNavCards: true),
  utilities('Utilities', useNavCards: true),
  settings('Settings', showHeader: false),
  support('Support', showHeader: false),
  account('Account', showHeader: false);

  const MobileMenuSection(
    this.label, {
    this.showHeader = true,
    this.useNavCards = false,
  });

  final String label;
  final bool showHeader;
  final bool useNavCards;
}

/// Non-route actions handled inside the Menu hub.
enum MobileMenuAction {
  none,
  externalUrl,
  mailto,
  openReport,
  versionInfo,
  logout,
}

/// One navigable or expandable entry in the mobile Menu hub.
class MobileMenuItem {
  const MobileMenuItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.route,
    this.reportIntent,
    this.children = const [],
    this.section,
    this.action = MobileMenuAction.none,
    this.externalUrl,
    this.enabled = true,
    this.isAccordion = false,
    this.useFlatExpandable = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? route;
  final ReportsNavIntent? reportIntent;
  final List<MobileMenuItem> children;
  final MobileMenuSection? section;
  final MobileMenuAction action;
  final String? externalUrl;
  final bool enabled;
  final bool isAccordion;
  final bool useFlatExpandable;

  bool get isLeaf =>
      !isAccordion &&
      children.isEmpty &&
      (route != null ||
          reportIntent != null ||
          action != MobileMenuAction.none);

  MobileMenuItem copyWith({
    List<MobileMenuItem>? children,
    bool? enabled,
  }) {
    return MobileMenuItem(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      route: route,
      reportIntent: reportIntent,
      children: children ?? this.children,
      section: section,
      action: action,
      externalUrl: externalUrl,
      enabled: enabled ?? this.enabled,
      isAccordion: isAccordion,
      useFlatExpandable: useFlatExpandable,
    );
  }
}
