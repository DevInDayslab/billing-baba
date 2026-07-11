import 'package:flutter/material.dart';

const filterIconAsset = 'assets/icons/filter.png';

/// Filter icon from `assets/icons/filter.png`, tinted via [color].
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
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        filterIconAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
