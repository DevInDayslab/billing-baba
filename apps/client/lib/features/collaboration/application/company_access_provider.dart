import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_access_provider.g.dart';

@Riverpod(keepAlive: true)
Future<CompanyAccess> companyAccess(Ref ref) async {
  ref.watch(collaborationInitProvider);
  final service = ref.watch(collaborationServiceProvider);
  return service.fetchCompany();
}
