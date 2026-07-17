import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/models/contact_activity.dart';

class AddContactServiceInput {
  const AddContactServiceInput({
    required this.name,
    required this.phone,
    this.email,
    this.accountName,
    this.assignedTo,
    this.salutation,
    this.firstName,
    this.lastName,
    this.title,
    this.description,
  });

  final String name;
  final String phone;
  final String? email;
  final String? accountName;
  final String? assignedTo;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? title;
  final String? description;

  factory AddContactServiceInput.fromDialogInput({
    required String name,
    required String phone,
    String? email,
    String? accountName,
    String? owner,
    String? salutation,
    String? firstName,
    String? lastName,
    String? title,
    String? description,
    String? leadSource,
    String? otherPhone,
    String? mobile,
    String? assistant,
    String? vendorName,
    String? department,
    String? homePhone,
    String? fax,
    DateTime? dateOfBirth,
    String? asstPhone,
    bool emailOptOut = false,
  }) {
    return AddContactServiceInput(
      name: name,
      phone: phone,
      email: email,
      accountName: accountName,
      assignedTo: owner,
      salutation: salutation,
      firstName: firstName,
      lastName: lastName,
      title: title,
      description: composeContactDescription(
        description: description,
        leadSource: leadSource,
        otherPhone: otherPhone,
        mobile: mobile,
        assistant: assistant,
        vendorName: vendorName,
        department: department,
        homePhone: homePhone,
        fax: fax,
        dateOfBirth: dateOfBirth,
        asstPhone: asstPhone,
        emailOptOut: emailOptOut,
      ),
    );
  }
}

String? composeContactDescription({
  String? description,
  String? leadSource,
  String? otherPhone,
  String? mobile,
  String? assistant,
  String? vendorName,
  String? department,
  String? homePhone,
  String? fax,
  DateTime? dateOfBirth,
  String? asstPhone,
  bool emailOptOut = false,
}) {
  final lines = <String>[];

  void addLine(String label, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    lines.add('$label: $trimmed');
  }

  addLine('Lead Source', leadSource);
  addLine('Vendor Name', vendorName);
  addLine('Department', department);
  addLine('Other Phone', otherPhone);
  addLine('Mobile', mobile);
  addLine('Home Phone', homePhone);
  addLine('Fax', fax);
  addLine('Assistant', assistant);
  addLine('Asst Phone', asstPhone);
  if (dateOfBirth != null) {
    lines.add(
      'Date of Birth: ${dateOfBirth.day.toString().padLeft(2, '0')}/'
      '${dateOfBirth.month.toString().padLeft(2, '0')}/'
      '${dateOfBirth.year}',
    );
  }
  if (emailOptOut) {
    lines.add('Email Opt Out: Yes');
  }

  final trimmedDescription = description?.trim();
  if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
    if (lines.isNotEmpty) lines.add('');
    lines.add(trimmedDescription);
  }

  if (lines.isEmpty) return null;
  return lines.join('\n');
}

class ContactWithActivities {
  const ContactWithActivities({
    required this.contact,
    required this.activities,
  });

  final Contact contact;
  final List<ContactActivity> activities;
}

class ContactQueryFilters {
  const ContactQueryFilters({
    this.searchQuery = '',
    this.accountName,
    this.assignedTo,
    this.dateFrom,
    this.dateTo,
  });

  final String searchQuery;
  final String? accountName;
  final String? assignedTo;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ContactQueryFilters copyWith({
    String? searchQuery,
    String? Function()? accountName,
    String? Function()? assignedTo,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
  }) {
    return ContactQueryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      accountName: accountName != null ? accountName() : this.accountName,
      assignedTo: assignedTo != null ? assignedTo() : this.assignedTo,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
    );
  }
}

class ContactBusinessNotSelectedException implements Exception {
  const ContactBusinessNotSelectedException();
}

class ContactValidationException implements Exception {
  const ContactValidationException(this.message);

  final String message;
}
