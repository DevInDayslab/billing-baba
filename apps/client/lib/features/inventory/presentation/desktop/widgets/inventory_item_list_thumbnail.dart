import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Square thumbnail for inventory list rows and search suggestions.
const inventoryItemListThumbSize = 40.0;

class InventoryItemListThumbnail extends ConsumerWidget {
  const InventoryItemListThumbnail({
    required this.item,
    super.key,
    this.size = inventoryItemListThumbSize,
    this.borderRadius = 4,
  });

  final InventoryItem item;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryUrl = normalizeImageUrl(item.primaryImageUrl);

    Widget image;
    if (!isServerBackedInventoryItemId(item.id)) {
      image = primaryUrl != null
          ? _NetworkThumb(
              item: item,
              imageUrl: primaryUrl,
              size: size,
              borderRadius: borderRadius,
            )
          : _Placeholder(item: item, size: size, borderRadius: borderRadius);
    } else {
      final imagesAsync = ref.watch(itemImagesProvider(item.id));
      image = imagesAsync.when(
        loading: () => _resolveThumb(
          item: item,
          size: size,
          borderRadius: borderRadius,
          primaryUrl: primaryUrl,
          images: ref.read(itemImagesProvider(item.id)).asData?.value,
        ),
        error: (_, _) => _resolveThumb(
          item: item,
          size: size,
          borderRadius: borderRadius,
          primaryUrl: primaryUrl,
          images: ref.read(itemImagesProvider(item.id)).asData?.value,
        ),
        data: (images) => _resolveThumb(
          item: item,
          size: size,
          borderRadius: borderRadius,
          primaryUrl: primaryUrl,
          images: images,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: image,
    );
  }

  static Widget _resolveThumb({
    required InventoryItem item,
    required double size,
    required double borderRadius,
    required String? primaryUrl,
    required List<ItemImageModel>? images,
  }) {
    final image = images == null ? null : _resolvePrimaryOrFirst(images);
    final url = image != null
        ? normalizeImageUrl(image.urlForGrid())
        : primaryUrl;
    if (url == null) {
      return _Placeholder(item: item, size: size, borderRadius: borderRadius);
    }
    return _NetworkThumb(
      item: item,
      imageUrl: url,
      size: size,
      borderRadius: borderRadius,
      mediaAssetId: image?.mediaAssetId,
    );
  }

  static ItemImageModel? _resolvePrimaryOrFirst(List<ItemImageModel> images) {
    if (images.isEmpty) return null;
    return images.where((image) => image.isPrimary).firstOrNull ??
        images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).firstOrNull;
  }
}

class _NetworkThumb extends StatelessWidget {
  const _NetworkThumb({
    required this.item,
    required this.imageUrl,
    required this.size,
    required this.borderRadius,
    this.mediaAssetId,
  });

  final InventoryItem item;
  final String imageUrl;
  final double size;
  final double borderRadius;
  final String? mediaAssetId;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AppNetworkImage(
        imageUrl: imageUrl,
        sourceMediaAssetId: mediaAssetId,
        width: size,
        height: size,
        displayContext: ImageDisplayContext.galleryThumb,
        memCacheWidth: (size * 2).round(),
        loadWhenVisible: false,
        fadeInDuration: Duration.zero,
        fit: BoxFit.cover,
        placeholder: _Placeholder(
          item: item,
          size: size,
          borderRadius: borderRadius,
          loading: true,
        ),
        errorWidget: _Placeholder(
          item: item,
          size: size,
          borderRadius: borderRadius,
          failed: true,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.item,
    required this.size,
    required this.borderRadius,
    this.loading = false,
    this.failed = false,
  });

  final InventoryItem item;
  final double size;
  final double borderRadius;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: loading
            ? SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                failed
                    ? Icons.broken_image_outlined
                    : item.type == ItemType.product
                    ? Icons.inventory_2_outlined
                    : Icons.handyman_outlined,
                size: size * 0.45,
                color: Colors.grey.shade500,
              ),
      ),
    );
  }
}
