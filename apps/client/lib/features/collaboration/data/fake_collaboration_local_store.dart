import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCollaborationLocalStore {
  String _membersKey(String businessId) =>
      '${StorageKeys.collaborationMembers}_$businessId';

  String _invitationsKey(String businessId) =>
      '${StorageKeys.collaborationInvitations}_$businessId';

  Future<
    ({
      List<BusinessMember> members,
      List<Invitation> invitations,
    })?
  >
  load(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    final membersRaw = prefs.getString(_membersKey(businessId));
    final invitationsRaw = prefs.getString(_invitationsKey(businessId));
    if (membersRaw == null || invitationsRaw == null) return null;

    try {
      final membersDecoded = jsonDecode(membersRaw);
      final invitationsDecoded = jsonDecode(invitationsRaw);
      if (membersDecoded is! List || invitationsDecoded is! List) return null;

      return (
        members: membersDecoded
            .whereType<Map<Object?, Object?>>()
            .map(
              (entry) => BusinessMember.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList(),
        invitations: invitationsDecoded
            .whereType<Map<Object?, Object?>>()
            .map(
              (entry) => Invitation.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> save({
    required String businessId,
    required List<BusinessMember> members,
    required List<Invitation> invitations,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _membersKey(businessId),
      jsonEncode(members.map((member) => member.toJson()).toList()),
    );
    await prefs.setString(
      _invitationsKey(businessId),
      jsonEncode(invitations.map((invitation) => invitation.toJson()).toList()),
    );
  }
}
