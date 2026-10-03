import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/rack_location_history_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:billing_baba/shared/media/rack_photo_stamp.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _rackPhotoAllowedMimes = {'image/png', 'image/jpeg', 'image/webp'};
const int _rackPhotoMaxBytes = 2 * 1024 * 1024;

/// Compact rack/shelf field with camera + history actions and optional employee log.
class RackShelfSection extends ConsumerStatefulWidget {
  const RackShelfSection({
    required this.locationController,
    required this.employeeController,
    required this.onLocationChanged,
    this.locationId,
    this.photoUrl,
    this.lastUpdatedAt,
    this.history = const [],
    this.onPhotoChanged,
    this.onHistoryRefresh,
    this.pendingPhotoBytes,
    this.onPendingPhotoChanged,
    super.key,
  });

  final TextEditingController locationController;
  final TextEditingController employeeController;
  final ValueChanged<String> onLocationChanged;
  final String? locationId;
  final String? photoUrl;
  final DateTime? lastUpdatedAt;
  final List<ItemLocationHistoryModel> history;
  final ValueChanged<String?>? onPhotoChanged;
  final VoidCallback? onHistoryRefresh;
  final Uint8List? pendingPhotoBytes;
  final ValueChanged<Uint8List?>? onPendingPhotoChanged;

  @override
  ConsumerState<RackShelfSection> createState() => _RackShelfSectionState();
}

class _RackShelfSectionState extends ConsumerState<RackShelfSection> {
  bool _isUploading = false;
  String? _photoUrl;
  bool _sectionExpanded = false;
  bool _logEmployee = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
    _logEmployee = widget.employeeController.text.trim().isNotEmpty;
    _sectionExpanded =
        _logEmployee ||
        widget.locationId != null ||
        widget.locationController.text.trim().isNotEmpty;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant RackShelfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _photoUrl = widget.photoUrl;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _sectionExpanded = true);
    }
  }

  void _activateSection() {
    setState(() => _sectionExpanded = true);
  }

  Future<({Uint8List bytes, String mimeType})?> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );

    final file = result?.files.single;
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final mime = mimeTypeFromFilename(file.name);
    if (!isAllowedMime(mime, _rackPhotoAllowedMimes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type: ${file.name}')),
        );
      }
      return null;
    }

    if (bytes.length > _rackPhotoMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be 2 MB or smaller')),
        );
      }
      return null;
    }

    return (bytes: bytes, mimeType: mime);
  }

  Future<void> _upload() async {
    final picked = await _pickImage();
    if (picked == null) return;

    final locationId = widget.locationId;
    if (locationId == null) {
      // Keep raw bytes; stamp with latest rack/employee labels on save/upload.
      widget.onPendingPhotoChanged?.call(picked.bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo will upload when you save the item.'),
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    final previousUrl = _photoUrl;
    final employee = _logEmployee ? widget.employeeController.text.trim() : '';
    try {
      final stamped = await stampRackPhoto(
        bytes: picked.bytes,
        takenAt: DateTime.now(),
        rackShelfLabel: widget.locationController.text,
        employeeLabel: employee.isEmpty ? null : employee,
      );
      final service = await ref.read(inventoryServiceProvider.future);
      final url = await service.uploadRackPhoto(
        locationId: locationId,
        bytes: stamped.bytes,
        mimeType: stamped.mimeType,
        employeeLabel: employee.isEmpty ? null : employee,
      );
      setState(() => _photoUrl = url);
      widget.onPhotoChanged?.call(url);
      widget.onHistoryRefresh?.call();
      unawaited(
        ref
            .read(imageServiceProvider)
            .replaceImage(
              oldUrl: previousUrl,
              newUrl: url,
              oldCacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
              newCacheKey: buildImageCacheKey(fallbackUrl: url),
            ),
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto() async {
    final locationId = widget.locationId;
    if (locationId == null) {
      widget.onPendingPhotoChanged?.call(null);
      return;
    }

    setState(() => _isUploading = true);
    final previousUrl = _photoUrl;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteRackPhoto(locationId);
      setState(() => _photoUrl = null);
      widget.onPhotoChanged?.call(null);
      unawaited(
        ref
            .read(imageServiceProvider)
            .invalidateImage(
              url: previousUrl,
              cacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
            ),
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _onCameraPressed() async {
    _activateSection();
    final hasPending = widget.pendingPhotoBytes != null;
    final hasRemote = _photoUrl != null && _photoUrl!.isNotEmpty;

    if (hasPending || hasRemote) {
      await _showPhotoActions();
      return;
    }
    await _upload();
  }

  Future<void> _showPhotoActions() async {
    final hasPending = widget.pendingPhotoBytes != null;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rack / Shelf photo'),
        content: SizedBox(
          width: 280,
          child: hasPending
              ? const Text(
                  'A photo is ready and will upload when you save the item.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              : _photoUrl != null
              ? AppNetworkImage(imageUrl: _photoUrl!, height: 160)
              : const SizedBox.shrink(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              unawaited(_upload());
            },
            child: const Text('Replace'),
          ),
          if (hasPending || _photoUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                unawaited(_deletePhoto());
              },
              child: const Text('Remove'),
            ),
        ],
      ),
    );
  }

  void _openHistory() {
    _activateSection();
    if (widget.locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save the item to view rack/shelf history.'),
        ),
      );
      return;
    }
    unawaited(showRackLocationHistoryDialog(context, history: widget.history));
  }

  Widget _rackSuffixIcons() {
    final hasPhoto =
        widget.pendingPhotoBytes != null ||
        (_photoUrl != null && _photoUrl!.isNotEmpty);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Rack / shelf photo',
          onPressed: _isUploading ? null : () => unawaited(_onCameraPressed()),
          icon: Icon(
            LucideIcons.camera,
            size: 18,
            color: hasPhoto ? AppColors.primary : null,
          ),
        ),
        IconButton(
          tooltip: 'Rack / shelf history',
          onPressed: _openHistory,
          icon: const Icon(LucideIcons.clock, size: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Rack / Shelf',
          floatingLabel: true,
          child: TextField(
            controller: widget.locationController,
            focusNode: _focusNode,
            style: saleFieldTextStyle,
            decoration: buildFormControlDecoration(
              labelText: 'Rack / Shelf',
              suffix: _rackSuffixIcons(),
            ),
            onTap: _activateSection,
            onChanged: widget.onLocationChanged,
          ),
        ),
        if (_sectionExpanded) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: _logEmployee,
                onChanged: (value) {
                  setState(() {
                    _logEmployee = value;
                    if (!value) widget.employeeController.clear();
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Record employee for this update',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (_logEmployee) ...[
            const SizedBox(height: 4),
            TextField(
              controller: widget.employeeController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(
                labelText: 'Employee name or ID',
              ),
            ),
          ],
          if (widget.lastUpdatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last updated: ${dateFormat.format(widget.lastUpdatedAt!)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
