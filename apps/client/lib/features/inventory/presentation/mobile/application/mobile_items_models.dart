import 'package:flutter/material.dart';

class MobileItemsQuickLink {
  const MobileItemsQuickLink({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE8F4FD),
    this.iconColor = const Color(0xFF42A5F5),
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
}
