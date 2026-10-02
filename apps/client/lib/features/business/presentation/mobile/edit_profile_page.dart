import 'dart:async';

import 'package:billing_baba/core/network/business_selection_retry_guard.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_profile_controller.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/data/business_branding_repository.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/business/presentation/mobile/application/mobile_business_profile_completion.dart';
import 'package:billing_baba/features/business/presentation/mobile/application/mobile_business_profile_loader.dart';
import 'package:billing_baba/features/business/presentation/mobile/widgets/mobile_business_profile_completion_section.dart';
import 'package:billing_baba/features/business/presentation/mobile/widgets/mobile_business_profile_labeled_field.dart';
import 'package:billing_baba/features/business/presentation/mobile/widgets/mobile_business_profile_signature_section.dart';
import 'package:billing_baba/features/business/presentation/mobile/widgets/mobile_business_profile_tab_bar.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/optimistic_media_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MobileEditProfilePage extends ConsumerStatefulWidget {
  const MobileEditProfilePage({super.key});

  @override
  ConsumerState<MobileEditProfilePage> createState() =>
      _MobileEditProfilePageState();
}

class _MobileEditProfilePageState extends ConsumerState<MobileEditProfilePage> {
  static const _saveRed = Color(0xFFE53935);
  static const _logoSize = 112.0;
  static const _logoMimes = {'image/png', 'image/jpeg', 'image/webp'};
  static const _pngOnly = {'image/png'};

  static const _businessTypes = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Service',
    'Other',
  ];

  static const _businessCategories = [
    'Apparels',
    'Medical',
    'Fruits',
    'Restaurant',
    'Hardware',
    'Electronics',
    'Salon',
    'Gym',
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
  final _phone2Controller = TextEditingController();
  final _gstinController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _upiIdController = TextEditingController();

  MobileBusinessProfileTab _activeTab = MobileBusinessProfileTab.basicDetails;
  String? _businessType;
  String? _businessCategory;
  String? _state;
  String? _hydratedProfileId;
  String? _profileSeed;
  final _showGstinOnCard = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile =
          ref.read(mobileBusinessProfileLoaderProvider).asData?.value ??
          ref.read(businessProfileProvider).asData?.value;
      if (profile != null && mounted) {
        setState(() => _hydrateFromProfile(profile));
      }
      unawaited(_initBrandingRepository());
    });
  }

  Future<void> _initBrandingRepository() async {
    final api = await ref.read(apiClientProvider.future);
    if (!mounted) return;
    setState(() => _brandingRepository = BusinessBrandingRepository(api.dio));
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _descriptionController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(BusinessProfileModel profile) {
    if (_hydratedProfileId == profile.id) return;

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
    _logoUrl = profile.logoUrl;
    _signatureUrl = profile.signatureUrl;
    _logoOptimisticBytes = null;
    _signatureOptimisticBytes = null;
    _profileSeed = profile.id;
    _hydratedProfileId = profile.id;
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
    ref.invalidate(mobileBusinessProfileLoaderProvider);
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
    ref.invalidate(mobileBusinessProfileLoaderProvider);
  }

  Future<void> _uploadBranding({
    required Set<String> allowedMimes,
    required int maxBytes,
    required Future<Map<String, dynamic>> Function(
      BusinessBrandingRepository repo,
      Uint8List bytes,
      String mime,
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

  int _completionPercent(BusinessProfileModel profile) {
    return calculateMobileBusinessProfileCompletion(
      profile: profile,
      name: _businessNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstin: _gstinController.text,
      address: _addressController.text,
      pincode: _pincodeController.text,
      businessType: _businessType,
      businessCategory: _businessCategory,
      state: _state,
      upiId: _upiIdController.text,
    );
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
      setState(() {
        _businessType = updated.businessType;
        _businessCategory = updated.businessCategory;
        _state = updated.state;
      });
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(mobileBusinessProfileLoaderProvider);
    final formState = ref.watch(editBusinessProfileFormProvider);

    ref.listen<AsyncValue<BusinessProfileModel>>(
      mobileBusinessProfileLoaderProvider,
      (previous, next) {
        next.whenData((profile) {
          if (_hydratedProfileId != profile.id && mounted) {
            setState(() => _hydrateFromProfile(profile));
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 14,
                  color: AppColors.error.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 4),
                Text(
                  'Mobile Freemium',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: error is BusinessServerUnavailable
              ? error.toString()
              : 'Unable to load business profile. Please try again.',
          onRetry: () {
            BusinessSelectionRetryGuard.reset();
            ref
              ..invalidate(mobileBusinessProfileLoaderProvider)
              ..invalidate(businessProfileProvider);
          },
        ),
        data: (profile) {
          final completion = _completionPercent(profile);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  children: [
                    MobileBusinessProfileCompletionSection(
                      percent: completion,
                    ),
                    MobileBusinessProfileTabBar(
                      activeTab: _activeTab,
                      onChanged: (tab) => setState(() => _activeTab = tab),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      child: _activeTab == MobileBusinessProfileTab.basicDetails
                          ? _buildBasicDetailsTab(formState)
                          : _buildBusinessDetailsTab(formState),
                    ),
                  ],
                ),
              ),
              _FooterBar(
                isSaving: formState.isSubmitting,
                onCancel: () => context.pop(),
                onSave: _save,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicDetailsTab(EditBusinessProfileFormState formState) {
    final displayName = _businessNameController.text.trim().isEmpty
        ? 'Business'
        : _businessNameController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: OptimisticMediaUploader(
            label: 'Business logo',
            size: _logoSize,
            imageUrl: _logoUrl,
            optimisticBytes: _logoOptimisticBytes,
            isUploading: _uploadingLogo,
            replaceLabel: 'Change logo',
            removeLabel: 'Remove logo',
            emptyLabel: 'Add logo',
            placeholder: BusinessAvatar(
              name: displayName,
              seed: _profileSeed ?? _hydratedProfileId ?? 'business',
              diameter: _logoSize,
            ),
            onReplace: () => unawaited(_uploadLogo()),
            onRemove:
                (_logoUrl != null && _logoUrl!.trim().isNotEmpty) ||
                    _logoOptimisticBytes != null
                ? () => unawaited(_deleteLogo())
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        MobileBusinessProfileLabeledField(
          label: 'Business Name',
          controller: _businessNameController,
          onChanged: () => setState(() {}),
          errorText: formState.errorFor('name'),
          inputFormatters: [
            LengthLimitingTextInputFormatter(Validators.businessNameMaxLength),
            FilteringTextInputFormatter.allow(
              Validators.businessNameInputPattern,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'GSTIN',
          controller: _gstinController,
          onChanged: () => setState(() {}),
          errorText: formState.errorFor('gstin'),
          inputFormatters: [
            const UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          ],
          // suffix: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     Text(
          //       'Show on card',
          //       style: Theme.of(context).textTheme.labelSmall?.copyWith(
          //         color: AppColors.textSecondary,
          //       ),
          //     ),
          //     Switch(
          //       value: _showGstinOnCard,
          //       onChanged: (value) => setState(() => _showGstinOnCard = value),
          //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     ),
          //   ],
          // ),
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Phone Number 1',
          controller: _phoneController,
          onChanged: () => setState(() {}),
          keyboardType: TextInputType.phone,
          errorText: formState.errorFor('phone'),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Phone Number 2',
          controller: _phone2Controller,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Email ID',
          controller: _emailController,
          onChanged: () => setState(() {}),
          keyboardType: TextInputType.emailAddress,
          errorText: formState.errorFor('email'),
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
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Business Address',
          controller: _addressController,
          onChanged: () => setState(() {}),
          minLines: 3,
          maxLines: 4,
          errorText: formState.errorFor('address'),
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Pincode',
          controller: _pincodeController,
          onChanged: () => setState(() {}),
          keyboardType: TextInputType.number,
          errorText: formState.errorFor('pincode'),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'Business Description',
          controller: _descriptionController,
          minLines: 3,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_signatureUrl != null ||
            _signatureOptimisticBytes != null ||
            _uploadingSignature) ...[
          Center(
            child: OptimisticMediaUploader(
              label: 'Signature',
              width: 220,
              height: 96,
              shape: OptimisticMediaShape.roundedRect,
              imageUrl: _signatureUrl,
              optimisticBytes: _signatureOptimisticBytes,
              isUploading: _uploadingSignature,
              replaceLabel: 'Replace signature',
              removeLabel: 'Remove signature',
              emptyLabel: 'Sign',
              onReplace: () => unawaited(_uploadSignature()),
              onRemove:
                  (_signatureUrl != null && _signatureUrl!.trim().isNotEmpty) ||
                      _signatureOptimisticBytes != null
                  ? () => unawaited(_deleteSignature())
                  : null,
            ),
          ),
        ] else
          MobileBusinessProfileSignatureSection(
            onCreate: () => unawaited(_uploadSignature()),
            onUpload: () => unawaited(_uploadSignature()),
          ),
      ],
    );
  }

  Widget _buildBusinessDetailsTab(EditBusinessProfileFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DropdownField(
          label: 'Business Type',
          value: _businessType,
          options: _dropdownOptions(_businessTypes, _businessType),
          onChanged: (value) => setState(() {
            _businessType = value;
          }),
          errorText: formState.errorFor('business_type'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DropdownField(
          label: 'Business Category',
          value: _businessCategory,
          options: _dropdownOptions(_businessCategories, _businessCategory),
          onChanged: (value) => setState(() {
            _businessCategory = value;
          }),
          errorText: formState.errorFor('business_category'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DropdownField(
          label: 'State',
          value: _state,
          options: _dropdownOptions(_indianStates, _state),
          onChanged: (value) => setState(() {
            _state = value;
          }),
          errorText: formState.errorFor('state'),
        ),
        const SizedBox(height: AppSpacing.lg),
        MobileBusinessProfileLabeledField(
          label: 'UPI ID',
          controller: _upiIdController,
          onChanged: () => setState(() {}),
          errorText: formState.errorFor('upi_id'),
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
            FilteringTextInputFormatter.allow(RegExp(r'[\w.\-@]')),
          ],
        ),
      ],
    );
  }

  List<String> _dropdownOptions(List<String> options, String? selected) {
    if (selected == null || selected.isEmpty || options.contains(selected)) {
      return options;
    }
    return [selected, ...options];
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
            errorText: errorText,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label'),
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: _MobileEditProfilePageState._saveRed,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
