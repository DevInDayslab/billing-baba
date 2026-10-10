import 'dart:async';

import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tooltipWait = Duration(milliseconds: 200);
const _previewSize = 48.0;
const _bubbleWidth = 104.0;

/// Compact row-hover preview — appears below the item name in the list.
class InventoryItemRowPreviewTooltip extends ConsumerStatefulWidget {
  const InventoryItemRowPreviewTooltip({
    required this.item,
    required this.child,
    super.key,
  });

  final InventoryItem item;
  final Widget child;

  @override
  ConsumerState<InventoryItemRowPreviewTooltip> createState() =>
      _InventoryItemRowPreviewTooltipState();
}

class _InventoryItemRowPreviewTooltipState
    extends ConsumerState<InventoryItemRowPreviewTooltip> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _onHoverEnter() {
    ref.read(inventoryListImageWarmupProvider).warmItem(widget.item);
    _scheduleShow();
  }

  void _scheduleShow() {
    _showTimer?.cancel();
    _showTimer = Timer(_tooltipWait, () {
      if (!mounted) return;
      _showTooltip();
    });
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final container = ProviderScope.containerOf(context, listen: false);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => UncontrolledProviderScope(
        container: container,
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 6),
            showWhenUnlinked: false,
            child: UnconstrainedBox(
              alignment: Alignment.topCenter,
              child: _MiniPreviewBubble(item: widget.item),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (isServerBackedInventoryItemId(widget.item.id)) {
      ref.listen(itemImagesProvider(widget.item.id), (_, _) {
        _overlayEntry?.markNeedsBuild();
      });
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _hideTooltip(),
        child: widget.child,
      ),
    );
  }
}

class _MiniPreviewBubble extends StatelessWidget {
  const _MiniPreviewBubble({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.black26,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black26),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: _bubbleWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: _previewSize,
                  height: _previewSize,
                  child: _PreviewImage(item: item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewImage extends ConsumerWidget {
  const _PreviewImage({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryUrl = normalizeImageUrl(item.primaryImageUrl);

    if (!isServerBackedInventoryItemId(item.id)) {
      if (primaryUrl != null) {
        return _WarmPreviewImage(item: item, imageUrl: primaryUrl);
      }
      return _ImageSlotPlaceholder(item: item);
    }

    final imagesAsync = ref.watch(itemImagesProvider(item.id));
    return imagesAsync.when(
      loading: () => _resolveWarmPreview(
        item: item,
        primaryUrl: primaryUrl,
        images: ref.read(itemImagesProvider(item.id)).asData?.value,
      ),
      error: (_, _) => _resolveWarmPreview(
        item: item,
        primaryUrl: primaryUrl,
        images: ref.read(itemImagesProvider(item.id)).asData?.value,
      ),
      data: (images) => _resolveWarmPreview(
        item: item,
        primaryUrl: primaryUrl,
        images: images,
      ),
    );
  }

  Widget _resolveWarmPreview({
    required InventoryItem item,
    required String? primaryUrl,
    required List<ItemImageModel>? images,
  }) {
    final image = images == null ? null : _resolvePrimaryOrFirst(images);
    final url = image != null
        ? normalizeImageUrl(image.urlForGrid())
        : primaryUrl;
    if (url == null) {
      return _ImageSlotPlaceholder(item: item);
    }
    return _WarmPreviewImage(
      item: item,
      imageUrl: url,
      mediaAssetId: image?.mediaAssetId,
    );
  }

  ItemImageModel? _resolvePrimaryOrFirst(List<ItemImageModel> images) {
    if (images.isEmpty) return null;
    return images.where((image) => image.isPrimary).firstOrNull ??
        images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).firstOrNull;
  }
}

/// Matches gallery thumbs — grey slot, visible loading/error, no white-on-white flash.
class _WarmPreviewImage extends StatelessWidget {
  const _WarmPreviewImage({
    required this.item,
    required this.imageUrl,
    this.mediaAssetId,
  });

  final InventoryItem item;
  final String imageUrl;
  final String? mediaAssetId;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: AppNetworkImage(
        imageUrl: imageUrl,
        sourceMediaAssetId: mediaAssetId,
        width: _previewSize,
        height: _previewSize,
        displayContext: ImageDisplayContext.galleryThumb,
        memCacheWidth: (_previewSize * 2).round(),
        loadWhenVisible: false,
        fadeInDuration: Duration.zero,
        placeholder: _ImageSlotPlaceholder(item: item, loading: true),
        errorWidget: _ImageSlotPlaceholder(item: item, failed: true),
      ),
    );
  }
}

class _ImageSlotPlaceholder extends StatelessWidget {
  const _ImageSlotPlaceholder({
    required this.item,
    this.loading = false,
    this.failed = false,
  });

  final InventoryItem item;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                failed
                    ? Icons.broken_image_outlined
                    : item.type == ItemType.product
                    ? Icons.inventory_2_outlined
                    : Icons.handyman_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),
      ),
    );
  }
}
