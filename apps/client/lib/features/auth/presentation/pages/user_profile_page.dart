import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/storage/media_upload_client.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/data/business_branding_repository.dart';
import 'package:billing_baba/features/business/presentation/widgets/branding_image_uploader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  static const _avatarMimes = {'image/png', 'image/jpeg', 'image/webp'};

  AccountAvatarRepository? _avatarRepository;
  String? _avatarUrl;
  String _displayName = 'User';
  String _phone = '';
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authProvider);
      _phone = auth.phone;
      final service = await ref.read(businessServiceProvider.future);
      final cached = await service.readCachedProfile();
      if (mounted && cached != null) {
        final auth = ref.read(authProvider);
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
      });
    } on Exception {
      // Keep cached avatar on failure.
    }
  }

  Future<void> _uploadAvatar() async {
    final repo = _avatarRepository;
    if (repo == null) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    final mime = mimeTypeFromFilename(file.name);
    if (!isAllowedMime(mime, _avatarMimes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type: ${file.name}')),
        );
      }
      return;
    }

    if (file.bytes!.length > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar must be 2 MB or smaller')),
        );
      }
      return;
    }

    setState(() => _uploading = true);

    try {
      final upload = await repo.uploadAvatar(
        bytes: file.bytes!,
        mimeType: mime,
      );
      setState(() => _avatarUrl = upload['url'] as String?);
      await _refreshMe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteAvatar() async {
    final repo = _avatarRepository;
    if (repo == null) return;

    setState(() => _uploading = true);

    try {
      await repo.deleteAvatar();
      setState(() => _avatarUrl = null);
      await _refreshMe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar removed')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: AppRadius.mdBorder,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _phone,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: SizedBox(
                      width: 160,
                      child: BrandingImageUploader(
                        label: 'Avatar',
                        imageUrl: _avatarUrl,
                        isUploading: _uploading,
                        shape: BrandingImageShape.circle,
                        width: 140,
                        height: 140,
                        onUpload: _uploadAvatar,
                        onDelete: _avatarUrl == null ? null : _deleteAvatar,
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
