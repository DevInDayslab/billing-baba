import 'dart:typed_data';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/features/business/utils/business_avatar_color.dart';
import 'package:billing_baba/features/parties/application/party_optimistic_profile_images_provider.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Circular party avatar with initials fallback and optional profile image.
class PartyAvatar extends ConsumerWidget {
  const PartyAvatar({
    required this.name,
    required this.seed,
    this.diameter = 36,
    this.fontSize,
    this.profileImageUrl,
    this.profileMediaAssetId,
    this.optimisticBytes,
    this.displayContext = ImageDisplayContext.list,
    this.onTap,
    this.partyId,
    super.key,
  });

  final String name;
  final String seed;
  final double diameter;
  final double? fontSize;
  final String? profileImageUrl;
  final String? profileMediaAssetId;

  /// Explicit local preview bytes (e.g. dialog). When null, [partyId] may still
  /// resolve bytes from [partyOptimisticProfileImagesProvider].
  final Uint8List? optimisticBytes;
  final ImageDisplayContext displayContext;
  final VoidCallback? onTap;

  /// When set, watches shared optimistic bytes so list/detail update instantly.
  final String? partyId;

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

  Widget _memoryAvatar(Uint8List bytes) {
    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Image.memory(
          bytes,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedOptimistic = partyId == null
        ? null
        : ref.watch(
            partyOptimisticProfileImagesProvider.select(
              (map) => map[partyId!],
            ),
          );
    final localBytes = optimisticBytes ?? sharedOptimistic;
    if (localBytes != null && localBytes.isNotEmpty) {
      final child = _memoryAvatar(localBytes);
      if (onTap == null) return child;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

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
