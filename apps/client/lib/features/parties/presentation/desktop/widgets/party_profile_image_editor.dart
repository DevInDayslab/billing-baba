import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_optimistic_profile_images_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/data/party_profile_image_repository.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:billing_baba/shared/widgets/optimistic_media_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Party profile photo editor — same optimistic flow as Business Logo.
///
/// 1. Paint local preview immediately
/// 2. Upload in the background
/// 3. Keep local bytes (no flicker to network)
/// 4. On failure, restore previous image + snackbar
class PartyProfileImageEditor extends ConsumerStatefulWidget {
  const PartyProfileImageEditor({
    required this.partyName,
    required this.seed,
    this.partyId,
    this.initialImageUrl,
    this.initialMediaAssetId,
    this.onChanged,
    this.size = 96,
    super.key,
  });

  final String? partyId;
  final String partyName;
  final String seed;
  final String? initialImageUrl;
  final String? initialMediaAssetId;
  final double size;

  final void Function({
    required String? imageUrl,
    required String? mediaAssetId,
  })?
  onChanged;

  @override
  ConsumerState<PartyProfileImageEditor> createState() =>
      PartyProfileImageEditorState();
}

class PartyProfileImageEditorState
    extends ConsumerState<PartyProfileImageEditor> {
  PartyProfileImageRepository? _repository;
  String? _imageUrl;
  String? _mediaAssetId;
  Uint8List? _optimisticBytes;
  Uint8List? _pendingUploadBytes;
  String? _pendingMimeType;
  bool _uploading = false;
  var _uploadGeneration = 0;
  Completer<void>? _inFlight;

  bool get hasPendingUpload =>
      _pendingUploadBytes != null && _pendingUploadBytes!.isNotEmpty;

  bool get isBusy => _uploading || (_inFlight?.isCompleted == false);

  String? get imageUrl => _imageUrl;
  String? get mediaAssetId => _mediaAssetId;

  Future<void> waitForIdle() async {
    final inFlight = _inFlight;
    if (inFlight != null && !inFlight.isCompleted) {
      await inFlight.future;
    }
  }

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
    _mediaAssetId = widget.initialMediaAssetId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initRepository());
  }

  @override
  void didUpdateWidget(covariant PartyProfileImageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Match business profile: never clobber an active local preview.
    if (_uploading || _optimisticBytes != null) return;
    if (oldWidget.initialImageUrl != widget.initialImageUrl) {
      _imageUrl = widget.initialImageUrl;
    }
    if (oldWidget.initialMediaAssetId != widget.initialMediaAssetId) {
      _mediaAssetId = widget.initialMediaAssetId;
    }
  }

  Future<void> _initRepository() async {
    final api = await ref.read(apiClientProvider.future);
    if (!mounted) return;
    setState(() => _repository = PartyProfileImageRepository(api.dio));
  }

  void _notifyChanged() {
    widget.onChanged?.call(
      imageUrl: _imageUrl,
      mediaAssetId: _mediaAssetId,
    );
  }

  void _setSharedOptimistic(String? partyId, Uint8List? bytes) {
    if (partyId == null || partyId.isEmpty) return;
    final notifier = ref.read(partyOptimisticProfileImagesProvider.notifier);
    if (bytes == null || bytes.isEmpty) {
      notifier.clear(partyId);
    } else {
      notifier.setBytes(partyId, bytes);
    }
  }

  void _patchProviders({
    required String partyId,
    required String? imageUrl,
    required String? mediaAssetId,
    bool clear = false,
  }) {
    try {
      ref
          .read(partyListProvider.notifier)
          .patchProfileImage(
            partyId,
            profileImageUrl: imageUrl,
            profileMediaAssetId: mediaAssetId,
            clear: clear,
          );
    } on Object {
      // Scope may already be gone after dialog dismiss.
    }
  }

  Completer<void> _beginInFlight() {
    final previous = _inFlight;
    if (previous != null && !previous.isCompleted) {
      previous.complete();
    }
    final completer = Completer<void>();
    _inFlight = completer;
    return completer;
  }

  void _endInFlight(Completer<void> completer) {
    if (!completer.isCompleted) completer.complete();
    if (identical(_inFlight, completer)) _inFlight = null;
  }

  Future<void> flushPendingUpload(String partyId) async {
    final bytes = _pendingUploadBytes;
    final mime = _pendingMimeType;
    if (bytes == null || mime == null) return;

    // Promote create-flow preview into the shared optimistic map for the new id.
    if (_optimisticBytes != null) {
      _setSharedOptimistic(partyId, _optimisticBytes);
    }

    await _performUpload(partyId: partyId, bytes: bytes, mimeType: mime);
    _pendingUploadBytes = null;
    _pendingMimeType = null;
    if (mounted) setState(() {});
  }

  Future<void> _onReplace() async {
    final repoReady = _repository != null || widget.partyId == null;
    if (!repoReady) {
      await _initRepository();
    }

    final picked = await pickAndPrepareMediaImage(context: context);
    if (picked == null || !mounted) return;

    final generation = ++_uploadGeneration;
    final previousUrl = _imageUrl;
    final previousMediaId = _mediaAssetId;
    final partyId = widget.partyId;
    final completer = _beginInFlight();

    // Paint local preview immediately — same as Business Logo.
    setState(() {
      _optimisticBytes = picked.previewBytes;
      _uploading = true;
    });
    _setSharedOptimistic(partyId, picked.previewBytes);

    if (partyId == null || partyId.isEmpty) {
      setState(() {
        _pendingUploadBytes = picked.bytes;
        _pendingMimeType = picked.mimeType;
        _uploading = false;
      });
      _endInFlight(completer);
      return;
    }

    try {
      if (_repository == null) {
        final api = await ref.read(apiClientProvider.future);
        _repository = PartyProfileImageRepository(api.dio);
      }
      if (!mounted || _uploadGeneration != generation) return;

      final upload = await _repository!.uploadProfileImage(
        partyId: partyId,
        bytes: picked.bytes,
        mimeType: picked.mimeType,
      );
      if (_uploadGeneration != generation) return;

      final newUrl = upload['url'] as String?;
      final newMediaId = upload['media_asset_id'] as String?;

      // Keep optimistic bytes (business logo pattern) — no network flicker.
      _imageUrl = newUrl;
      _mediaAssetId = newMediaId;
      _uploading = false;
      _notifyChanged();
      _patchProviders(
        partyId: partyId,
        imageUrl: newUrl,
        mediaAssetId: newMediaId,
      );
      if (mounted) setState(() {});

      unawaited(
        ref
            .read(imageServiceProvider)
            .replaceImage(
              oldUrl: previousUrl,
              newUrl: newUrl,
              oldCacheKey: buildImageCacheKey(
                mediaAssetId: previousMediaId,
                fallbackUrl: previousUrl,
              ),
              newCacheKey: buildImageCacheKey(
                mediaAssetId: newMediaId,
                fallbackUrl: newUrl,
              ),
              mediaAssetId: previousMediaId,
            ),
      );
    } on Exception catch (e) {
      if (_uploadGeneration != generation) return;
      _optimisticBytes = null;
      _imageUrl = previousUrl;
      _mediaAssetId = previousMediaId;
      _uploading = false;
      _setSharedOptimistic(partyId, null);
      _notifyChanged();
      _patchProviders(
        partyId: partyId,
        imageUrl: previousUrl,
        mediaAssetId: previousMediaId,
        clear: previousUrl == null && previousMediaId == null,
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      _endInFlight(completer);
    }
  }

  Future<void> _performUpload({
    required String partyId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (_repository == null) {
      final api = await ref.read(apiClientProvider.future);
      _repository = PartyProfileImageRepository(api.dio);
    }
    final previousUrl = _imageUrl;
    final previousMediaId = _mediaAssetId;
    final generation = ++_uploadGeneration;

    if (mounted) setState(() => _uploading = true);

    final upload = await _repository!.uploadProfileImage(
      partyId: partyId,
      bytes: bytes,
      mimeType: mimeType,
    );
    if (_uploadGeneration != generation) return;

    final newUrl = upload['url'] as String?;
    final newMediaId = upload['media_asset_id'] as String?;
    _imageUrl = newUrl;
    _mediaAssetId = newMediaId;
    _uploading = false;
    _notifyChanged();
    _patchProviders(
      partyId: partyId,
      imageUrl: newUrl,
      mediaAssetId: newMediaId,
    );
    if (mounted) setState(() {});

    unawaited(
      ref
          .read(imageServiceProvider)
          .replaceImage(
            oldUrl: previousUrl,
            newUrl: newUrl,
            oldCacheKey: buildImageCacheKey(
              mediaAssetId: previousMediaId,
              fallbackUrl: previousUrl,
            ),
            newCacheKey: buildImageCacheKey(
              mediaAssetId: newMediaId,
              fallbackUrl: newUrl,
            ),
            mediaAssetId: previousMediaId,
          ),
    );
  }

  Future<void> _onRemove() async {
    final generation = ++_uploadGeneration;
    final previousUrl = _imageUrl;
    final previousMediaId = _mediaAssetId;
    final partyId = widget.partyId;
    final completer = _beginInFlight();

    setState(() {
      _optimisticBytes = null;
      _pendingUploadBytes = null;
      _pendingMimeType = null;
      _imageUrl = null;
      _mediaAssetId = null;
      _uploading = true;
    });
    _setSharedOptimistic(partyId, null);
    _notifyChanged();
    if (partyId != null && partyId.isNotEmpty) {
      _patchProviders(
        partyId: partyId,
        imageUrl: null,
        mediaAssetId: null,
        clear: true,
      );
    }

    if (partyId == null || partyId.isEmpty) {
      if (mounted) setState(() => _uploading = false);
      _endInFlight(completer);
      return;
    }

    try {
      if (_repository == null) {
        final api = await ref.read(apiClientProvider.future);
        _repository = PartyProfileImageRepository(api.dio);
      }
      await _repository!.deleteProfileImage(partyId);
      if (_uploadGeneration != generation) return;
      _uploading = false;
      if (mounted) setState(() {});
      unawaited(
        ref
            .read(imageServiceProvider)
            .invalidateImage(
              url: previousUrl,
              cacheKey: buildImageCacheKey(
                mediaAssetId: previousMediaId,
                fallbackUrl: previousUrl,
              ),
              mediaAssetId: previousMediaId,
            ),
      );
    } on Exception catch (e) {
      if (_uploadGeneration != generation) return;
      _imageUrl = previousUrl;
      _mediaAssetId = previousMediaId;
      _uploading = false;
      _notifyChanged();
      _patchProviders(
        partyId: partyId,
        imageUrl: previousUrl,
        mediaAssetId: previousMediaId,
        clear: previousUrl == null && previousMediaId == null,
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Remove failed: $e')),
        );
      }
    } finally {
      _endInFlight(completer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.partyName.trim().isEmpty
        ? 'Party'
        : widget.partyName.trim();

    return OptimisticMediaUploader(
      label: 'Photo',
      size: widget.size,
      imageUrl: _imageUrl,
      optimisticBytes: _optimisticBytes,
      isUploading: _uploading,
      replaceLabel: 'Edit Photo',
      removeLabel: 'Remove Photo',
      fit: BoxFit.cover,
      placeholder: PartyAvatar(
        name: displayName,
        seed: widget.seed,
        diameter: widget.size,
        partyId: widget.partyId,
      ),
      onReplace: _onReplace,
      onRemove:
          (_imageUrl != null && _imageUrl!.trim().isNotEmpty) ||
              (_optimisticBytes != null && _optimisticBytes!.isNotEmpty)
          ? _onRemove
          : null,
    );
  }
}
