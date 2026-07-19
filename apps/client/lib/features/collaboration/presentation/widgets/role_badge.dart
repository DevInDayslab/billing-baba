import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Text(
      role.displayLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
    );
  }
}
