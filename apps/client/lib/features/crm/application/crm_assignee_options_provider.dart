import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/application/members_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crm_assignee_options_provider.g.dart';

const crmOwnerNoneOption = '-None-';
const crmOwnerAllOption = 'All Owners';

List<String> assignableMemberNames(List<BusinessMember> members) {
  final names = members
      .where((member) => member.isOwner || member.status.isJoined)
      .map((member) => member.fullName.trim())
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names;
}

@Riverpod(keepAlive: true)
Future<List<String>> crmAssigneeNames(Ref ref) async {
  ref.watch(collaborationInitProvider);
  final members = await ref.watch(membersProvider.future);
  return assignableMemberNames(members);
}

@Riverpod(keepAlive: true)
Future<List<String>> crmAssigneeFormOptions(Ref ref) async {
  final names = await ref.watch(crmAssigneeNamesProvider.future);
  return [crmOwnerNoneOption, ...names];
}

@Riverpod(keepAlive: true)
Future<List<String>> crmAssigneeFilterOptions(Ref ref) async {
  final names = await ref.watch(crmAssigneeNamesProvider.future);
  return [crmOwnerAllOption, ...names];
}

@riverpod
String? crmDefaultOwnerName(Ref ref) {
  final session = ref.watch(companySessionProvider);
  final namesAsync = ref.watch(crmAssigneeNamesProvider);
  return namesAsync.maybeWhen(
    data: (names) {
      final current = session?.currentUserName.trim();
      if (current == null || current.isEmpty) return null;
      return names.contains(current) ? current : null;
    },
    orElse: () => null,
  );
}
