import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/item_card.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_category_style.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// POS product thumbnail — primary inventory image with category icon fallback.
class PosItemThumbnail extends ConsumerWidget {
  const PosItemThumbnail({
    required this.item,
    super.key,
    this.size,
    this.iconSize,
  });

  final PosItem item;

  /// When set, constrains the thumb to a square of this size (e.g. cart rows).
  final double? size;

  /// Category icon size when no image is available. Defaults by [size].
  final double? iconSize;

  static const _defaultIconSize = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedSize = size;
    final resolvedIconSize =
        iconSize ??
        (resolvedSize != null ? resolvedSize * 0.5 : _defaultIconSize);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final layoutExtent = resolvedSize ?? ItemCard.imageHeight;
    final cacheWidth = (layoutExtent * dpr).round();
    final fallback = _CategoryIcon(
      styleKey: item.categoryStyleKey,
      iconSize: resolvedIconSize,
    );
    final directUrl = item.imageUrl?.trim();

    Widget thumb;
    if (directUrl != null && directUrl.isNotEmpty) {
      thumb = _ImageThumb(
        imageUrl: directUrl,
        mediaAssetId: item.imageMediaAssetId,
        memCacheWidth: cacheWidth,
        fallback: fallback,
      );
    } else if (!isServerBackedInventoryItemId(item.id)) {
      thumb = fallback;
    } else {
      final imagesAsync = ref.watch(itemImagesProvider(item.id));
      thumb = imagesAsync.when(
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

    if (resolvedSize == null) return thumb;
    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: ClipRRect(
        borderRadius: AppRadius.smBorder,
        child: ColoredBox(
          color: PosCategoryStyle.backgroundColor(item.categoryStyleKey),
          child: thumb,
        ),
      ),
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
        loadWhenVisible: false,
        placeholder: fallback,
        errorWidget: fallback,
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.styleKey,
    required this.iconSize,
  });

  final String styleKey;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        PosCategoryStyle.icon(styleKey),
        size: iconSize,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
    );
  }
}
