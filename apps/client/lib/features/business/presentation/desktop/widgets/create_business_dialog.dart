import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/create_business_controller.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_form_fields.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showCreateBusinessModal(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 600) {
    final maxWidth = width >= 720 ? 740.0 : 560.0;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
    this.maxWidth = 740,
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

  static const _states = [
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
    'Gujarat',
    'Rajasthan',
    'West Bengal',
  ];

  String? _businessType;
  String? _state;
  String _currency = 'INR';
  var _prefilled = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

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
    final name = auth.session?.user.name;
    if (name != null && name.isNotEmpty) {
      _ownerNameController.text = name;
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
      state: _state ?? '',
      currency: _currency,
      address: _addressController.text,
    );
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
      businessNameController: _businessNameController,
      ownerNameController: _ownerNameController,
      phoneController: _phoneController,
      emailController: _emailController,
      gstinController: _gstinController,
      addressController: _addressController,
      businessType: _businessType,
      state: _state,
      currency: _currency,
      businessTypes: _businessTypes,
      states: _states,
      onBusinessTypeChanged: (value) => setState(() => _businessType = value),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
    required this.businessNameController,
    required this.ownerNameController,
    required this.phoneController,
    required this.emailController,
    required this.gstinController,
    required this.addressController,
    required this.businessType,
    required this.state,
    required this.currency,
    required this.businessTypes,
    required this.states,
    required this.onBusinessTypeChanged,
    required this.onStateChanged,
    required this.onCurrencyChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final CreateBusinessFormState formState;
  final TextEditingController businessNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController gstinController;
  final TextEditingController addressController;
  final String? businessType;
  final String? state;
  final String currency;
  final List<String> businessTypes;
  final List<String> states;
  final ValueChanged<String?> onBusinessTypeChanged;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Business',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const BusinessFormSectionHeader(
            title: 'Business Details',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.store_outlined,
            label: 'Business Name *',
            controller: businessNameController,
            textCapitalization: TextCapitalization.words,
            serverError: formState.errorFor('name'),
            inputFormatters: [
              LengthLimitingTextInputFormatter(Validators.businessNameMaxLength),
              FilteringTextInputFormatter.allow(
                Validators.businessNameInputPattern,
              ),
            ],
            validator: Validators.businessName,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.receipt_long_outlined,
            label: 'GSTIN',
            controller: gstinController,
            hint: '15-character GSTIN',
            serverError: formState.errorFor('gstin'),
            inputFormatters: [
              const UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            ],
            validator: Validators.gstin,
          ),
          const SizedBox(height: AppSpacing.xl),
          const BusinessFormSectionHeader(
            title: 'Owner Details',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.badge_outlined,
            label: 'Owner Name *',
            controller: ownerNameController,
            textCapitalization: TextCapitalization.words,
            serverError: formState.errorFor('owner_name'),
            inputFormatters: [
              LengthLimitingTextInputFormatter(Validators.ownerNameMaxLength),
              FilteringTextInputFormatter.allow(
                Validators.businessNameInputPattern,
              ),
            ],
            validator: Validators.ownerName,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.phone_outlined,
            label: 'Phone *',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            serverError: formState.errorFor('phone'),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: Validators.requiredPhone,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.email_outlined,
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            serverError: formState.errorFor('email'),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              return Validators.email(trimmed);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const BusinessFormSectionHeader(
            title: 'Business Information',
            icon: Icons.info_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormDropdown(
            icon: Icons.category_outlined,
            label: 'Business Type *',
            value: businessType,
            serverError: formState.errorFor('business_type'),
            items: businessTypes,
            onChanged: onBusinessTypeChanged,
            validator: (value) => Validators.requiredSelection(
              value,
              fieldName: 'Business type',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormDropdown(
            icon: Icons.map_outlined,
            label: 'State *',
            value: state,
            serverError: formState.errorFor('state'),
            items: states,
            onChanged: onStateChanged,
            validator: (value) =>
                Validators.requiredSelection(value, fieldName: 'State'),
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormDropdown(
            icon: Icons.currency_rupee,
            label: 'Currency *',
            value: currency,
            serverError: formState.errorFor('currency'),
            items: const ['INR'],
            onChanged: onCurrencyChanged,
            validator: (value) =>
                Validators.requiredSelection(value, fieldName: 'Currency'),
          ),
          const SizedBox(height: AppSpacing.xl),
          const BusinessFormSectionHeader(
            title: 'Address',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          BusinessFormField(
            icon: Icons.home_outlined,
            label: 'Address',
            controller: addressController,
            maxLines: 3,
            serverError: formState.errorFor('address'),
          ),
          if (formState.generalError != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdBorder,
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
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(0, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
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
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: formState.isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Creating Business...',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Create Business',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
