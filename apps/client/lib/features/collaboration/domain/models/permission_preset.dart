import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_level.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';

/// A single row in a role permission matrix.
class PermissionRow {
  const PermissionRow({
    required this.module,
    required this.levels,
  });

  final PermissionModule module;
  final Map<PermissionAction, PermissionLevel> levels;
}

/// Fixed permission preset for a role.
class PermissionPreset {
  const PermissionPreset({
    required this.role,
    required this.rows,
  });

  final Role role;
  final List<PermissionRow> rows;
}
