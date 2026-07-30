import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_profile_controller.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_form_fields.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showEditBusinessModal(
  BuildContext context, {
  required String businessId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final navigator = Navigator.of(context, rootNavigator: true);

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('Loading company details...'),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  BusinessProfileModel profile;
  try {
    profile = await container
        .read(businessListProvider.notifier)
        .fetchProfileForEdit(businessId);
  } on BusinessSelectionFailed catch (error) {
    if (context.mounted) {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
    return null;
  } on Object {
    if (context.mounted) {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load company details. Please try again.'),
        ),
      );
    }
    return null;
  }

  if (context.mounted) {
    navigator.pop();
  }

  if (!context.mounted) return null;

  container.invalidate(editBusinessProfileFormProvider);

  final width = MediaQuery.sizeOf(context).width;
  if (width >= 600) {
    final maxWidth = width >= 720 ? 820.0 : 600.0;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: _EditBusinessSheet(
          profile: profile,
          businessId: businessId,
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
    builder: (context) => _EditBusinessSheet(
      profile: profile,
      businessId: businessId,
      isDialog: false,
    ),
  );
}

class _EditBusinessSheet extends ConsumerStatefulWidget {
  const _EditBusinessSheet({
    required this.profile,
    required this.businessId,
    required this.isDialog,
    this.maxWidth = 820,
  });

  final BusinessProfileModel profile;
  final String businessId;
  final bool isDialog;
  final double maxWidth;

  @override
  ConsumerState<_EditBusinessSheet> createState() => _EditBusinessSheetState();
}

class _EditBusinessSheetState extends ConsumerState<_EditBusinessSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _gstinController;
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;

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

  late String? _businessType;
  late String? _state;
  late List<String> _businessTypeOptions;
  late List<String> _stateOptions;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _businessNameController = TextEditingController(text: profile.name);
    _ownerNameController = TextEditingController(text: profile.ownerName ?? '');
    _phoneController = TextEditingController(text: profile.phone ?? '');
    _emailController = TextEditingController(text: profile.email ?? '');
    _gstinController = TextEditingController(text: profile.gstin ?? '');
    _addressController = TextEditingController(text: profile.address ?? '');
    _currencyController = TextEditingController(text: profile.currency);
    _businessType = profile.businessType;
    _state = profile.state;
    _businessTypeOptions = _withSelectedOption(_businessTypes, _businessType);
    _stateOptions = _withSelectedOption(_states, _state);
  }

  List<String> _withSelectedOption(List<String> options, String? selected) {
    if (selected == null || selected.isEmpty || options.contains(selected)) {
      return options;
    }
    return [selected, ...options];
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  UpdateBusinessProfileInput _buildInput() {
    return UpdateBusinessProfileInput(
      name: _businessNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstin: _gstinController.text,
      businessType: _businessType,
      state: _state,
      address: _addressController.text,
    );
  }

  Future<void> _submit() async {
    final formState = ref.read(editBusinessProfileFormProvider);
    if (formState.isSubmitting) return;

    ref.read(editBusinessProfileFormProvider.notifier).clearErrors();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final updated = await ref
        .read(editBusinessProfileFormProvider.notifier)
        .submit(_buildInput());
    if (!mounted) return;

    if (updated != null) {
      if (updated.id != widget.businessId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved to a different company than expected. Please reopen the Company List and try again.',
            ),
          ),
        );
        return;
      }

      ref.invalidate(editBusinessProfileFormProvider);
      final container = ProviderScope.containerOf(context, listen: false);
      await container.read(businessListProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(editBusinessProfileFormProvider);

    final content = _EditBusinessFormContent(
      formKey: _formKey,
      formState: formState,
      businessNameController: _businessNameController,
      ownerNameController: _ownerNameController,
      phoneController: _phoneController,
      emailController: _emailController,
      gstinController: _gstinController,
      addressController: _addressController,
      businessType: _businessType,
      state: _state,
      currencyController: _currencyController,
      businessTypes: _businessTypeOptions,
      states: _stateOptions,
      onBusinessTypeChanged: (value) => setState(() => _businessType = value),
      onStateChanged: (value) => setState(() => _state = value),
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

class _EditBusinessFormContent extends StatelessWidget {
  const _EditBusinessFormContent({
    required this.formKey,
    required this.formState,
    required this.businessNameController,
    required this.ownerNameController,
    required this.phoneController,
    required this.emailController,
    required this.gstinController,
    required this.addressController,
    required this.businessType,
    required this.state,
    required this.currencyController,
    required this.businessTypes,
    required this.states,
    required this.onBusinessTypeChanged,
    required this.onStateChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final EditBusinessProfileFormState formState;
  final TextEditingController businessNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController gstinController;
  final TextEditingController addressController;
  final String? businessType;
  final String? state;
  final TextEditingController currencyController;
  final List<String> businessTypes;
  final List<String> states;
  final ValueChanged<String?> onBusinessTypeChanged;
  final ValueChanged<String?> onStateChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
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
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Company',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Update your business details.',
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
          BusinessFormRow(
            left: BusinessFormField(
              icon: Icons.store_outlined,
              label: 'Business Name *',
              controller: businessNameController,
              textCapitalization: TextCapitalization.words,
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
            right: BusinessFormField(
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
          ),
          BusinessFormFullWidthField(
            child: BusinessFormRow(
              left: BusinessFormField(
                icon: Icons.badge_outlined,
                label: 'Owner Name',
                controller: ownerNameController,
                textCapitalization: TextCapitalization.words,
                readOnly: true,
              ),
              right: BusinessFormField(
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
            ),
          ),
          BusinessFormFullWidthField(
            child: BusinessFormRow(
              left: BusinessFormField(
                icon: Icons.email_outlined,
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                serverError: formState.errorFor('email'),
                validator: Validators.email,
              ),
              right: BusinessFormDropdown(
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
            ),
          ),
          BusinessFormFullWidthField(
            child: BusinessFormRow(
              left: BusinessFormDropdown(
                icon: Icons.map_outlined,
                label: 'State *',
                value: state,
                serverError: formState.errorFor('state'),
                items: states,
                onChanged: onStateChanged,
                validator: (value) =>
                    Validators.requiredSelection(value, fieldName: 'State'),
              ),
              right: BusinessFormField(
                icon: Icons.currency_rupee,
                label: 'Currency',
                controller: currencyController,
                readOnly: true,
              ),
            ),
          ),
          BusinessFormFullWidthField(
            child: BusinessFormField(
              icon: Icons.home_outlined,
              label: 'Address',
              controller: addressController,
              maxLines: 3,
              serverError: formState.errorFor('address'),
            ),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(120, 48),
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
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: formState.isSubmitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: formState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
