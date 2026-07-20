import 'dart:typed_data';

import 'package:billing_baba/core/storage/media_upload_client.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _itemImageAllowedMimes = {'image/png', 'image/jpeg', 'image/webp'};
const int _itemImageMaxBytes = 2 * 1024 * 1024;
const _maxGalleryImages = 20;
const _thumbSize = 88.0;

class ItemImageGallerySection extends ConsumerStatefulWidget {
  const ItemImageGallerySection({
    required this.itemId,
    this.label = 'Item Images',
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
  bool _isUploading = false;
  String? _replacingImageId;

  Future<({Uint8List bytes, String mimeType})?> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || file.bytes == null) return null;

    final mime = mimeTypeFromFilename(file.name);
    if (!isAllowedMime(mime, _itemImageAllowedMimes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type: ${file.name}')),
        );
      }
      return null;
    }

    if (file.bytes!.length > _itemImageMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be 2 MB or smaller')),
        );
      }
      return null;
    }

    return (bytes: file.bytes!, mimeType: mime);
  }

  Future<void> _upload({String? replacesImageId, bool isPrimary = false}) async {
    final picked = await _pickImage();
    if (picked == null) return;

    setState(() {
      _isUploading = true;
      _replacingImageId = replacesImageId;
    });

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.uploadItemImage(
        widget.itemId,
        bytes: picked.bytes,
        mimeType: picked.mimeType,
        isPrimary: isPrimary,
        replacesImageId: replacesImageId,
      );
      ref.invalidate(itemImagesProvider(widget.itemId));
      ref.invalidate(productDetailProvider(widget.itemId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _replacingImageId = null;
        });
      }
    }
  }

  Future<void> _deleteImage(ItemImageModel image) async {
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
    if (confirmed != true) return;

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItemImage(widget.itemId, image.id);
      ref.invalidate(itemImagesProvider(widget.itemId));
      ref.invalidate(productDetailProvider(widget.itemId));
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
    }
  }

  Future<void> _setPrimary(ItemImageModel image) async {
    if (image.isPrimary) return;

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.setPrimaryItemImage(widget.itemId, image.id);
      ref.invalidate(itemImagesProvider(widget.itemId));
      ref.invalidate(productDetailProvider(widget.itemId));
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not set primary: $error')),
        );
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final imagesAsync = ref.read(itemImagesProvider(widget.itemId));
    final images = imagesAsync.value;
    if (images == null) return;

    final reordered = List<ItemImageModel>.from(images);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.reorderItemImages(
        widget.itemId,
        reordered.map((img) => img.id).toList(),
      );
      ref.invalidate(itemImagesProvider(widget.itemId));
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reorder failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(itemImagesProvider(widget.itemId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (_isUploading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        imagesAsync.when(
          loading: () => const SizedBox(
            height: _thumbSize,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => Text(
            'Could not load images: $error',
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
          data: (images) {
            final sorted = List<ItemImageModel>.from(images)
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            if (sorted.isEmpty && !_isUploading) {
              return _AddImageTile(
                onTap: _isUploading ? null : () => _upload(isPrimary: true),
                label: 'Add primary image',
              );
            }

            return SizedBox(
              height: _thumbSize + 28,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: _onReorder,
                itemCount: sorted.length + (sorted.length < _maxGalleryImages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == sorted.length) {
                    return _AddImageTile(
                      key: const ValueKey('add-image'),
                      onTap: _isUploading ? null : _upload,
                      label: 'Add',
                    );
                  }

                  final image = sorted[index];
                  final isReplacing = _replacingImageId == image.id && _isUploading;

                  return _GalleryThumb(
                    key: ValueKey(image.id),
                    image: image,
                    index: index,
                    isUploading: isReplacing,
                    onSetPrimary: () => _setPrimary(image),
                    onReplace: () => _upload(replacesImageId: image.id),
                    onDelete: () => _deleteImage(image),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Drag to reorder · Tap star for primary · Long-press drag handle',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.image,
    required this.index,
    required this.isUploading,
    required this.onSetPrimary,
    required this.onReplace,
    required this.onDelete,
    super.key,
  });

  final ItemImageModel image;
  final int index;
  final bool isUploading;
  final VoidCallback onSetPrimary;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: AppRadius.smBorder,
                child: SizedBox(
                  width: _thumbSize,
                  height: _thumbSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(
                        imageUrl: image.imageUrl,
                        memCacheWidth: (_thumbSize * 2).round(),
                        placeholder: ColoredBox(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: ColoredBox(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                      if (isUploading)
                        ColoredBox(
                          color: Colors.white.withValues(alpha: 0.7),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (image.isPrimary)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => [
                    if (!image.isPrimary)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Text('Set as primary'),
                      ),
                    const PopupMenuItem(
                      value: 'replace',
                      child: Text('Replace'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'primary':
                        onSetPrimary();
                      case 'replace':
                        onReplace();
                      case 'delete':
                        onDelete();
                    }
                  },
                ),
              ),
            ],
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(LucideIcons.gripVertical, size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({
    required this.onTap,
    required this.label,
    super.key,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Container(
          width: _thumbSize,
          height: _thumbSize,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBDBDBD)),
            borderRadius: AppRadius.smBorder,
            color: Colors.grey.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.plus,
                size: 20,
                color: AppColors.primary.withValues(alpha: onTap == null ? 0.4 : 1),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: onTap == null ? 0.4 : 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
