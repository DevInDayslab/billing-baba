import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CollaborationPageSkeleton extends StatelessWidget {
  const CollaborationPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _block(height: 36, width: 200),
        const SizedBox(height: AppSpacing.lg),
        _block(height: 20, width: 260),
        const SizedBox(height: AppSpacing.xl),
        _block(height: 24, width: 100),
        const SizedBox(height: AppSpacing.md),
        _block(height: 280),
      ],
    );
  }

  Widget _block({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: AppRadius.mdBorder,
      ),
    );
  }
}
