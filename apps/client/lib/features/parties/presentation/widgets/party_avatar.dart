import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/features/business/utils/business_avatar_color.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

/// Circular party avatar with initials fallback and optional profile image.
class PartyAvatar extends StatelessWidget {
  const PartyAvatar({
    required this.name,
    required this.seed,
    this.diameter = 36,
    this.fontSize,
    this.profileImageUrl,
    this.profileMediaAssetId,
    this.displayContext = ImageDisplayContext.list,
    this.onTap,
    super.key,
  });

  final String name;
  final String seed;
  final double diameter;
  final double? fontSize;
  final String? profileImageUrl;
  final String? profileMediaAssetId;
  final ImageDisplayContext displayContext;
  final VoidCallback? onTap;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'P';
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
    final url = profileImageUrl?.trim();
    final mediaId = profileMediaAssetId?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    Widget child;
    if (!hasUrl && (mediaId == null || mediaId.isEmpty)) {
      child = _initialsAvatar();
    } else {
      child = ClipOval(
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: AppNetworkImage(
            imageUrl: url ?? '',
            sourceMediaAssetId: mediaId,
            displayContext: displayContext,
            width: diameter,
            height: diameter,
            // Avatars are always in-viewport when built; visibility detectors
            // race with dialog/detail dispose and leave initials stuck.
            loadWhenVisible: false,
            placeholder: _initialsAvatar(),
            errorWidget: _initialsAvatar(),
          ),
        ),
      );
    }

    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
