import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_level.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:flutter/material.dart';

class PermissionMatrixTable extends StatelessWidget {
  const PermissionMatrixTable({
    required this.role,
    this.preset,
    this.compact = false,
    super.key,
  });

  final Role role;
  final PermissionPreset? preset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final matrix = preset ?? RolePermissionRegistry.presetFor(role);
    final moduleWidth = compact ? 180.0 : 220.0;
    final actionWidth = compact ? 56.0 : 72.0;
    final rowHeight = compact ? 30.0 : 40.0;
    final cellPadding = compact
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4)
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${role.displayLabel} Permissions',
          style: TextStyle(
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: AppRadius.mdBorder,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdBorder,
            child: Table(
              columnWidths: {
                0: FixedColumnWidth(moduleWidth),
                for (
                  var i = 0;
                  i < RolePermissionRegistry.allActions.length;
                  i++
                )
                  i + 1: FixedColumnWidth(actionWidth),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
                  children: [
                    _headerCell('Transactions', cellPadding),
                    for (final action in RolePermissionRegistry.allActions)
                      _headerCell(
                        action.displayLabel,
                        cellPadding,
                        centered: true,
                      ),
                  ],
                ),
                for (final row in matrix.rows)
                  TableRow(
                    children: [
                      Padding(
                        padding: cellPadding,
                        child: Text(
                          row.module.displayLabel,
                          style: TextStyle(
                            fontSize: compact ? 12 : 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      for (final action in RolePermissionRegistry.allActions)
                        _levelCell(row.levels[action]!, rowHeight, compact),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(
    String label,
    EdgeInsets padding, {
    bool centered = false,
  }) {
    return Padding(
      padding: padding,
      child: Text(
        label.toUpperCase(),
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _levelCell(PermissionLevel level, double rowHeight, bool compact) {
    return SizedBox(
      height: rowHeight,
      child: Center(
        child: _PermissionLevelIcon(level: level, compact: compact),
      ),
    );
  }
}

class _PermissionLevelIcon extends StatelessWidget {
  const _PermissionLevelIcon({
    required this.level,
    required this.compact,
  });

  final PermissionLevel level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 15.0 : 18.0;

    return switch (level) {
      PermissionLevel.allowed => Icon(
        Icons.check,
        size: iconSize,
        color: const Color(0xFF2E7D32),
      ),
      PermissionLevel.denied => Icon(
        Icons.close,
        size: iconSize,
        color: AppColors.error,
      ),
      PermissionLevel.notApplicable => Text(
        '—',
        style: TextStyle(
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    };
  }
}
