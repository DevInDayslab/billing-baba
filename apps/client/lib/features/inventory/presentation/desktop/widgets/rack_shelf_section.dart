import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/rack_location_history_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart' show
    buildImageCacheKey,
    coalesceStorageMediaAssetId,
    extractMediaAssetIdFromUrl,
    stripUrlQuery;
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:billing_baba/shared/media/prepare_media_upload_bytes.dart';
import 'package:billing_baba/shared/media/rack_photo_stamp.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:billing_baba/shared/widgets/transaction_success_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _rackPhotoAllowedMimes = {'image/png', 'image/jpeg', 'image/webp'};
const int _rackPhotoMaxBytes = 2 * 1024 * 1024;
/// Matches server retention ([InventoryService.rackLocationHistoryLimit]).
const int _maxRackLocationHistory = 5;
const double _rackListThumbSize = 100;

class _RackGalleryPhoto {
  const _RackGalleryPhoto({
    this.url,
    this.mediaAssetId,
    this.bytes,
    this.isPending = false,
    this.createdAt,
    this.rackLabel,
    this.employeeLabel,
  });

  final String? url;
  final String? mediaAssetId;
  final Uint8List? bytes;
  final bool isPending;
  final DateTime? createdAt;
  final String? rackLabel;
  final String? employeeLabel;
}

/// True when saving should sync rack/shelf (location, photo, or employee log).
bool rackShelfHasPendingWork({
  required String rack,
  required String initialRack,
  required String employee,
  required Uint8List? pendingPhoto,
  String? locationId,
}) {
  if (pendingPhoto != null) return true;
  final rackChanged = rack != initialRack;
  if (rackChanged) return true;
  if (locationId == null && rack.isNotEmpty) return true;
  return false;
}

String? validateRackShelfEmployee({
  required String rack,
  required String initialRack,
  required String employee,
  required Uint8List? pendingPhoto,
  String? locationId,
}) {
  if (pendingPhoto != null) {
    if (rack.trim().isEmpty) {
      return 'Rack is required before uploading a photo.';
    }
    if (employee.trim().isEmpty) {
      return 'Employee name or ID is required before uploading a rack photo.';
    }
  }
  if (!rackShelfHasPendingWork(
    rack: rack,
    initialRack: initialRack,
    employee: employee,
    pendingPhoto: pendingPhoto,
    locationId: locationId,
  )) {
    return null;
  }
  return null;
}

/// Compact rack/shelf field with camera + history actions and optional employee log.
class RackShelfSection extends ConsumerStatefulWidget {
  const RackShelfSection({
    required this.locationController,
    required this.employeeController,
    required this.onLocationChanged,
    this.locationId,
    this.photoUrl,
    this.photoTakenAt,
    this.lastUpdatedAt,
    this.history = const [],
    this.onPhotoChanged,
    this.onHistoryRefresh,
    this.pendingPhotoBytes,
    this.onPendingPhotoChanged,
    this.pendingRawPhotoBytes,
    this.onPendingRawPhotoChanged,
    this.initialRackLocation = '',
    this.employeeError,
    this.onEmployeeChanged,
    this.onRackPhotoUploaded,
    this.onRackLocationSynced,
    super.key,
  });

  final TextEditingController locationController;
  final TextEditingController employeeController;
  final ValueChanged<String> onLocationChanged;
  final String? locationId;
  final String? photoUrl;
  final DateTime? photoTakenAt;
  final DateTime? lastUpdatedAt;
  final List<ItemLocationHistoryModel> history;
  final void Function(String? url, DateTime? takenAt)? onPhotoChanged;
  final Future<void> Function()? onHistoryRefresh;
  final Uint8List? pendingPhotoBytes;
  final ValueChanged<Uint8List?>? onPendingPhotoChanged;
  final Uint8List? pendingRawPhotoBytes;
  final ValueChanged<Uint8List?>? onPendingRawPhotoChanged;
  final String initialRackLocation;
  final String? employeeError;
  final VoidCallback? onEmployeeChanged;
  final VoidCallback? onRackPhotoUploaded;
  final ValueChanged<String>? onRackLocationSynced;

  @override
  ConsumerState<RackShelfSection> createState() => _RackShelfSectionState();
}

class _RackShelfSectionState extends ConsumerState<RackShelfSection> {
  bool _isUploading = false;
  String? _photoUrl;
  bool _sectionExpanded = false;
  bool _logEmployee = false;
  Uint8List? _lastPickedRawBytes;
  Timer? _stampRefreshDebounce;
  DateTime? _previewStampedAt;
  String? _historyRefreshForLocationId;
  final _focusNode = FocusNode();

  void _requestHistoryRefreshIfNeeded() {
    final locationId = widget.locationId;
    if (locationId == null || widget.onHistoryRefresh == null) return;
    if (_historyRefreshForLocationId == locationId) return;
    _historyRefreshForLocationId = locationId;
    unawaited(widget.onHistoryRefresh!());
  }

  String? _rackPhotoIdentity({String? url, String? mediaAssetId}) {
    final id = mediaAssetId?.trim();
    if (id != null && id.isNotEmpty) return id;
    return extractMediaAssetIdFromUrl(url) ?? stripUrlQuery(url);
  }

  @override
  void initState() {
    super.initState();
    _lastPickedRawBytes = widget.pendingRawPhotoBytes;
    _photoUrl = widget.photoUrl;
    _logEmployee =
        widget.employeeController.text.trim().isNotEmpty ||
        widget.pendingPhotoBytes != null ||
        (widget.photoUrl != null && widget.photoUrl!.isNotEmpty);
    _sectionExpanded =
        _logEmployee ||
        widget.locationId != null ||
        widget.locationController.text.trim().isNotEmpty ||
        widget.pendingPhotoBytes != null ||
        widget.history.isNotEmpty;
    _focusNode.addListener(_onFocusChange);
    if (widget.history.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestHistoryRefreshIfNeeded();
      });
    }
  }

  @override
  void didUpdateWidget(covariant RackShelfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locationId != oldWidget.locationId) {
      _historyRefreshForLocationId = null;
      if (widget.history.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _requestHistoryRefreshIfNeeded();
        });
      }
    }
    if (widget.photoUrl != oldWidget.photoUrl) {
      _photoUrl = widget.photoUrl;
    }
    if (widget.pendingPhotoBytes != oldWidget.pendingPhotoBytes &&
        widget.pendingPhotoBytes != null) {
      _sectionExpanded = true;
      _logEmployee = true;
    }
    if (widget.pendingRawPhotoBytes != oldWidget.pendingRawPhotoBytes) {
      _lastPickedRawBytes = widget.pendingRawPhotoBytes;
    }
  }

  @override
  void dispose() {
    _stampRefreshDebounce?.cancel();
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

  bool _ensureReadyForPhotoUpload() {
    setState(() => _sectionExpanded = true);
    final rack = widget.locationController.text.trim();
    if (rack.isEmpty) {
      showOverlaySnackBar(
        context,
        message: 'Enter rack name before adding a photo.',
      );
      return false;
    }
    if (widget.employeeController.text.trim().isEmpty) {
      showOverlaySnackBar(
        context,
        message: 'Enter employee name or ID before adding a photo.',
      );
      return false;
    }
    return true;
  }

  bool _hasActiveRackPhoto() {
    return widget.pendingPhotoBytes != null ||
        (_photoUrl != null && _photoUrl!.trim().isNotEmpty);
  }

  _RackGalleryPhoto? _pendingUploadPreview() {
    final bytes = widget.pendingPhotoBytes;
    if (bytes == null) return null;
    final employee = widget.employeeController.text.trim();
    final rack = widget.locationController.text.trim();
    return _RackGalleryPhoto(
      bytes: bytes,
      isPending: true,
      createdAt: _previewStampedAt,
      rackLabel: rack.isEmpty ? null : rack,
      employeeLabel: employee.isEmpty ? null : employee,
    );
  }

  List<_RackGalleryPhoto> _readonlyHistoryPhotos() {
    final sortedHistory = [...widget.history]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final seenKeys = <String>{};
    final photos = <_RackGalleryPhoto>[];

    for (final entry in sortedHistory) {
      if (photos.length >= _maxRackLocationHistory) break;
      final url = entry.photoUrl?.trim();
      if (url == null || url.isEmpty) continue;
      final mediaAssetId = coalesceStorageMediaAssetId(
        storedMediaAssetId: entry.photoMediaAssetId,
        imageUrl: url,
      );
      final key = _rackPhotoIdentity(
        url: url,
        mediaAssetId: mediaAssetId,
      );
      if (key == null || key.isEmpty || !seenKeys.add(key)) continue;

      final rackOnly = entry.rack?.trim();
      photos.add(
        _RackGalleryPhoto(
          url: url,
          mediaAssetId: mediaAssetId,
          createdAt: entry.createdAt,
          rackLabel: (rackOnly == null || rackOnly.isEmpty) ? null : rackOnly,
          employeeLabel: entry.employeeLabel,
        ),
      );
    }
    return photos;
  }

  void _scheduleStampPreviewRefresh() {
    _stampRefreshDebounce?.cancel();
    _stampRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_refreshStampPreview());
    });
  }

  Future<void> _refreshStampPreview() async {
    final raw = _lastPickedRawBytes;
    if (raw == null || widget.locationId != null) return;

    final stamped = await _stampBytes(raw);
    if (!mounted) return;
    widget.onPendingPhotoChanged?.call(stamped.bytes);
    setState(() {});
  }

  Future<({Uint8List bytes, String mimeType})> _stampBytes(Uint8List raw) {
    final employee = widget.employeeController.text.trim();
    final takenAt = DateTime.now();
    _previewStampedAt = takenAt;
    return stampRackPhoto(
      bytes: raw,
      takenAt: takenAt,
      rackShelfLabel: widget.locationController.text,
      employeeLabel: employee.isEmpty ? null : employee,
    );
  }

  Future<void> _viewRackPhoto(_RackGalleryPhoto photo) async {
    final imageKey = photo.bytes != null
        ? ValueKey(photo.bytes.hashCode)
        : ValueKey(photo.url);
    const dialogWidth = 400.0;
    const imageHeight = 280.0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        photo.isPending
                            ? 'New rack photo'
                            : 'Rack photo (view only)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: ColoredBox(
                    color: const Color(0xFFF5F5F5),
                    child: SizedBox(
                      width: dialogWidth - AppSpacing.md * 2,
                      height: imageHeight,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4,
                        child: photo.bytes != null
                            ? Image.memory(
                                photo.bytes!,
                                key: imageKey,
                                fit: BoxFit.contain,
                              )
                            : AppNetworkImage(
                                imageUrl: photo.url!,
                                sourceMediaAssetId: photo.mediaAssetId,
                                displayContext: ImageDisplayContext.zoom,
                                fit: BoxFit.contain,
                                loadWhenVisible: false,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (photo.isPending)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Text(
                    widget.locationId == null
                        ? 'This stamped preview uploads when you save the item.'
                        : _isUploading
                        ? 'Uploading stamped photo to your business storage…'
                        : 'Stamped with rack, employee, and time on this device.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    0,
                  ),
                  child: Text(
                    'Past rack photos are read-only. Add a new photo to record another update.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRackAuditGallery() {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    if (widget.locationId == null) {
      return const Text(
        'Save the item to track rack photos (last 5 updates).',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );
    }

    final pending = _pendingUploadPreview();
    final historyPhotos = _readonlyHistoryPhotos();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Add rack photo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (_isUploading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _canStartPhotoUpload()
              ? 'Fill rack and employee above, then tap New. Date and time are stamped on the image before upload.'
              : 'Enter rack name and who is updating (employee name or ID) to enable photo upload.',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        if (pending != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _RackAuditTile(
                photo: pending,
                showLatestBadge: false,
                showUploading: _isUploading,
                dateFormat: dateFormat,
                captionPrefix: 'Preview',
                onTap: _isUploading
                    ? null
                    : () => unawaited(_viewRackPhoto(pending)),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Recent rack photos (last 5)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < historyPhotos.length; i++)
              _RackAuditTile(
                photo: historyPhotos[i],
                showLatestBadge: i == 0,
                dateFormat: dateFormat,
                onTap: () => unawaited(_viewRackPhoto(historyPhotos[i])),
              ),
            if (_canStartPhotoUpload())
              _RackUploadTile(
                onTap: _isUploading
                    ? null
                    : () => unawaited(_onCameraPressed()),
              ),
          ],
        ),
        if (historyPhotos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _canStartPhotoUpload()
                  ? 'No rack photos yet. Tap New to add one (last five are kept, read-only).'
                  : 'No rack photos yet. Your last five uploads will appear here (read-only).',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
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
        showOverlaySnackBar(
          context,
          message: 'Unsupported file type: ${file.name}',
        );
      }
      return null;
    }

    if (bytes.length > _rackPhotoMaxBytes) {
      if (mounted) {
        showOverlaySnackBar(
          context,
          message: 'Image must be 2 MB or smaller',
        );
      }
      return null;
    }

    return (bytes: bytes, mimeType: mime);
  }

  Future<void> _upload() async {
    if (_isUploading) return;
    if (!_ensureReadyForPhotoUpload()) return;

    final picked = await _pickImage();
    if (picked == null) return;

    _lastPickedRawBytes = picked.bytes;
    widget.onPendingRawPhotoChanged?.call(picked.bytes);
    if (mounted) {
      setState(() => _isUploading = true);
    }
    unawaited(_processAndUploadRackPhoto(picked));
  }

  Future<void> _processAndUploadRackPhoto(
    ({Uint8List bytes, String mimeType}) picked,
  ) async {
    try {
      final stamped = await _stampBytes(picked.bytes);
      final prepared = await prepareMediaUploadBytes(
        bytes: stamped.bytes,
        mimeType: stamped.mimeType,
      );

      if (!mounted) return;
      widget.onPendingPhotoChanged?.call(prepared.bytes);
      setState(() {});

      final locationId = widget.locationId;
      if (locationId == null) {
        return;
      }

      final rack = widget.locationController.text.trim();
      final service = await ref.read(inventoryServiceProvider.future);
      if (rack != widget.initialRackLocation) {
        await service.updateItemLocation(
          locationId,
          rack: rack.isEmpty ? '' : rack,
        );
        widget.onRackLocationSynced?.call(rack);
      }

      final previousUrl = _photoUrl;
      final employee = widget.employeeController.text.trim();
      final upload = await service.uploadRackPhoto(
        locationId: locationId,
        bytes: prepared.bytes,
        mimeType: prepared.mimeType,
        employeeLabel: employee.isEmpty ? null : employee,
      );
      if (!mounted) return;
      final takenAt = upload.takenAt ?? DateTime.now();
      widget.onPendingPhotoChanged?.call(null);
      setState(() {
        _photoUrl = upload.url;
        _previewStampedAt = takenAt;
      });
      widget.onPhotoChanged?.call(upload.url, takenAt);
      widget.onRackPhotoUploaded?.call();
      unawaited(widget.onHistoryRefresh?.call());
      unawaited(
        ref
            .read(imageServiceProvider)
            .replaceImage(
              oldUrl: previousUrl,
              newUrl: upload.url,
              oldCacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
              newCacheKey: buildImageCacheKey(fallbackUrl: upload.url),
            ),
      );
    } on Exception catch (error) {
      if (mounted) {
        widget.onPendingPhotoChanged?.call(null);
        showOverlaySnackBar(context, message: 'Upload failed: $error');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _onCameraPressed() async {
    _activateSection();
    await _upload();
  }

  void _openHistory() {
    _activateSection();
    if (widget.locationId == null) {
      showOverlaySnackBar(
        context,
        message: 'Save the item to view rack history.',
      );
      return;
    }
    unawaited(showRackLocationHistoryDialog(context, history: widget.history));
  }

  Widget _rackSuffixIcons() {
    return IconButton(
      tooltip: 'Location update history',
      onPressed: _openHistory,
      icon: const Icon(LucideIcons.clock, size: 18),
    );
  }

  bool _canStartPhotoUpload() {
    return widget.locationController.text.trim().isNotEmpty &&
        widget.employeeController.text.trim().isNotEmpty;
  }

  Widget _buildEmployeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Employee name or ID *',
          floatingLabel: true,
          child: TextField(
            controller: widget.employeeController,
            style: saleFieldTextStyle,
            decoration: buildFormControlDecoration(
              labelText: 'Employee name or ID *',
              hasError: widget.employeeError != null,
            ),
            onTap: _activateSection,
            onChanged: (_) {
              widget.onEmployeeChanged?.call();
              _scheduleStampPreviewRefresh();
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Required for each new rack photo (stored on the stamped image).',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        if (widget.employeeError != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.employeeError!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showEmployee =
        widget.locationId != null ||
        _sectionExpanded ||
        _hasActiveRackPhoto() ||
        widget.history.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFormField(
          label: 'Rack *',
          floatingLabel: true,
          child: TextField(
            controller: widget.locationController,
            focusNode: _focusNode,
            style: saleFieldTextStyle,
            decoration: buildFormControlDecoration(
              labelText: 'Rack *',
              suffix: _rackSuffixIcons(),
            ),
            onTap: _activateSection,
            onChanged: (value) {
              if (value.trim() != widget.initialRackLocation) {
                setState(() {
                  _logEmployee = true;
                  _sectionExpanded = true;
                });
              }
              widget.onLocationChanged(value);
              _scheduleStampPreviewRefresh();
              setState(() {});
            },
          ),
        ),
        if (showEmployee) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildEmployeeField(),
        ],
        if (widget.locationId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRackAuditGallery(),
        ],
      ],
    );
  }
}

/// Fast list thumb — uses source/staging URL (rack uploads have no variants).
class _RackShelfThumbImage extends StatelessWidget {
  const _RackShelfThumbImage({required this.photo});

  final _RackGalleryPhoto photo;
  static const double size = _rackListThumbSize;

  @override
  Widget build(BuildContext context) {
    if (photo.bytes != null) {
      return Image.memory(
        photo.bytes!,
        key: ValueKey(photo.bytes.hashCode),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
    final url = photo.url?.trim();
    if (url == null || url.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFF0F0F0),
        child: Icon(LucideIcons.imageOff, color: AppColors.textSecondary),
      );
    }
    return AppNetworkImage(
      imageUrl: url,
      sourceMediaAssetId: photo.mediaAssetId,
      width: _RackShelfThumbImage.size,
      height: _RackShelfThumbImage.size,
      memCacheWidth: 200,
      loadWhenVisible: false,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );
  }
}

class _RackUploadTile extends StatelessWidget {
  const _RackUploadTile({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _rackListThumbSize + 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.35),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: _rackListThumbSize + 8,
                height: _rackListThumbSize + 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.camera,
                      size: 28,
                      color: onTap == null
                          ? AppColors.textSecondary.withValues(alpha: 0.4)
                          : AppColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'New',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: onTap == null
                            ? AppColors.textSecondary.withValues(alpha: 0.4)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload update',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RackAuditTile extends StatelessWidget {
  const _RackAuditTile({
    required this.photo,
    required this.showLatestBadge,
    required this.dateFormat,
    required this.onTap,
    this.showUploading = false,
    this.captionPrefix,
  });

  final _RackGalleryPhoto photo;
  final bool showLatestBadge;
  final bool showUploading;
  final DateFormat dateFormat;
  final VoidCallback? onTap;
  final String? captionPrefix;

  @override
  Widget build(BuildContext context) {
    final when = photo.createdAt != null
        ? dateFormat.format(photo.createdAt!.toLocal())
        : '—';
    final who = photo.employeeLabel?.trim();
    final where = photo.rackLabel?.trim();

    return SizedBox(
      width: _rackListThumbSize + 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  SizedBox(
                    width: _rackListThumbSize + 8,
                    height: _rackListThumbSize + 8,
                    child: Center(
                      child: _RackShelfThumbImage(photo: photo),
                    ),
                  ),
                  if (showLatestBadge && !showUploading)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Latest',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showUploading)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (captionPrefix != null)
            Text(
              captionPrefix!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          Text(
            when,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          if (where != null && where.isNotEmpty)
            Text(
              where,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          if (who != null && who.isNotEmpty)
            Text(
              who,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
