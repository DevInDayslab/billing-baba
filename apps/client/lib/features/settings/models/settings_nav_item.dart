import 'package:flutter/material.dart';

/// A navigable global settings entry shown in the settings list.
class SettingsNavItem {
  const SettingsNavItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
    this.group = SettingsNavGroup.general,
  });

  final String id;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String route;
  final SettingsNavGroup group;
}

enum SettingsNavGroup {
  general('General'),
  reports('Reports'),
  messaging('Messaging'),
  account('Account & Data');

  const SettingsNavGroup(this.label);

  final String label;
}
