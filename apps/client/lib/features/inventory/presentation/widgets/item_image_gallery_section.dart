import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/core/media/pick_media_image.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/item_image_preview_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/pending_item_image.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:billing_baba/shared/widgets/app_network_image_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _maxGalleryImages = 20;
const _thumbSize = 52.0;

class ItemImageGallerySection extends ConsumerStatefulWidget {
  const ItemImageGallerySection({
    required this.itemId,
    this.label = '',
    super.key,
  });

  final String itemId;
  final String label;

  @override
  ConsumerState<ItemImageGallerySection> createState() =>
      _ItemImageGallerySectionState();
}

class _ItemImageGallerySectionState
    extends ConsumerState<ItemImageGallerySection> {
  final List<PendingItemImage> _pending = [];
  var _uploadGeneration = 0;

  /// Optimistic primary override until provider refreshes.
  String? _optimisticPrimaryId;

  void _invalidateCaches() {
    ref.invalidate(itemImagesProvider(widget.itemId));
    ref.invalidate(productDetailProvider(widget.itemId));
  }

  /// Returns true when an image was uploaded successfully.
  Future<bool> _upload({
    String? replacesImageId,
    bool isPrimary = false,
  }) async {
    final remote = ref.read(itemImagesProvider(widget.itemId)).value ?? [];
    if (replacesImageId == null &&
        remote.length + _pending.length >= _maxGalleryImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum $_maxGalleryImages images')),
        );
      }
      return false;
    }

    // Shared Business Profile pick + prepare pipeline.
    final picked = await pickAndPrepareMediaImage(context: context);
    if (picked == null) return false;

    final generation = ++_uploadGeneration;
    final localId = 'local-$generation';
    final pending = PendingItemImage(
      localId: localId,
      bytes: picked.previewBytes,
      replacesImageId: replacesImageId,
      isPrimary: isPrimary || remote.isEmpty,
    );

    // Instant local preview — upload continues in the background.
    setState(() {
      _pending.removeWhere((p) => p.replacesImageId == replacesImageId);
      _pending.add(pending);
    });

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final uploaded = await service.uploadItemImage(
        widget.itemId,
        bytes: picked.bytes,
        mimeType: picked.mimeType,
        isPrimary: pending.isPrimary,
        replacesImageId: replacesImageId,
      );

      if (replacesImageId != null) {
        final oldUrl = remote
            .where((img) => img.id == replacesImageId)
            .map((img) => img.urlForGrid())
            .firstOrNull;
        unawaited(evictAppNetworkImage(oldUrl));
      }

      if (!mounted) return true;
      setState(() {
        _pending.removeWhere((p) => p.localId == localId);
        if (uploaded.isPrimary) {
          _optimisticPrimaryId = uploaded.id;
        }
      });
      _invalidateCaches();
      return true;
    } on Exception catch (error) {
      if (!mounted) return false;
      setState(() {
        _pending.removeWhere((p) => p.localId == localId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
      return false;
    }
  }

  Future<bool> _deleteImage(ItemImageModel image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This image will be removed from the gallery.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItemImage(widget.itemId, image.id);
      unawaited(evictAppNetworkImage(image.urlForGrid()));
      if (_optimisticPrimaryId == image.id) {
        _optimisticPrimaryId = null;
      }
      _invalidateCaches();
      return true;
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _setPrimary(ItemImageModel image) async {
    if (image.isPrimary && _optimisticPrimaryId == null) return;
    if (_optimisticPrimaryId == image.id) return;

    final previous = _optimisticPrimaryId;
    setState(() => _optimisticPrimaryId = image.id);

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.setPrimaryItemImage(widget.itemId, image.id);
      _invalidateCaches();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _optimisticPrimaryId = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not set primary: $error')),
      );
      rethrow;
    }
  }

  List<ItemImageModel> _sortedRemote(List<ItemImageModel> images) {
    final sorted = List<ItemImageModel>.from(images)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final primaryId = _optimisticPrimaryId;
    if (primaryId == null) return sorted;
    return sorted
        .map((img) => img.copyWith(isPrimary: img.id == primaryId))
        .toList();
  }

  Future<void> _openPreview(
    List<ItemImageModel> images,
    int index,
  ) async {
    await showItemImagePreviewDialog(
      context: context,
      images: images,
      initialIndex: index,
      onSetPrimary: _setPrimary,
      onReplace: (image) => _upload(replacesImageId: image.id),
      onDelete: _deleteImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(itemImagesProvider(widget.itemId));

    return imagesAsync.when(
      loading: () => const SizedBox(
        height: _thumbSize,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, _) => Text(
        'Could not load images: $error',
        style: const TextStyle(color: AppColors.error, fontSize: 12),
      ),
      data: (images) {
        final remote = _sortedRemote(images);
        final replacingIds = _pending
            .map((p) => p.replacesImageId)
            .whereType<String>()
            .toSet();
        final visibleRemote = remote
            .where((img) => !replacingIds.contains(img.id))
            .toList();
        final hasAny = visibleRemote.isNotEmpty || _pending.isNotEmpty;

        if (!hasAny) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _upload(isPrimary: true),
              icon: const Icon(LucideIcons.imagePlus, size: 16),
              label: Text(
                widget.label.trim().isEmpty
                    ? 'Add Item Image'
                    : 'Add ${widget.label.replaceAll('Images', 'Image')}',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label.trim().isNotEmpty) ...[
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < visibleRemote.length; i++)
                  _RemoteThumb(
                    image: visibleRemote[i],
                    onTap: () => _openPreview(visibleRemote, i),
                  ),
                for (final pending in _pending)
                  _PendingThumb(
                    bytes: pending.bytes,
                    isPrimary: pending.isPrimary,
                  ),
                if (remote.length + _pending.length < _maxGalleryImages)
                  _AddChip(onTap: _upload),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RemoteThumb extends StatelessWidget {
  const _RemoteThumb({
    required this.image,
    required this.onTap,
  });

  final ItemImageModel image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Ink(
          width: _thumbSize,
          height: _thumbSize,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: AppRadius.smBorder,
                child: AppNetworkImage(
                  imageUrl: image.urlForGrid(),
                  sourceMediaAssetId: image.mediaAssetId,
                  displayContext: ImageDisplayContext.galleryThumb,
                  fit: BoxFit.contain,
                  memCacheWidth: (_thumbSize * 2).round(),
                  placeholder: ColoredBox(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: ColoredBox(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_outlined, size: 18),
                  ),
                ),
              ),
              if (image.isPrimary)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingThumb extends StatelessWidget {
  const _PendingThumb({
    required this.bytes,
    required this.isPrimary,
  });

  final Uint8List bytes;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _thumbSize,
      height: _thumbSize,
      decoration: BoxDecoration(
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            bytes,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            cacheWidth: (_thumbSize * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (isPrimary)
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        width: _thumbSize,
        height: _thumbSize,
        decoration: BoxDecoration(
          borderRadius: AppRadius.smBorder,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
          color: AppColors.primary.withValues(alpha: 0.06),
        ),
        child: const Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
      ),
    );
  }
}
