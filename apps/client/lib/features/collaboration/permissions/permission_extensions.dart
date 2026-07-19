import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension PermissionRefX on WidgetRef {
  bool canView(PermissionModule module) =>
      read(permissionServiceProvider).canView(module);

  bool canCreate(PermissionModule module) =>
      read(permissionServiceProvider).canCreate(module);

  bool canEdit(PermissionModule module) =>
      read(permissionServiceProvider).canEdit(module);

  bool canDelete(PermissionModule module) =>
      read(permissionServiceProvider).canDelete(module);

  bool canShare(PermissionModule module) =>
      read(permissionServiceProvider).canShare(module);
}

extension PermissionContextX on BuildContext {
  bool canView(PermissionModule module, WidgetRef ref) => ref.canView(module);

  bool canCreate(PermissionModule module, WidgetRef ref) =>
      ref.canCreate(module);

  bool canEdit(PermissionModule module, WidgetRef ref) => ref.canEdit(module);

  bool canDelete(PermissionModule module, WidgetRef ref) =>
      ref.canDelete(module);
}
