import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/core/media/pick_media_image.dart';
import 'package:billing_baba/core/media/prepare_media_upload_bytes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_image_preview_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/pending_item_image.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _maxGalleryImages = 20;
const _thumbSize = 52.0;

class ItemImageGallerySection extends ConsumerStatefulWidget {
  const ItemImageGallerySection({
    required this.itemId,
    this.label = '',
    this.seedPrimaryImageUrl,
    super.key,
  });

  final String itemId;
  final String label;
  final String? seedPrimaryImageUrl;

  @override
  ConsumerState<ItemImageGallerySection> createState() =>
      _ItemImageGallerySectionState();
}

class _ItemImageGallerySectionState
    extends ConsumerState<ItemImageGallerySection> {
  final List<PendingItemImage> _pending = [];
  var _uploadGeneration = 0;
  var _seedApplied = false;
  final Set<String> _prefetchedImageIds = {};

  ItemImages get _imagesNotifier =>
      ref.read(itemImagesProvider(widget.itemId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applySeedIfNeeded());
  }

  @override
  void didUpdateWidget(covariant ItemImageGallerySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seedPrimaryImageUrl != widget.seedPrimaryImageUrl ||
        oldWidget.itemId != widget.itemId) {
      _seedApplied = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _applySeedIfNeeded());
    }
  }

  void _applySeedIfNeeded() {
    if (_seedApplied) return;
    final seedUrl = widget.seedPrimaryImageUrl?.trim();
    if (seedUrl == null || seedUrl.isEmpty) return;

    _seedApplied = true;
    _imagesNotifier.seed([
      seedItemImageFromUrl(widget.itemId, seedUrl),
    ]);
    unawaited(_prefetchImageUrl(seedUrl));
  }

  Future<void> _invalidateGalleryImage(ItemImageModel image) async {
    await ref.read(imageServiceProvider).invalidateImage(
          url: image.urlForGrid(),
          mediaAssetId: image.mediaAssetId,
          extraUrls: galleryImageUrls(image),
        );
  }

  Future<void> _prefetchGalleryImage(ItemImageModel image) async {
    try {
      final imageService = ref.read(imageServiceProvider);
      final thumbUrl = normalizeImageUrl(image.urlForGrid());
      final detailUrl = normalizeImageUrl(image.urlForDetail());
      final mediaAssetId = image.mediaAssetId?.trim();

      if (mediaAssetId != null && mediaAssetId.isNotEmpty) {
        await imageService.prefetchResolved(
          sourceMediaAssetId: mediaAssetId,
          context: ImageDisplayContext.galleryThumb,
          fallbackUrl: thumbUrl,
        );
        if (detailUrl != null) {
          await imageService.prefetchResolved(
            sourceMediaAssetId: mediaAssetId,
            context: ImageDisplayContext.detail,
            fallbackUrl: detailUrl,
          );
        }
        return;
      }

      if (thumbUrl != null) {
        await imageService.prefetchUrl(
          thumbUrl,
          cacheKey: buildImageCacheKey(fallbackUrl: thumbUrl),
        );
      }
    } on Object {
      // Best-effort thumbnail warm-up.
    }
  }

  Future<void> _prefetchImageUrl(String url) async {
    try {
      final normalized = normalizeImageUrl(url);
      if (normalized == null) return;
      await ref.read(imageServiceProvider).prefetchUrl(
            normalized,
            cacheKey: buildImageCacheKey(fallbackUrl: normalized),
          );
    } on Object {
      // Best-effort thumbnail warm-up.
    }
  }

  void _syncPrimaryImageToInventoryList({String? primaryImageUrl}) {
    ref
        .read(inventoryItemsProvider.notifier)
        .patchItemPrimaryImageUrl(widget.itemId, primaryImageUrl);
  }

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

    final picked = await pickMediaImageBytes(context: context);
    if (picked == null) return false;

    final generation = ++_uploadGeneration;
    final localId = 'local-$generation';
    final shouldBePrimary = isPrimary || remote.isEmpty;
    final pending = PendingItemImage(
      localId: localId,
      bytes: picked.bytes,
      replacesImageId: replacesImageId,
      isPrimary: shouldBePrimary,
    );

    // Instant local preview — prepare + upload continue in the background.
    setState(() {
      _pending.removeWhere((p) => p.replacesImageId == replacesImageId);
      _pending.add(pending);
    });

    unawaited(
      _completeUpload(
        localId: localId,
        generation: generation,
        pickedBytes: picked.bytes,
        pickedMime: picked.mimeType,
        replacesImageId: replacesImageId,
        isPrimary: shouldBePrimary,
        remote: remote,
      ),
    );
    return true;
  }

  Future<void> _completeUpload({
    required String localId,
    required int generation,
    required Uint8List pickedBytes,
    required String pickedMime,
    required bool isPrimary,
    required List<ItemImageModel> remote,
    String? replacesImageId,
  }) async {
    try {
      final prepared = await prepareMediaUploadBytes(
        bytes: pickedBytes,
        mimeType: pickedMime,
      );

      if (!mounted || generation != _uploadGeneration) return;

      final service = await ref.read(inventoryServiceProvider.future);
      final uploaded = await service.uploadItemImage(
        widget.itemId,
        bytes: prepared.bytes,
        mimeType: prepared.mimeType,
        isPrimary: isPrimary,
        replacesImageId: replacesImageId,
      );

      if (replacesImageId != null) {
        final oldImage = remote
            .where((img) => img.id == replacesImageId)
            .firstOrNull;
        if (oldImage != null) {
          unawaited(_invalidateGalleryImage(oldImage));
        }
      }

      if (!mounted || generation != _uploadGeneration) return;

      _imagesNotifier.upsert(uploaded);
      setState(() {
        _pending.removeWhere((p) => p.localId == localId);
      });

      if (uploaded.isPrimary) {
        _syncPrimaryImageToInventoryList(
          primaryImageUrl: uploaded.urlForGrid(),
        );
      }

      unawaited(_prefetchGalleryImage(uploaded));
      unawaited(_imagesNotifier.refreshInBackground());
    } on Exception catch (error) {
      if (!mounted || generation != _uploadGeneration) return;
      setState(() {
        _pending.removeWhere((p) => p.localId == localId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
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

    final previous = ref.read(itemImagesProvider(widget.itemId)).value ?? [];
    _imagesNotifier.removeLocal(image.id);

    final remaining = previous
        .where((candidate) => candidate.id != image.id)
        .toList();
    final nextPrimary =
        remaining.where((candidate) => candidate.isPrimary).firstOrNull ??
        remaining.firstOrNull;
    _syncPrimaryImageToInventoryList(
      primaryImageUrl: nextPrimary?.urlForGrid(),
    );

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItemImage(widget.itemId, image.id);
      unawaited(_invalidateGalleryImage(image));
      unawaited(_imagesNotifier.refreshInBackground());
      return true;
    } on Exception catch (error) {
      _imagesNotifier.applyOptimistic(previous);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _setPrimary(ItemImageModel image) async {
    if (image.isPrimary) return;

    final previous = ref.read(itemImagesProvider(widget.itemId)).value ?? [];
    _imagesNotifier.setPrimaryLocal(image.id);
    _syncPrimaryImageToInventoryList(primaryImageUrl: image.urlForGrid());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.setPrimaryItemImage(widget.itemId, image.id);
      unawaited(_imagesNotifier.refreshInBackground());
    } on Exception catch (error) {
      _imagesNotifier.applyOptimistic(previous);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not set primary: $error')),
      );
      rethrow;
    }
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
    ref.listen(itemImagesProvider(widget.itemId), (previous, next) {
      final images = next.value;
      if (images == null || images.isEmpty) return;
      for (final image in images) {
        if (_prefetchedImageIds.contains(image.id)) continue;
        _prefetchedImageIds.add(image.id);
        unawaited(_prefetchGalleryImage(image));
      }
    });

    final imagesAsync = ref.watch(itemImagesProvider(widget.itemId));
    final images = imagesAsync.value ?? const <ItemImageModel>[];
    final remote = List<ItemImageModel>.from(images)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final replacingIds = _pending
        .map((p) => p.replacesImageId)
        .whereType<String>()
        .toSet();
    final visibleRemote = remote
        .where((img) => !replacingIds.contains(img.id))
        .toList();
    final hasAny = visibleRemote.isNotEmpty || _pending.isNotEmpty;

    if (!hasAny) {
      if (imagesAsync.isLoading) {
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: null,
            icon: const Icon(LucideIcons.imagePlus, size: 16),
            label: Text(
              widget.label.trim().isEmpty
                  ? 'Add Item Image'
                  : 'Add ${widget.label.replaceAll('Images', 'Image')}',
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary.withValues(alpha: 0.55),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      }

      if (imagesAsync.hasError) {
        return Text(
          'Could not load images: ${imagesAsync.error}',
          style: const TextStyle(color: AppColors.error, fontSize: 12),
        );
      }

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
                    child: const SizedBox.shrink(),
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
