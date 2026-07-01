import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SingleChildScrollView(
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
                      const _LogoPlaceholder(),
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
                              child: _OutlinedField(
                                controller: _businessNameController,
                                hintText: 'Business Name',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'Phone Number',
                              child: _OutlinedField(
                                controller: _phoneController,
                                hintText: 'Phone Number',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'GSTIN',
                              child: _OutlinedField(
                                controller: _gstinController,
                                hintText: 'GSTIN',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'Email ID',
                              child: _OutlinedField(
                                controller: _emailController,
                                hintText: 'Email ID',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'Business Address',
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
                              child: _OutlinedDropdown<String>(
                                value: _businessCategory,
                                hintText: 'Business Category',
                                items: _businessCategories,
                                onChanged: (value) =>
                                    setState(() => _businessCategory = value),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'State',
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
                              child: _OutlinedField(
                                controller: _pincodeController,
                                hintText: 'Pincode',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LabeledField(
                              label: 'Add Signature',
                              child: _SignatureUploadBox(onTap: () {}),
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
                        onPressed: () => context.pop(),
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
                        onPressed: () => debugPrint('saved'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _saveButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm + 4,
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
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
  });

  final String label;
  final Widget child;
  final bool required;

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
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        shape: _DashedBorderShape.circle,
        color: const Color(0xFFBDBDBD),
      ),
      child: const SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            'Add Logo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SignatureUploadBox extends StatelessWidget {
  const _SignatureUploadBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomPaint(
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
                'Upload Signature',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
