import 'dart:async';

import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/create_business_controller.dart';
import 'package:billing_baba/features/business/data/business_branding_repository.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_form_fields.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/media/pick_media_image.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const double _compactBreakpoint = 860;
const double _dialogWideWidth = 1080;
const _cardBorder = Color(0xFFE0E0E0);
const double _logoSize = 120;
const double _mediaColumnWidth = 180;

const Map<String, String> _currencyLabels = {
  'INR': 'INR (₹)',
  'USD': r'USD ($)',
  'EUR': 'EUR (€)',
  'GBP': 'GBP (£)',
  'AED': 'AED',
};

Future<bool?> showCreateBusinessModal(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 600) {
    final maxWidth = width >= 860
        ? _dialogWideWidth
        : width >= 720
        ? 740.0
        : 560.0;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: _CreateBusinessSheet(
          isDialog: true,
          maxWidth: maxWidth,
        ),
      ),
    );
  }
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateBusinessSheet(isDialog: false),
  );
}

class _CreateBusinessSheet extends ConsumerStatefulWidget {
  const _CreateBusinessSheet({
    required this.isDialog,
    this.maxWidth = _dialogWideWidth,
  });

  final bool isDialog;
  final double maxWidth;

  @override
  ConsumerState<_CreateBusinessSheet> createState() =>
      _CreateBusinessSheetState();
}

class _CreateBusinessSheetState extends ConsumerState<_CreateBusinessSheet> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();

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

  static const _currencies = ['INR', 'USD', 'EUR', 'GBP', 'AED'];

  String? _businessType;
  String? _businessCategory;
  String? _state;
  String _currency = 'INR';
  Uint8List? _logoBytes;
  Uint8List? _logoPreviewBytes;
  String? _logoMimeType;
  var _prefilled = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final auth = ref.read(authProvider);
    final phone = auth.session?.user.phone ?? auth.phone;
    if (phone.length >= 10) {
      _phoneController.text = phone.substring(phone.length - 10);
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  CreateBusinessInput _buildInput() {
    return CreateBusinessInput(
      name: _businessNameController.text,
      ownerName: _ownerNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstin: _gstinController.text,
      businessType: _businessType ?? '',
      businessCategory: _businessCategory ?? '',
      state: _state ?? '',
      currency: _currency,
      address: _addressController.text,
    );
  }

  Future<void> _pickLogo() async {
    final picked = await pickAndPrepareMediaImage(context: context);
    if (picked == null || !mounted) return;
    setState(() {
      _logoBytes = picked.bytes;
      _logoPreviewBytes = picked.previewBytes;
      _logoMimeType = picked.mimeType;
    });
  }

  Future<void> _uploadLogoIfPicked() async {
    final bytes = _logoBytes;
    final mime = _logoMimeType;
    if (bytes == null || mime == null) return;

    try {
      final api = await ref.read(apiClientProvider.future);
      if (!mounted) return;
      await BusinessBrandingRepository(api.dio).uploadLogo(
        bytes: bytes,
        mimeType: mime,
      );
      if (!mounted) return;
      await ref.read(businessListProvider.notifier).refresh();
    } on Object {
      // Create already succeeded; logo can be added later in profile.
    }
  }

  Future<void> _submit() async {
    final formState = ref.read(createBusinessFormProvider);
    if (formState.isSubmitting) return;

    ref.read(createBusinessFormProvider.notifier).clearErrors();

    setState(() => _autovalidateMode = AutovalidateMode.always);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final created = await ref
        .read(createBusinessFormProvider.notifier)
        .submit(_buildInput());
    if (!mounted) return;

    if (created != null) {
      await _uploadLogoIfPicked();
      if (!mounted) return;
      ref.invalidate(createBusinessFormProvider);
      Navigator.of(context).pop(true);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.validate();
    });
  }

  void _showGenericErrorDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Could not create business'),
          content: const Text(
            'Something went wrong. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoColumn() {
    final displayName = _businessNameController.text.trim().isNotEmpty
        ? _businessNameController.text
        : 'Business';

    final avatar = _logoPreviewBytes != null
        ? ClipOval(
            child: Image.memory(
              _logoPreviewBytes!,
              width: _logoSize,
              height: _logoSize,
              fit: BoxFit.cover,
            ),
          )
        : BusinessAvatar(
            name: displayName,
            seed: 'new-business',
            diameter: _logoSize,
          );

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Tooltip(
              message: 'JPG, PNG or SVG. Max 2MB',
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        avatar,
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _pickLogo,
          icon: const Icon(LucideIcons.upload, size: 16),
          label: const Text('Upload Logo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'JPG, PNG or SVG. Max 2MB',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createBusinessFormProvider);

    ref.listen<CreateBusinessFormState>(createBusinessFormProvider, (
      prev,
      next,
    ) {
      if (next.showGenericErrorDialog &&
          (prev == null || !prev.showGenericErrorDialog)) {
        _showGenericErrorDialog();
        ref
            .read(createBusinessFormProvider.notifier)
            .acknowledgeGenericDialog();
      }
    });

    final content = _CreateBusinessFormContent(
      formKey: _formKey,
      autovalidateMode: _autovalidateMode,
      formState: formState,
      logoColumn: _buildLogoColumn(),
      businessNameController: _businessNameController,
      ownerNameController: _ownerNameController,
      phoneController: _phoneController,
      emailController: _emailController,
      gstinController: _gstinController,
      addressController: _addressController,
      businessType: _businessType,
      businessCategory: _businessCategory,
      state: _state,
      currency: _currency,
      businessTypes: _businessTypes,
      businessCategories: _businessCategories,
      states: SaleDropdownOptions.indianStates,
      currencies: _currencies,
      onBusinessTypeChanged: (value) => setState(() => _businessType = value),
      onBusinessCategoryChanged: (value) =>
          setState(() => _businessCategory = value),
      onStateChanged: (value) => setState(() => _state = value),
      onCurrencyChanged: (value) {
        if (value != null) setState(() => _currency = value);
      },
      onCancel: formState.isSubmitting
          ? null
          : () => Navigator.of(context).pop(false),
      onSubmit: _submit,
    );

    if (widget.isDialog) {
      return Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.elevated,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(child: content),
    );
  }
}

class _CreateBusinessFormContent extends StatelessWidget {
  const _CreateBusinessFormContent({
    required this.formKey,
    required this.autovalidateMode,
    required this.formState,
    required this.logoColumn,
    required this.businessNameController,
    required this.ownerNameController,
    required this.phoneController,
    required this.emailController,
    required this.gstinController,
    required this.addressController,
    required this.businessType,
    required this.businessCategory,
    required this.state,
    required this.currency,
    required this.businessTypes,
    required this.businessCategories,
    required this.states,
    required this.currencies,
    required this.onBusinessTypeChanged,
    required this.onBusinessCategoryChanged,
    required this.onStateChanged,
    required this.onCurrencyChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final CreateBusinessFormState formState;
  final Widget logoColumn;
  final TextEditingController businessNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController gstinController;
  final TextEditingController addressController;
  final String? businessType;
  final String? businessCategory;
  final String? state;
  final String currency;
  final List<String> businessTypes;
  final List<String> businessCategories;
  final List<String> states;
  final List<String> currencies;
  final ValueChanged<String?> onBusinessTypeChanged;
  final ValueChanged<String?> onBusinessCategoryChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Business',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Let's set up your first business.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < _compactBreakpoint;
                  final details = _buildBusinessDetailsColumn();
                  final more = _buildMoreDetailsColumn();
                  final address = _buildAddressColumn();

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: logoColumn),
                        const SizedBox(height: AppSpacing.lg),
                        details,
                        const SizedBox(height: AppSpacing.lg),
                        more,
                        const SizedBox(height: AppSpacing.lg),
                        address,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _mediaColumnWidth,
                        child: logoColumn,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: details),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: more),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: address),
                    ],
                  );
                },
              ),
              if (formState.generalError != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          formState.generalError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: _cardBorder),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm + 4,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  FilledButton(
                    onPressed: formState.isSubmitting ? null : onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.5,
                      ),
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.8,
                      ),
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
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Create Business'),
                              SizedBox(width: AppSpacing.sm),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BusinessProfileSectionHeader(
          title: 'Business Details',
          icon: LucideIcons.store,
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Business Name',
          required: true,
          child: BusinessOutlinedField(
            controller: businessNameController,
            hintText: 'Business Name',
            textCapitalization: TextCapitalization.words,
            suffixIcon: const Icon(
              LucideIcons.idCard,
              size: 18,
              color: AppColors.textSecondary,
            ),
            serverError: formState.errorFor('name'),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                Validators.businessNameMaxLength,
              ),
              FilteringTextInputFormatter.allow(
                Validators.businessNameInputPattern,
              ),
            ],
            validator: Validators.businessName,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Phone',
          required: true,
          child: BusinessOutlinedField(
            controller: phoneController,
            hintText: 'Phone Number',
            keyboardType: TextInputType.phone,
            suffixIcon: const Icon(
              LucideIcons.phone,
              size: 18,
              color: AppColors.textSecondary,
            ),
            serverError: formState.errorFor('phone'),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: Validators.requiredPhone,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'GSTIN',
          child: BusinessOutlinedField(
            controller: gstinController,
            hintText: '15-character GSTIN',
            serverError: formState.errorFor('gstin'),
            inputFormatters: [
              const UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            ],
            validator: Validators.gstin,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Email',
          child: BusinessOutlinedField(
            controller: emailController,
            hintText: 'Email ID',
            keyboardType: TextInputType.emailAddress,
            suffixIcon: const Icon(
              LucideIcons.mail,
              size: 18,
              color: AppColors.textSecondary,
            ),
            serverError: formState.errorFor('email'),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              return Validators.email(trimmed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BusinessProfileSectionHeader(
          title: 'More Details',
          icon: LucideIcons.user,
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Owner Name',
          required: true,
          child: BusinessOutlinedField(
            controller: ownerNameController,
            hintText: 'Owner Name',
            textCapitalization: TextCapitalization.words,
            suffixIcon: const Icon(
              LucideIcons.user,
              size: 18,
              color: AppColors.textSecondary,
            ),
            serverError: formState.errorFor('owner_name'),
            inputFormatters: [
              LengthLimitingTextInputFormatter(Validators.ownerNameMaxLength),
              FilteringTextInputFormatter.allow(
                Validators.businessNameInputPattern,
              ),
            ],
            validator: Validators.ownerName,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Business Type',
          required: true,
          child: BusinessSearchableDropdown(
            value: businessType,
            hintText: 'Business Type',
            items: businessTypes,
            serverError: formState.errorFor('business_type'),
            onChanged: onBusinessTypeChanged,
            validator: (value) => Validators.requiredSelection(
              value,
              fieldName: 'Business type',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Business Category',
          child: BusinessSearchableDropdown(
            value: businessCategory,
            hintText: 'Business Category',
            items: businessCategories,
            serverError: formState.errorFor('business_category'),
            onChanged: onBusinessCategoryChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'State',
          required: true,
          child: BusinessSearchableDropdown(
            value: state,
            hintText: 'State',
            items: states,
            serverError: formState.errorFor('state'),
            onChanged: onStateChanged,
            validator: (value) =>
                Validators.requiredSelection(value, fieldName: 'State'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Currency',
          required: true,
          child: BusinessSearchableDropdown(
            value: currency,
            hintText: 'Currency',
            items: currencies,
            itemLabel: (code) => _currencyLabels[code] ?? code,
            serverError: formState.errorFor('currency'),
            onChanged: onCurrencyChanged,
            validator: (value) =>
                Validators.requiredSelection(value, fieldName: 'Currency'),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BusinessProfileSectionHeader(
          title: 'Address',
          icon: LucideIcons.mapPin,
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessLabeledField(
          label: 'Address',
          child: BusinessOutlinedField(
            controller: addressController,
            hintText: 'Business Address',
            minLines: 4,
            maxLines: 8,
            suffixIcon: const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Icon(
                LucideIcons.mapPin,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            serverError: formState.errorFor('address'),
          ),
        ),
      ],
    );
  }
}
