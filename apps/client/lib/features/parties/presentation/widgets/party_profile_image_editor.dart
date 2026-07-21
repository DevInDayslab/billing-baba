import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/media/pick_media_image.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/data/party_profile_image_repository.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_avatar.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/widgets/optimistic_media_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Business-logo-style profile image editor for parties.
///
/// When [partyId] is null (create flow), the pick is kept locally until
/// [PartyProfileImageEditorState.flushPendingUpload] runs after create.
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

  /// Called after a successful upload/delete (or local clear while creating).
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

  bool get hasPendingUpload =>
      _pendingUploadBytes != null && _pendingUploadBytes!.isNotEmpty;

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
    if (oldWidget.initialImageUrl != widget.initialImageUrl &&
        _optimisticBytes == null) {
      _imageUrl = widget.initialImageUrl;
    }
    if (oldWidget.initialMediaAssetId != widget.initialMediaAssetId &&
        _optimisticBytes == null) {
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

  Future<void> flushPendingUpload(String partyId) async {
    final bytes = _pendingUploadBytes;
    final mime = _pendingMimeType;
    if (bytes == null || mime == null) return;
    await _performUpload(partyId: partyId, bytes: bytes, mimeType: mime);
    if (!mounted) return;
    setState(() {
      _pendingUploadBytes = null;
      _pendingMimeType = null;
    });
  }

  Future<void> _onReplace() async {
    final picked = await pickAndPrepareMediaImage(context: context);
    if (picked == null || !mounted) return;

    final generation = ++_uploadGeneration;
    final previousUrl = _imageUrl;
    final previousMediaId = _mediaAssetId;

    setState(() {
      _optimisticBytes = picked.previewBytes;
      _uploading = true;
    });

    final partyId = widget.partyId;
    if (partyId == null || partyId.isEmpty) {
      // Create flow — keep bytes until the party exists.
      setState(() {
        _pendingUploadBytes = picked.bytes;
        _pendingMimeType = picked.mimeType;
        _uploading = false;
        _imageUrl = null;
        _mediaAssetId = null;
      });
      _notifyChanged();
      return;
    }

    try {
      await _performUpload(
        partyId: partyId,
        bytes: picked.bytes,
        mimeType: picked.mimeType,
        generation: generation,
      );
    } on Exception catch (e) {
      if (!mounted || _uploadGeneration != generation) return;
      setState(() {
        _optimisticBytes = null;
        _imageUrl = previousUrl;
        _mediaAssetId = previousMediaId;
        _uploading = false;
      });
      _notifyChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _performUpload({
    required String partyId,
    required Uint8List bytes,
    required String mimeType,
    int? generation,
  }) async {
    final repo = _repository;
    if (repo == null) {
      final api = await ref.read(apiClientProvider.future);
      _repository = PartyProfileImageRepository(api.dio);
    }
    final uploadRepo = _repository!;
    final gen = generation ?? ++_uploadGeneration;
    final previousUrl = _imageUrl;
    final previousMediaId = _mediaAssetId;

    setState(() => _uploading = true);

    final upload = await uploadRepo.uploadProfileImage(
      partyId: partyId,
      bytes: bytes,
      mimeType: mimeType,
    );
    if (!mounted || _uploadGeneration != gen) return;

    final newUrl = upload['url'] as String?;
    final newMediaId = upload['media_asset_id'] as String?;

    setState(() {
      _imageUrl = newUrl;
      _mediaAssetId = newMediaId;
      // Keep local preview until the next frame so AppNetworkImage can mount
      // with the signed URL without flashing the initials placeholder.
      _uploading = false;
    });
    _notifyChanged();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _uploadGeneration != gen) return;
      setState(() => _optimisticBytes = null);
    });

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

    setState(() {
      _optimisticBytes = null;
      _pendingUploadBytes = null;
      _pendingMimeType = null;
      _imageUrl = null;
      _mediaAssetId = null;
      _uploading = true;
    });
    _notifyChanged();

    final partyId = widget.partyId;
    if (partyId == null || partyId.isEmpty) {
      setState(() => _uploading = false);
      return;
    }

    final repo = _repository;
    if (repo == null) {
      setState(() {
        _imageUrl = previousUrl;
        _mediaAssetId = previousMediaId;
        _uploading = false;
      });
      _notifyChanged();
      return;
    }

    try {
      await repo.deleteProfileImage(partyId);
      if (!mounted || _uploadGeneration != generation) return;
      setState(() => _uploading = false);
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
      if (!mounted || _uploadGeneration != generation) return;
      setState(() {
        _imageUrl = previousUrl;
        _mediaAssetId = previousMediaId;
        _uploading = false;
      });
      _notifyChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
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
