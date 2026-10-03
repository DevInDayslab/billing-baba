import 'dart:typed_data';

import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style horizontal image thumbnails with add button for Add Item.
class MobileAddItemImageStrip extends ConsumerStatefulWidget {
  const MobileAddItemImageStrip({
    required this.pendingPhotos,
    required this.onAddPhoto,
    required this.onTapPendingPhoto,
    this.itemId,
    this.seedPrimaryImageUrl,
    this.onTapRemotePhoto,
    this.maxPhotos = 20,
    super.key,
  });

  final List<Uint8List> pendingPhotos;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onTapPendingPhoto;
  final String? itemId;
  final String? seedPrimaryImageUrl;
  final ValueChanged<ItemImageModel>? onTapRemotePhoto;
  final int maxPhotos;

  static const double thumbSize = 56;

  @override
  ConsumerState<MobileAddItemImageStrip> createState() =>
      _MobileAddItemImageStripState();
}

class _MobileAddItemImageStripState
    extends ConsumerState<MobileAddItemImageStrip> {
  bool _seedApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applySeedIfNeeded();
  }

  @override
  void didUpdateWidget(MobileAddItemImageStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId ||
        oldWidget.seedPrimaryImageUrl != widget.seedPrimaryImageUrl) {
      _seedApplied = false;
    }
  }

  void _applySeedIfNeeded() {
    if (_seedApplied || widget.itemId == null) return;
    final seedUrl = widget.seedPrimaryImageUrl?.trim();
    if (seedUrl == null || seedUrl.isEmpty) return;

    final notifier = ref.read(itemImagesProvider(widget.itemId!).notifier);
    final current = ref.read(itemImagesProvider(widget.itemId!)).value ?? [];
    if (current.isNotEmpty) {
      _seedApplied = true;
      return;
    }

    _seedApplied = true;
    notifier.seed([seedItemImageFromUrl(widget.itemId!, seedUrl)]);
  }

  @override
  Widget build(BuildContext context) {
    final remote = widget.itemId != null
        ? ref.watch(itemImagesProvider(widget.itemId!)).value ??
              const <ItemImageModel>[]
        : const <ItemImageModel>[];
    final sortedRemote = List<ItemImageModel>.from(remote)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final totalCount = sortedRemote.length + widget.pendingPhotos.length;
    final canAdd = totalCount < widget.maxPhotos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MobileAddItemTheme.horizontalPadding,
        8,
        MobileAddItemTheme.horizontalPadding,
        12,
      ),
      child: SizedBox(
        height: MobileAddItemImageStrip.thumbSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount:
              sortedRemote.length +
              widget.pendingPhotos.length +
              (canAdd ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index < sortedRemote.length) {
              final image = sortedRemote[index];
              return _RemoteThumb(
                image: image,
                onTap: widget.onTapRemotePhoto == null
                    ? null
                    : () => widget.onTapRemotePhoto!(image),
              );
            }

            final pendingIndex = index - sortedRemote.length;
            if (pendingIndex < widget.pendingPhotos.length) {
              return _PendingThumb(
                bytes: widget.pendingPhotos[pendingIndex],
                onTap: () => widget.onTapPendingPhoto(pendingIndex),
              );
            }

            return _AddPhotoChip(onTap: widget.onAddPhoto);
          },
        ),
      ),
    );
  }
}

class _RemoteThumb extends StatelessWidget {
  const _RemoteThumb({
    required this.image,
    this.onTap,
  });

  final ItemImageModel image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: MobileAddItemImageStrip.thumbSize,
          height: MobileAddItemImageStrip.thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: AppNetworkImage(
              imageUrl: image.urlForGrid(),
              sourceMediaAssetId: image.mediaAssetId,
              displayContext: ImageDisplayContext.galleryThumb,
              fit: BoxFit.cover,
              memCacheWidth: (MobileAddItemImageStrip.thumbSize * 2).round(),
              placeholder: ColoredBox(
                color: Colors.grey.shade100,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: ColoredBox(
                color: Colors.grey.shade100,
                child: const Icon(LucideIcons.imageOff, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingThumb extends StatelessWidget {
  const _PendingThumb({
    required this.bytes,
    required this.onTap,
  });

  final Uint8List bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: MobileAddItemImageStrip.thumbSize,
          height: MobileAddItemImageStrip.thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoChip extends StatelessWidget {
  const _AddPhotoChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: MobileAddItemImageStrip.thumbSize,
          height: MobileAddItemImageStrip.thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            color: AppColors.surface,
          ),
          child: Icon(
            LucideIcons.plus,
            size: 24,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
