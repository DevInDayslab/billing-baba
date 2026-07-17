import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';

class AddLeadInput {
  const AddLeadInput({
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.leadSource,
    this.status = LeadStatus.newLead,
    this.assignedTo,
    this.notes,
    this.salutation,
    this.firstName,
    this.lastName,
    this.title,
    this.mobile,
    this.fax,
    this.website,
    this.industry,
    this.annualRevenue,
    this.emailOptOut = false,
    this.noOfEmployees,
    this.rating,
    this.secondaryEmail,
    this.description,
  });

  final String name;
  final String phone;
  final String? email;
  final String? company;
  final LeadSource? leadSource;
  final LeadStatus status;
  final String? assignedTo;
  final String? notes;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? title;
  final String? mobile;
  final String? fax;
  final String? website;
  final String? industry;
  final String? annualRevenue;
  final bool emailOptOut;
  final String? noOfEmployees;
  final String? rating;
  final String? secondaryEmail;
  final String? description;
}

class LeadWithActivities {
  const LeadWithActivities({
    required this.lead,
    required this.activities,
  });

  final Lead lead;
  final List<LeadActivity> activities;
}

class LeadQueryFilters {
  const LeadQueryFilters({
    this.searchQuery = '',
    this.status,
    this.leadSource,
    this.dateFrom,
    this.dateTo,
  });

  final String searchQuery;
  final LeadStatus? status;
  final LeadSource? leadSource;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  LeadQueryFilters copyWith({
    String? searchQuery,
    LeadStatus? Function()? status,
    LeadSource? Function()? leadSource,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
  }) {
    return LeadQueryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status != null ? status() : this.status,
      leadSource: leadSource != null ? leadSource() : this.leadSource,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
    );
  }
}

class LeadBusinessNotSelectedException implements Exception {
  const LeadBusinessNotSelectedException();
}

class LeadValidationException implements Exception {
  const LeadValidationException(this.message);

  final String message;
}
