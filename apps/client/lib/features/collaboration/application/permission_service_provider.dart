import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentRoleProvider = Provider<Role?>((ref) {
  final session = ref.watch(companySessionProvider);
  return session?.role;
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final session = ref.watch(companySessionProvider);
  return PermissionService(session);
});
