import 'dart:async';

import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

const _tooltipWait = Duration(milliseconds: 500);
const _previewSize = 64.0;
const _bubbleMaxWidth = 152.0;

/// Compact row-hover preview — Material tooltip style; excludes stock & menu zones.
class InventoryItemRowPreviewTooltip extends StatefulWidget {
  const InventoryItemRowPreviewTooltip({
    required this.item,
    required this.child,
    super.key,
  });

  final InventoryItem item;
  final Widget child;

  @override
  State<InventoryItemRowPreviewTooltip> createState() =>
      _InventoryItemRowPreviewTooltipState();
}

class _InventoryItemRowPreviewTooltipState
    extends State<InventoryItemRowPreviewTooltip> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
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
      builder: (context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            width: 0,
            height: 0,
            child: CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 6),
              showWhenUnlinked: false,
              child: IgnorePointer(
                child: _MiniPreviewBubble(item: item),
              ),
            ),
          ),
        ],
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
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
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

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.primaryImageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: ColoredBox(
          color: Colors.white,
          child: AppNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            width: _previewSize,
            height: _previewSize,
            displayContext: ImageDisplayContext.galleryThumb,
            memCacheWidth: (_previewSize * 2).round(),
            placeholder: _placeholder(),
            errorWidget: _placeholder(),
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
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
