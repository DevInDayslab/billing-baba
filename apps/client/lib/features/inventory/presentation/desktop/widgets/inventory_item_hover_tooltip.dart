import 'dart:async';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_list_image_warmup.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tooltipWait = Duration(milliseconds: 200);
const _previewSize = 64.0;
const _bubbleMaxWidth = 152.0;

/// Compact row-hover preview — Material tooltip style; excludes stock & menu zones.
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
    final item = widget.item;
    _overlayEntry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 6),
              showWhenUnlinked: false,
              child: UnconstrainedBox(
                alignment: Alignment.topCenter,
                child: _MiniPreviewBubble(item: item),
              ),
            ),
          ],
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _hideTooltip(),
          child: widget.child,
        ),
      ),
    );
  }
}

class _MiniPreviewBubble extends StatelessWidget {
  const _MiniPreviewBubble({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final tooltipTheme = TooltipTheme.of(context);
    final decoration =
        tooltipTheme.decoration ??
        BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
        );
    final textStyle =
        tooltipTheme.textStyle ??
        const TextStyle(color: Colors.white, fontSize: 12);

    return Material(
      color: Colors.transparent,
      elevation: tooltipTheme.decoration == null ? 4 : 0,
      shadowColor: Colors.black26,
      child: Container(
        width: _bubbleMaxWidth,
        decoration: decoration,
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _previewSize,
              height: _previewSize,
              child: _PreviewImage(item: item),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(fontSize: 11, height: 1.2),
            ),
          ],
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
    final directUrl = _resolvePreviewUrl(ref);
    if (directUrl != null) {
      return _WarmPreviewImage(
        item: item,
        imageUrl: directUrl,
      );
    }

    if (!isServerBackedInventoryItemId(item.id)) {
      return _PreviewPlaceholder(item: item);
    }

    final imagesAsync = ref.watch(itemImagesProvider(item.id));
    return imagesAsync.when(
      loading: () => _PreviewPlaceholder(item: item),
      error: (_, _) => _PreviewPlaceholder(item: item),
      data: (images) {
        final image = _resolvePrimaryOrFirst(images);
        final url = image == null ? null : normalizeImageUrl(image.urlForGrid());
        if (url == null) return _PreviewPlaceholder(item: item);
        return _WarmPreviewImage(
          item: item,
          imageUrl: url,
          mediaAssetId: image!.mediaAssetId,
        );
      },
    );
  }

  String? _resolvePreviewUrl(WidgetRef ref) {
    final primary = normalizeImageUrl(item.primaryImageUrl);
    if (primary != null) return primary;

    final images = ref.read(itemImagesProvider(item.id)).asData?.value;
    if (images == null || images.isEmpty) return null;
    final image = _resolvePrimaryOrFirst(images);
    return image == null ? null : normalizeImageUrl(image.urlForGrid());
  }

  ItemImageModel? _resolvePrimaryOrFirst(List<ItemImageModel> images) {
    if (images.isEmpty) return null;
    return images.where((image) => image.isPrimary).firstOrNull ??
        images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).firstOrNull;
  }
}

/// Warm preview via shared image stack — disk cache first, no fade delay.
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
    final placeholder = _PreviewPlaceholder(item: item);

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: ColoredBox(
        color: Colors.white,
        child: AppNetworkImage(
          imageUrl: imageUrl,
          sourceMediaAssetId: mediaAssetId,
          fit: BoxFit.contain,
          width: _previewSize,
          height: _previewSize,
          displayContext: ImageDisplayContext.galleryThumb,
          memCacheWidth: (_previewSize * 2).round(),
          loadWhenVisible: false,
          fadeInDuration: Duration.zero,
          placeholder: placeholder,
          errorWidget: placeholder,
        ),
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Icon(
          item.type == ItemType.product
              ? Icons.inventory_2_outlined
              : Icons.handyman_outlined,
          size: 22,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
