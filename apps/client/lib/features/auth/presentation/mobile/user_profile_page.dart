import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/data/business_branding_repository.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/optimistic_media_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile account profile — edit avatar (parity with desktop).
class MobileUserProfilePage extends ConsumerStatefulWidget {
  const MobileUserProfilePage({super.key});

  @override
  ConsumerState<MobileUserProfilePage> createState() =>
      _MobileUserProfilePageState();
}

class _MobileUserProfilePageState extends ConsumerState<MobileUserProfilePage> {
  static const _avatarMimes = {'image/png', 'image/jpeg', 'image/webp'};
  static const _avatarSize = 120.0;

  AccountAvatarRepository? _avatarRepository;
  String? _avatarUrl;
  Uint8List? _optimisticBytes;
  String _displayName = 'User';
  String _phone = '';
  String _role = '—';
  String _userId = '—';
  bool _uploading = false;
  var _uploadGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authProvider);
      final user = auth.session?.user;
      setState(() {
        _phone = auth.phone.isNotEmpty ? auth.phone : user?.phone ?? '';
        _displayName = user?.name?.trim().isNotEmpty == true
            ? user!.name!.trim()
            : 'User';
        _role = user?.role ?? '—';
        _userId = user?.id ?? '—';
      });

      final service = await ref.read(businessServiceProvider.future);
      final cached = await service.readCachedProfile();
      if (mounted && cached != null) {
        setState(() {
          _avatarUrl = cached.avatarUrl;
          _displayName =
              cached.displayName ?? auth.session?.user.name ?? 'User';
          _phone = cached.phone;
        });
      }
      await _initRepository();
      await _refreshMe();
    });
  }

  Future<void> _initRepository() async {
    final api = await ref.read(apiClientProvider.future);
    if (!mounted) return;
    setState(() => _avatarRepository = AccountAvatarRepository(api.dio));
  }

  Future<void> _refreshMe() async {
    final accessToken = ref.read(authProvider).session?.accessToken;
    if (accessToken == null) return;

    try {
      final me = await ref.read(authRepositoryProvider).me(accessToken);
      final service = await ref.read(businessServiceProvider.future);
      await service.cacheProfile(me.profile);
      if (!mounted) return;
      setState(() {
        _avatarUrl = me.profile.avatarUrl;
        _displayName = me.profile.displayName ?? me.user.name ?? 'User';
        _phone = me.profile.phone;
        _role = me.user.role ?? '—';
        _userId = me.user.id;
      });
    } on Exception {
      // Keep cached avatar on failure.
    }
  }

  Future<void> _uploadAvatar() async {
    final repo = _avatarRepository;
    if (repo == null) return;

    final picked = await pickAndPrepareMediaImage(
      context: context,
    );
    if (picked == null) return;

    final generation = ++_uploadGeneration;
    final previousUrl = _avatarUrl;

    setState(() {
      _optimisticBytes = picked.previewBytes;
      _uploading = true;
    });

    try {
      final upload = await repo.uploadAvatar(
        bytes: picked.bytes,
        mimeType: picked.mimeType,
      );
      if (!mounted || _uploadGeneration != generation) return;
      setState(() {
        _avatarUrl = upload['url'] as String?;
        _uploading = false;
      });
      unawaited(
        ref
            .read(imageServiceProvider)
            .replaceImage(
              oldUrl: previousUrl,
              newUrl: upload['url'] as String?,
              oldCacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
              newCacheKey: buildImageCacheKey(
                fallbackUrl: upload['url'] as String?,
              ),
            ),
      );
      unawaited(_refreshMe());
    } on Exception catch (e) {
      if (!mounted || _uploadGeneration != generation) return;
      setState(() {
        _optimisticBytes = null;
        _avatarUrl = previousUrl;
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _deleteAvatar() async {
    final repo = _avatarRepository;
    if (repo == null) return;

    final generation = ++_uploadGeneration;
    final previousUrl = _avatarUrl;
    setState(() {
      _optimisticBytes = null;
      _avatarUrl = null;
      _uploading = true;
    });

    try {
      await repo.deleteAvatar();
      if (!mounted || _uploadGeneration != generation) return;
      setState(() => _uploading = false);
      unawaited(
        ref
            .read(imageServiceProvider)
            .invalidateImage(
              url: previousUrl,
              cacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
            ),
      );
      unawaited(_refreshMe());
    } on Exception catch (e) {
      if (!mounted || _uploadGeneration != generation) return;
      setState(() {
        _avatarUrl = previousUrl;
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Profile',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            OptimisticMediaUploader(
              label: 'Profile photo',
              imageUrl: _avatarUrl,
              optimisticBytes: _optimisticBytes,
              isUploading: _uploading,
              replaceLabel: 'Change photo',
              removeLabel: 'Remove photo',
              emptyLabel: 'Add photo',
              onReplace: () => unawaited(_uploadAvatar()),
              onRemove:
                  (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty) ||
                      _optimisticBytes != null
                  ? () => unawaited(_deleteAvatar())
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _displayName,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _phone,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Role',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        _role,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'User ID',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        _userId,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
