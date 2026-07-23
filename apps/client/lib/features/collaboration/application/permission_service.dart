import 'package:billing_baba/features/collaboration/application/route_permission_registry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_level.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart' show Role;

/// Single authorization API — UI must never compare [Role] directly.
class PermissionService {
  PermissionService(this._session);

  final CompanySession? _session;

  bool get hasSession => _session != null;

  bool get hasFullAccess => _session?.hasFullAccess ?? false;

  /// Owner and secondary admin (manager equivalent) may view hidden ledger data.
  bool get canViewHiddenLedger =>
      hasFullAccess || _session?.role == Role.secondaryAdmin;

  bool canView(PermissionModule module) =>
      _can(module, PermissionAction.view);

  bool canCreate(PermissionModule module) =>
      _can(module, PermissionAction.create);

  bool canEdit(PermissionModule module) =>
      _can(module, PermissionAction.edit);

  bool canDelete(PermissionModule module) =>
      _can(module, PermissionAction.delete);

  bool canShare(PermissionModule module) =>
      _can(module, PermissionAction.share);

  bool canAccessRoute(String route) {
    return RoutePermissionRegistry.canAccessRoute(route, this);
  }

  bool _can(PermissionModule module, PermissionAction action) {
    if (_session == null) return false;
    if (hasFullAccess) return true;
    return _level(module, action) == PermissionLevel.allowed;
  }

  PermissionLevel _level(PermissionModule module, PermissionAction action) {
    final preset = _session!.permissionPreset;
    final row = _findRow(preset, module);
    if (row == null) return PermissionLevel.denied;
    return row.levels[action] ?? PermissionLevel.denied;
  }

  PermissionRow? _findRow(PermissionPreset preset, PermissionModule module) {
    for (final row in preset.rows) {
      if (row.module == module) return row;
    }
    return null;
  }
}
