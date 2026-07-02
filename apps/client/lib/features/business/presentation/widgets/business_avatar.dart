import 'package:billing_baba/features/business/utils/business_avatar_color.dart';
import 'package:flutter/material.dart';

class BusinessAvatar extends StatelessWidget {
  const BusinessAvatar({
    required this.name,
    required this.seed,
    this.diameter = 36,
    this.fontSize,
    super.key,
  });

  final String name;
  final String seed;
  final double diameter;
  final double? fontSize;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'B';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = diameter / 2;
    final textSize = fontSize ?? (diameter >= 80 ? 40 : radius * 0.78);

    return CircleAvatar(
      radius: radius,
      backgroundColor: businessAvatarColor(seed),
      child: Text(
        _initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
