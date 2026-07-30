import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_profile_controller.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/data/business_branding_repository.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/optimistic_media_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopEditProfilePage extends ConsumerStatefulWidget {
  const DesktopEditProfilePage({this.embedded = false, super.key});

  /// When true, omit page chrome meant for the standalone `/edit-profile` route
  /// (used inside the Settings Business Profile tab).
  final bool embedded;

  @override
  ConsumerState<DesktopEditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<DesktopEditProfilePage> {
  static const _saveButtonColor = Color(0xFFD32F2F);
  static const _compactBreakpoint = 860.0;
  static const _logoSize = 120.0;
  static const _signatureWidth = 220.0;
  static const _signatureHeight = 96.0;
  static const double _mediaColumnWidth = _signatureWidth + 8;
  static const _mediaToFormGap = 40.0;

  static const _pngOnly = {'image/png'};
  static const _logoMimes = {'image/png', 'image/jpeg', 'image/webp'};

  static const _businessTypes = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Service',
    'Other',
  ];

  static const _businessCategories = [
    'General Store',
    'Electronics',
    'Clothing',
    'Food',
    'Pharmacy',
    'Other',
  ];

  static const _indianStates = [
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
    'Gujarat',
    'Rajasthan',
    'West Bengal',
    'Madhya Pradesh',
    'Andhra Pradesh',
    'Telangana',
    'Kerala',
    'Punjab',
    'Haryana',
    'Bihar',
    'Odisha',
    'Assam',
    'Jharkhand',
    'Uttarakhand',
    'Himachal Pradesh',
    'Goa',
    'Chhattisgarh',
  ];

  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _upiIdController = TextEditingController();

  String? _businessType;
  String? _businessCategory;
  String? _state;
  String? _profileSeed;
  String? _hydratedProfileId;

  String? _logoUrl;
  String? _signatureUrl;
  Uint8List? _logoOptimisticBytes;
  Uint8List? _signatureOptimisticBytes;

  bool _uploadingLogo = false;
  bool _uploadingSignature = false;
  var _logoUploadGeneration = 0;
  var _signatureUploadGeneration = 0;

  BusinessBrandingRepository? _brandingRepository;

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(businessProfileProvider).asData?.value;
      if (profile != null && mounted) {
        setState(() => _hydrateFromProfile(profile));
      }
      _initRepository();
    });
  }

  Future<void> _initRepository() async {
    final api = await ref.read(apiClientProvider.future);
    if (!mounted) return;
    setState(() => _brandingRepository = BusinessBrandingRepository(api.dio));
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(
    BusinessProfileModel profile, {
    bool force = false,
  }) {
    if (!force && _hydratedProfileId == profile.id) return;

    _businessNameController.text = profile.name;
    _phoneController.text =
        Validators.normalizeIndianPhone(profile.phone) ?? '';
    _gstinController.text = profile.gstin ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _pincodeController.text =
        Validators.normalizePincode(profile.pincode) ?? '';
    _upiIdController.text = profile.upiId ?? '';
    _businessType = profile.businessType;
    _businessCategory = profile.businessCategory;
    _state = profile.state;
    _profileSeed = profile.id;
    _hydratedProfileId = profile.id;
    _logoUrl = profile.logoUrl;
    _signatureUrl = profile.signatureUrl;
    _logoOptimisticBytes = null;
    _signatureOptimisticBytes = null;
  }

  Future<void> _refreshProfile({bool syncFormFields = false}) async {
    final service = await ref.read(businessServiceProvider.future);
    final profile = await service.fetchBusinessProfile(forceRefresh: true);
    ref.read(businessProfileProvider.notifier).replaceWith(profile);
    if (!mounted) return;

    setState(() {
      _logoUrl = profile.logoUrl;
      _signatureUrl = profile.signatureUrl;
      _profileSeed = profile.id;
      // Keep optimistic local previews until the user picks a new image.
      if (syncFormFields || _hydratedProfileId != profile.id) {
        _hydrateFromProfile(profile, force: true);
      }
    });
  }

  Future<void> _uploadBranding({
    required Set<String> allowedMimes,
    required int maxBytes,
    required Future<Map<String, dynamic>> Function(
      BusinessBrandingRepository repo,
      Uint8List bytes,
      String mimeType,
    )
    upload,
    required void Function(bool value) setUploading,
    required void Function(String? url) setUrl,
    required void Function(Uint8List? bytes) setOptimisticBytes,
    required String? Function() currentUrl,
    required int Function() nextGeneration,
    required int Function() currentGeneration,
    required void Function(String? url) patchProfileMedia,
  }) async {
    final repo = _brandingRepository;
    if (repo == null) return;

    final picked = await pickAndPrepareMediaImage(
      context: context,
      allowedMimes: allowedMimes,
      maxBytes: maxBytes,
    );
    if (picked == null) return;

    final generation = nextGeneration();
    final previousUrl = currentUrl();

    // Paint local preview immediately — do not wait for the network.
    setState(() {
      setOptimisticBytes(picked.previewBytes);
      setUploading(true);
    });

    try {
      if (!mounted || currentGeneration() != generation) return;

      final result = await upload(repo, picked.bytes, picked.mimeType);
      if (!mounted || currentGeneration() != generation) return;

      final newUrl = result['url'] as String?;
      setState(() {
        setUrl(newUrl);
        setUploading(false);
      });
      patchProfileMedia(newUrl);
      unawaited(
        ref
            .read(imageServiceProvider)
            .replaceImage(
              oldUrl: previousUrl,
              newUrl: newUrl,
              oldCacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
              newCacheKey: buildImageCacheKey(fallbackUrl: newUrl),
            ),
      );
    } on Exception catch (e) {
      if (!mounted || currentGeneration() != generation) return;
      setState(() {
        setOptimisticBytes(null);
        setUrl(previousUrl);
        setUploading(false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _deleteBranding({
    required Future<void> Function(BusinessBrandingRepository repo) delete,
    required void Function(bool value) setUploading,
    required void Function(String? url) setUrl,
    required void Function(Uint8List? bytes) setOptimisticBytes,
    required String? Function() currentUrl,
    required int Function() nextGeneration,
    required int Function() currentGeneration,
    required void Function() patchProfileMediaCleared,
    required void Function(String? url) patchProfileMedia,
  }) async {
    final repo = _brandingRepository;
    if (repo == null) return;

    final generation = nextGeneration();
    final previousUrl = currentUrl();

    setState(() {
      setOptimisticBytes(null);
      setUrl(null);
      setUploading(true);
    });
    patchProfileMediaCleared();

    try {
      await delete(repo);
      if (!mounted || currentGeneration() != generation) return;
      setState(() => setUploading(false));
      unawaited(
        ref
            .read(imageServiceProvider)
            .invalidateImage(
              url: previousUrl,
              cacheKey: buildImageCacheKey(fallbackUrl: previousUrl),
            ),
      );
    } on Exception catch (e) {
      if (!mounted || currentGeneration() != generation) return;
      setState(() {
        setUrl(previousUrl);
        setUploading(false);
      });
      patchProfileMedia(previousUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  void _patchLogoOnProfile(String? url) {
    final current = ref.read(businessProfileProvider).asData?.value;
    if (current == null) return;
    ref
        .read(businessProfileProvider.notifier)
        .replaceWith(
          url == null
              ? current.copyWith(clearLogoUrl: true)
              : current.copyWith(logoUrl: url),
        );
  }

  void _patchSignatureOnProfile(String? url) {
    final current = ref.read(businessProfileProvider).asData?.value;
    if (current == null) return;
    ref
        .read(businessProfileProvider.notifier)
        .replaceWith(
          url == null
              ? current.copyWith(clearSignatureUrl: true)
              : current.copyWith(signatureUrl: url),
        );
  }

  Future<void> _uploadLogo() {
    return _uploadBranding(
      allowedMimes: _logoMimes,
      maxBytes: 2 * 1024 * 1024,
      upload: (repo, bytes, mime) =>
          repo.uploadLogo(bytes: bytes, mimeType: mime),
      setUploading: (v) => _uploadingLogo = v,
      setUrl: (url) => _logoUrl = url,
      setOptimisticBytes: (bytes) => _logoOptimisticBytes = bytes,
      currentUrl: () => _logoUrl,
      nextGeneration: () => ++_logoUploadGeneration,
      currentGeneration: () => _logoUploadGeneration,
      patchProfileMedia: _patchLogoOnProfile,
    );
  }

  Future<void> _deleteLogo() {
    return _deleteBranding(
      delete: (repo) => repo.deleteLogo(),
      setUploading: (v) => _uploadingLogo = v,
      setUrl: (url) => _logoUrl = url,
      setOptimisticBytes: (bytes) => _logoOptimisticBytes = bytes,
      currentUrl: () => _logoUrl,
      nextGeneration: () => ++_logoUploadGeneration,
      currentGeneration: () => _logoUploadGeneration,
      patchProfileMediaCleared: () => _patchLogoOnProfile(null),
      patchProfileMedia: _patchLogoOnProfile,
    );
  }

  Future<void> _uploadSignature() {
    return _uploadBranding(
      allowedMimes: _pngOnly,
      maxBytes: 1024 * 1024,
      upload: (repo, bytes, mime) =>
          repo.uploadSignature(bytes: bytes, mimeType: mime),
      setUploading: (v) => _uploadingSignature = v,
      setUrl: (url) => _signatureUrl = url,
      setOptimisticBytes: (bytes) => _signatureOptimisticBytes = bytes,
      currentUrl: () => _signatureUrl,
      nextGeneration: () => ++_signatureUploadGeneration,
      currentGeneration: () => _signatureUploadGeneration,
      patchProfileMedia: _patchSignatureOnProfile,
    );
  }

  Future<void> _deleteSignature() {
    return _deleteBranding(
      delete: (repo) => repo.deleteSignature(),
      setUploading: (v) => _uploadingSignature = v,
      setUrl: (url) => _signatureUrl = url,
      setOptimisticBytes: (bytes) => _signatureOptimisticBytes = bytes,
      currentUrl: () => _signatureUrl,
      nextGeneration: () => ++_signatureUploadGeneration,
      currentGeneration: () => _signatureUploadGeneration,
      patchProfileMediaCleared: () => _patchSignatureOnProfile(null),
      patchProfileMedia: _patchSignatureOnProfile,
    );
  }

  List<String> _dropdownOptions(List<String> options, String? selected) {
    if (selected == null || selected.isEmpty || options.contains(selected)) {
      return options;
    }
    return [selected, ...options];
  }

  Future<void> _save() async {
    ref.read(editBusinessProfileFormProvider.notifier).clearErrors();

    final input = UpdateBusinessProfileInput(
      name: _businessNameController.text,
      phone: Validators.normalizeIndianPhone(_phoneController.text),
      email: _emailController.text,
      gstin: _gstinController.text,
      address: _addressController.text,
      businessType: _businessType,
      businessCategory: _businessCategory,
      state: _state,
      pincode: Validators.normalizePincode(_pincodeController.text),
      upiId: _upiIdController.text,
    );

    final updated = await ref
        .read(editBusinessProfileFormProvider.notifier)
        .submit(input);

    if (!mounted) return;

    if (updated != null) {
      _syncDropdownsFromProfile(updated);
      await _refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile saved successfully')),
      );
      return;
    }

    final formState = ref.read(editBusinessProfileFormProvider);
    final message =
        formState.generalError ??
        (formState.fieldErrors.isNotEmpty
            ? formState.fieldErrors.values.first
            : null);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _syncDropdownsFromProfile(BusinessProfileModel profile) {
    setState(() {
      _businessType = profile.businessType;
      _businessCategory = profile.businessCategory;
      _state = profile.state;
      _profileSeed = profile.id;
      _logoUrl = profile.logoUrl;
      _signatureUrl = profile.signatureUrl;
      _phoneController.text =
          Validators.normalizeIndianPhone(profile.phone) ?? '';
      _pincodeController.text =
          Validators.normalizePincode(profile.pincode) ?? '';
    });
  }

  Widget _buildBusinessDetailsColumn(EditBusinessProfileFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Business Details'),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Business Name',
          required: true,
          errorText: formState.errorFor('name'),
          child: _OutlinedField(
            controller: _businessNameController,
            hintText: 'Business Name',
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                Validators.businessNameMaxLength,
              ),
              FilteringTextInputFormatter.allow(
                Validators.businessNameInputPattern,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Phone Number',
          errorText: formState.errorFor('phone'),
          child: _OutlinedField(
            controller: _phoneController,
            hintText: 'Phone Number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'GSTIN',
          errorText: formState.errorFor('gstin'),
          child: _OutlinedField(
            controller: _gstinController,
            hintText: 'GSTIN',
            inputFormatters: [
              const UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Email ID',
          errorText: formState.errorFor('email'),
          child: _OutlinedField(
            controller: _emailController,
            hintText: 'Email ID',
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              LengthLimitingTextInputFormatter(200),
              FilteringTextInputFormatter.allow(
                RegExp(
                  r'[\w\-.@+'
                  ']',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Business Address',
          errorText: formState.errorFor('address'),
          child: _OutlinedField(
            controller: _addressController,
            hintText: 'Business Address',
            minLines: 4,
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDetailsColumn(EditBusinessProfileFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'More Details'),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Business Type',
          errorText: formState.errorFor('business_type'),
          child: _OutlinedDropdown<String>(
            value: _businessType,
            hintText: 'Business Type',
            items: _dropdownOptions(_businessTypes, _businessType),
            onChanged: (value) => setState(() => _businessType = value),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Business Category',
          errorText: formState.errorFor('business_category'),
          child: _OutlinedDropdown<String>(
            value: _businessCategory,
            hintText: 'Business Category',
            items: _dropdownOptions(_businessCategories, _businessCategory),
            onChanged: (value) => setState(() => _businessCategory = value),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'State',
          errorText: formState.errorFor('state'),
          child: _OutlinedDropdown<String>(
            value: _state,
            hintText: 'State',
            items: _dropdownOptions(_indianStates, _state),
            onChanged: (value) => setState(() => _state = value),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Pincode',
          errorText: formState.errorFor('pincode'),
          child: _OutlinedField(
            controller: _pincodeController,
            hintText: 'Pincode',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'UPI ID',
          errorText: formState.errorFor('upi_id'),
          child: _OutlinedField(
            controller: _upiIdController,
            hintText: 'merchant@upi',
            inputFormatters: [
              LengthLimitingTextInputFormatter(100),
              FilteringTextInputFormatter.allow(RegExp(r'[\w.\-@]')),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(businessProfileProvider);
    final formState = ref.watch(editBusinessProfileFormProvider);

    ref.listen(businessProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (_hydratedProfileId != profile.id && mounted) {
          setState(() => _hydrateFromProfile(profile));
        }
      });
    });

    return ColoredBox(
      color: AppColors.surface,
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: 'Unable to load business profile. Please try again.',
          onRetry: () => ref.invalidate(businessProfileProvider),
        ),
        data: (profile) {
          final displayName = _businessNameController.text.isNotEmpty
              ? _businessNameController.text
              : profile.name;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.embedded) ...[
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (formState.generalError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      formState.generalError!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked =
                              constraints.maxWidth < _compactBreakpoint;
                          final mediaColumn = Column(
                            children: [
                              OptimisticMediaUploader(
                                label: 'Logo',
                                imageUrl: _logoUrl,
                                optimisticBytes: _logoOptimisticBytes,
                                isUploading: _uploadingLogo,
                                replaceLabel: 'Replace Business Logo',
                                removeLabel: 'Remove Business Logo',
                                placeholder: BusinessAvatar(
                                  name: displayName,
                                  seed: _profileSeed ?? profile.id,
                                  diameter: _logoSize,
                                ),
                                onReplace: _uploadLogo,
                                onRemove:
                                    (_logoUrl != null &&
                                            _logoUrl!.trim().isNotEmpty) ||
                                        _logoOptimisticBytes != null
                                    ? _deleteLogo
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              OptimisticMediaUploader(
                                label: 'Signature',
                                width: _signatureWidth,
                                height: _signatureHeight,
                                imageUrl: _signatureUrl,
                                optimisticBytes: _signatureOptimisticBytes,
                                isUploading: _uploadingSignature,
                                shape: OptimisticMediaShape.roundedRect,
                                replaceLabel: 'Replace Signature',
                                removeLabel: 'Remove Signature',
                                emptyLabel: 'Sign',
                                onReplace: _uploadSignature,
                                onRemove:
                                    (_signatureUrl != null &&
                                            _signatureUrl!.trim().isNotEmpty) ||
                                        _signatureOptimisticBytes != null
                                    ? _deleteSignature
                                    : null,
                              ),
                            ],
                          );
                          final details = _buildBusinessDetailsColumn(
                            formState,
                          );
                          final more = _buildMoreDetailsColumn(formState);

                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(child: mediaColumn),
                                const SizedBox(height: AppSpacing.lg),
                                details,
                                const SizedBox(height: AppSpacing.lg),
                                more,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: _mediaColumnWidth,
                                child: mediaColumn,
                              ),
                              const SizedBox(width: _mediaToFormGap),
                              Expanded(child: details),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(child: more),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: Color(0xFFE0E0E0)),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!widget.embedded) ...[
                            OutlinedButton(
                              onPressed: formState.isSubmitting
                                  ? null
                                  : () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm + 4,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: AppSpacing.sm + 4),
                          ] else ...[
                            OutlinedButton(
                              onPressed: formState.isSubmitting
                                  ? null
                                  : () {
                                      final current = ref
                                          .read(businessProfileProvider)
                                          .asData
                                          ?.value;
                                      if (current == null) return;
                                      setState(
                                        () => _hydrateFromProfile(current),
                                      );
                                      ref
                                          .read(
                                            editBusinessProfileFormProvider
                                                .notifier,
                                          )
                                          .clearErrors();
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm + 4,
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: AppSpacing.sm + 4),
                          ],
                          FilledButton(
                            onPressed: formState.isSubmitting ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: _saveButtonColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm + 4,
                              ),
                            ),
                            child: formState.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
  });

  static const _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
  );

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: _fieldBorder,
        enabledBorder: _fieldBorder,
        focusedBorder: _fieldBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 4,
          vertical: AppSpacing.sm + 4,
        ),
      ),
    );
  }
}

class _OutlinedDropdown<T> extends StatelessWidget {
  const _OutlinedDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  static const _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
  );

  final T? value;
  final String hintText;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(
        'Select $hintText',
        style: const TextStyle(color: Colors.grey),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87),
      decoration: const InputDecoration(
        border: _fieldBorder,
        enabledBorder: _fieldBorder,
        focusedBorder: _fieldBorder,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 4,
          vertical: AppSpacing.sm + 4,
        ),
      ),
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
