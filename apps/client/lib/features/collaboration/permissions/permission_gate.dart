import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    required this.module,
    required this.action,
    required this.child,
    this.fallback,
    super.key,
  });

  final PermissionModule module;
  final PermissionAction action;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(permissionServiceProvider);
    final allowed = switch (action) {
      PermissionAction.view => service.canView(module),
      PermissionAction.create => service.canCreate(module),
      PermissionAction.edit => service.canEdit(module),
      PermissionAction.delete => service.canDelete(module),
      PermissionAction.share => service.canShare(module),
    };

    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
