import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_section_header.dart';
import 'package:flutter/material.dart';

/// Groups mobile list rows under a shared section header.
class MobileListSection extends StatelessWidget {
  const MobileListSection({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.trailing,
    this.headerPadding,
    this.contentPadding,
    this.spacing = AppSpacing.sm,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileSectionHeader(
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          padding: headerPadding,
        ),
        Padding(
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: spacing),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
