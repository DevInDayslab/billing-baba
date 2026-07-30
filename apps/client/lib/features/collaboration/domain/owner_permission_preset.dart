import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_level.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';

/// Full-access preset for company owners. Do not modify [RolePermissionRegistry].
abstract final class OwnerPermissionPreset {
  static const PermissionLevel _allowed = PermissionLevel.allowed;

  static PermissionPreset get preset {
    final rows = PermissionModule.values.map((module) {
      return PermissionRow(
        module: module,
        levels: {
          for (final action in RolePermissionRegistry.allActions)
            action: _allowed,
        },
      );
    }).toList();

    // Role is unused for owners — [PermissionService] short-circuits on owner.
    return PermissionPreset(role: Role.secondaryAdmin, rows: rows);
  }

  static PermissionLevel levelFor(
    PermissionModule module,
    PermissionAction action,
  ) {
    return _allowed;
  }
}
