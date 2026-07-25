import 'package:billing_baba/core/media/image_display_context.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/item_card.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_category_style.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// POS product thumbnail — primary inventory image with category icon fallback.
class PosItemThumbnail extends ConsumerWidget {
  const PosItemThumbnail({
    required this.item,
    super.key,
  });

  final PosItem item;

  static const _iconSize = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (ItemCard.imageHeight * dpr).round();
    final fallback = _CategoryIcon(styleKey: item.categoryStyleKey);
    final directUrl = item.imageUrl?.trim();

    if (directUrl != null && directUrl.isNotEmpty) {
      return _ImageThumb(
        imageUrl: directUrl,
        mediaAssetId: item.imageMediaAssetId,
        memCacheWidth: cacheWidth,
        fallback: fallback,
      );
    }

    if (!isServerBackedInventoryItemId(item.id)) {
      return fallback;
    }

    final imagesAsync = ref.watch(itemImagesProvider(item.id));
    return imagesAsync.when(
      loading: () => fallback,
      error: (_, _) => fallback,
      data: (images) {
        final image = _resolvePrimaryOrFirst(images);
        if (image == null) return fallback;
        return _ImageThumb(
          imageUrl: image.urlForGrid(),
          mediaAssetId: image.mediaAssetId,
          memCacheWidth: cacheWidth,
          fallback: fallback,
        );
      },
    );
  }

  ItemImageModel? _resolvePrimaryOrFirst(List<ItemImageModel> images) {
    if (images.isEmpty) return null;
    return images.where((image) => image.isPrimary).firstOrNull ??
        images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).firstOrNull;
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.imageUrl,
    required this.fallback,
    required this.memCacheWidth,
    this.mediaAssetId,
  });

  final String imageUrl;
  final String? mediaAssetId;
  final int memCacheWidth;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AppNetworkImage(
        imageUrl: imageUrl,
        sourceMediaAssetId: mediaAssetId,
        displayContext: ImageDisplayContext.grid,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: memCacheWidth,
        placeholder: fallback,
        errorWidget: fallback,
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.styleKey});

  final String styleKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        PosCategoryStyle.icon(styleKey),
        size: PosItemThumbnail._iconSize,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
    );
  }
}
