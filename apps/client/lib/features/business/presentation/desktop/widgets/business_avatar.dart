import 'package:billing_baba/features/business/utils/business_avatar_color.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class BusinessAvatar extends StatelessWidget {
  const BusinessAvatar({
    required this.name,
    required this.seed,
    this.diameter = 36,
    this.fontSize,
    this.logoUrl,
    super.key,
  });

  final String name;
  final String seed;
  final double diameter;
  final double? fontSize;
  final String? logoUrl;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'B';
    return trimmed[0].toUpperCase();
  }

  Widget _initialsAvatar() {
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

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    if (url == null || url.isEmpty) {
      return _initialsAvatar();
    }

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: AppNetworkImage(
          imageUrl: url,
          displayContext: ImageDisplayContext.list,
          width: diameter,
          height: diameter,
          memCacheWidth: (diameter * 3).round(),
          loadWhenVisible: false,
          placeholder: _initialsAvatar(),
          errorWidget: _initialsAvatar(),
        ),
      ),
    );
  }
}
