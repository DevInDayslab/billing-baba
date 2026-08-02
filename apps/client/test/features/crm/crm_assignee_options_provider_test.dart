import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/crm/application/crm_assignee_options_provider.dart';
import 'package:flutter_test/flutter_test.dart';

BusinessMember _member({
  required String id,
  required String fullName,
  MemberStatus status = MemberStatus.joined,
  bool isOwner = false,
}) {
  return BusinessMember(
    id: id,
    fullName: fullName,
    phoneOrEmail: '+911234567890',
    status: status,
    role: Role.biller,
    invitedAt: DateTime(2026),
    isOwner: isOwner,
  );
}

void main() {
  test('assignableMemberNames includes owner and joined members only', () {
    final names = assignableMemberNames([
      _member(id: 'owner-1', fullName: 'Owner User', isOwner: true),
      _member(id: 'm-1', fullName: 'Joined User'),
      _member(
        id: 'm-2',
        fullName: 'Pending User',
        status: MemberStatus.pending,
      ),
      _member(id: 'm-3', fullName: 'Joined User'),
    ]);

    expect(names, ['Joined User', 'Owner User']);
  });
}
