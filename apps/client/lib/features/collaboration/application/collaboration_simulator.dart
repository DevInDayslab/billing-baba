import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:flutter/foundation.dart';

/// Simulates backend side-effects by printing formatted output to the terminal.
abstract final class CollaborationSimulator {
  static void log(String title, Map<String, String> fields) {
    final buffer = StringBuffer()
      ..writeln('=================================')
      ..writeln(title)
      ..writeln();
    for (final entry in fields.entries) {
      buffer.writeln('${entry.key}:');
      buffer.writeln(entry.value);
      buffer.writeln();
    }
    buffer.writeln('=================================');
    debugPrint(buffer.toString());
  }

  static void inviteUser({
    required String name,
    required String role,
    required String contact,
    required String invitationLink,
  }) {
    log('INVITE USER', {
      'Name': name,
      'Role': role,
      'Phone': contact.contains('@') ? '—' : contact,
      'Email': contact.contains('@') ? contact : '—',
      'Invitation': invitationLink,
    });
  }

  static void updateMember({
    required String name,
    required String role,
    required String contact,
  }) {
    log('UPDATE MEMBER', {
      'Name': name,
      'Role': role,
      'Contact': contact,
    });
  }

  static void deleteMember({required String name, required String contact}) {
    log('DELETE MEMBER', {
      'Name': name,
      'Contact': contact,
    });
  }

  static void changeRole({
    required String name,
    required Role from,
    required Role to,
  }) {
    log('CHANGE ROLE', {
      'Name': name,
      'From': from.displayLabel,
      'To': to.displayLabel,
    });
  }

  static void refresh({required String timestamp}) {
    log('REFRESH', {'Timestamp': timestamp});
  }

  static void enableSync() => log('ENABLE SYNC', {});

  static void disableSync() => log('DISABLE SYNC', {});

  static void logout() => log('LOGOUT', {});

  static void generateLink({required String link}) {
    log('GENERATE LINK', {'Invitation': link});
  }

  static void copyLink({required String link}) {
    log('COPY LINK', {'Invitation': link});
  }

  static void shareWhatsApp({
    required String phone,
    required String role,
    required String link,
  }) {
    debugPrint('''
====================================
WHATSAPP INVITE
To:
$phone

Message:

You have been invited to collaborate on Billing Baba.

Role:
$role

Invitation:
$link
====================================''');
  }

  static void sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) {
    debugPrint('''
====================================
EMAIL INVITATION

Recipient:
$recipient

Subject:
$subject

Body:
$body
====================================''');
  }

  static void acceptInvitation({
    required String name,
    required String link,
  }) {
    log('ACCEPT INVITATION', {
      'Name': name,
      'Invitation': link,
    });
  }

  static void rejectInvitation({
    required String name,
    required String link,
  }) {
    log('REJECT INVITATION', {
      'Name': name,
      'Invitation': link,
    });
  }

  static void cancelInvitation({
    required String name,
    required String link,
  }) {
    log('CANCEL INVITATION', {
      'Name': name,
      'Invitation': link,
    });
  }
}
