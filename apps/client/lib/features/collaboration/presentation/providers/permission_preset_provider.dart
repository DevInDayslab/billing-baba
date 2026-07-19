import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_preset_provider.g.dart';

@riverpod
PermissionPreset permissionPreset(Ref ref, Role role) {
  return RolePermissionRegistry.presetFor(role);
}
