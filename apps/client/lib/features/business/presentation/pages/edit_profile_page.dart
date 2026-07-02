import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_profile_controller.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  static const _saveButtonColor = Color(0xFFD32F2F);

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

  String? _businessType;
  String? _businessCategory;
  String? _state;
  String? _profileSeed;
  String? _hydratedProfileId;

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(businessProfileProvider).asData?.value;
      if (profile != null && mounted) {
        setState(() => _hydrateFromProfile(profile));
      }
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(BusinessProfileModel profile) {
    if (_hydratedProfileId == profile.id) return;

    _businessNameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _gstinController.text = profile.gstin ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _pincodeController.text = profile.pincode ?? '';
    _businessType = profile.businessType;
    _businessCategory = profile.businessCategory;
    _state = profile.state;
    _profileSeed = profile.id;
    _hydratedProfileId = profile.id;
  }

  void _syncDropdownsFromProfile(BusinessProfileModel profile) {
    setState(() {
      _businessType = profile.businessType;
      _businessCategory = profile.businessCategory;
      _state = profile.state;
      _profileSeed = profile.id;
    });
  }

  Future<void> _save() async {
    final input = UpdateBusinessProfileInput(
      name: _businessNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstin: _gstinController.text,
      address: _addressController.text,
      businessType: _businessType,
      businessCategory: _businessCategory,
      state: _state,
      pincode: _pincodeController.text,
    );

    final updated = await ref
        .read(editBusinessProfileFormProvider.notifier)
        .submit(input);

    if (!mounted) return;

    if (updated != null) {
      _syncDropdownsFromProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile saved successfully')),
      );
    }
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
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LogoPlaceholder(
                            name: displayName,
                            logoUrl: profile.logoUrl,
                            seed: _profileSeed ?? profile.id,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
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
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _LabeledField(
                                  label: 'GSTIN',
                                  errorText: formState.errorFor('gstin'),
                                  child: _OutlinedField(
                                    controller: _gstinController,
                                    hintText: 'GSTIN',
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
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
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
                                    items: _businessTypes,
                                    onChanged: (value) =>
                                        setState(() => _businessType = value),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _LabeledField(
                                  label: 'Business Category',
                                  errorText:
                                      formState.errorFor('business_category'),
                                  child: _OutlinedDropdown<String>(
                                    value: _businessCategory,
                                    hintText: 'Business Category',
                                    items: _businessCategories,
                                    onChanged: (value) => setState(
                                      () => _businessCategory = value,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _LabeledField(
                                  label: 'State',
                                  errorText: formState.errorFor('state'),
                                  child: _OutlinedDropdown<String>(
                                    value: _state,
                                    hintText: 'State',
                                    items: _indianStates,
                                    onChanged: (value) =>
                                        setState(() => _state = value),
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
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const _LabeledField(
                                  label: 'Add Signature',
                                  child: _SignatureUploadBox(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: Color(0xFFE0E0E0)),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
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

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({
    required this.name,
    required this.logoUrl,
    required this.seed,
  });

  final String name;
  final String? logoUrl;
  final String seed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(
            shape: _DashedBorderShape.circle,
            color: const Color(0xFFBDBDBD),
          ),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: logoUrl == null
                  ? BusinessAvatar(
                      name: name,
                      seed: seed,
                      diameter: 96,
                    )
                  : const Text(
                      'Add Logo',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Logo upload coming soon',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SignatureUploadBox extends StatelessWidget {
  const _SignatureUploadBox();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        shape: _DashedBorderShape.rectangle,
        color: const Color(0xFFBDBDBD),
        borderRadius: AppRadius.sm,
      ),
      child: const SizedBox(
        width: double.infinity,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload, color: AppColors.textSecondary, size: 24),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DashedBorderShape { circle, rectangle }

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.shape,
    required this.color,
    this.borderRadius = 0,
  });

  final _DashedBorderShape shape;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    if (shape == _DashedBorderShape.circle) {
      _drawDashedCircle(canvas, size, paint, dashWidth, dashSpace);
    } else {
      _drawDashedRect(canvas, size, paint, dashWidth, dashSpace);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Size size,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final radius = size.shortestSide / 2 - paint.strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawDashedRect(
    Canvas canvas,
    Size size,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paint.strokeWidth / 2,
        paint.strokeWidth / 2,
        size.width - paint.strokeWidth,
        size.height - paint.strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
