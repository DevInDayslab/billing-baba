import 'package:flutter/material.dart';

/// Conical/funnel filter icon (Vyapar-style), tinted via [color].
class AppFilterIcon extends StatelessWidget {
  const AppFilterIcon({
    required this.color,
    this.size = 14,
    super.key,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.filter_alt,
      size: size,
      color: color,
    );
  }
}
