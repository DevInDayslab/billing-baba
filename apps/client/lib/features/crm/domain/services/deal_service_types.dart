import 'package:billing_baba/features/crm/domain/models/deal.dart';

class DealQueryFilters {
  const DealQueryFilters({
    this.searchQuery = '',
    this.accountName,
    this.assignedTo,
    this.stage,
    this.dateFrom,
    this.dateTo,
  });

  final String searchQuery;
  final String? accountName;
  final String? assignedTo;
  final DealStage? stage;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  DealQueryFilters copyWith({
    String? searchQuery,
    String? Function()? accountName,
    String? Function()? assignedTo,
    DealStage? Function()? stage,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
  }) {
    return DealQueryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      accountName: accountName != null ? accountName() : this.accountName,
      assignedTo: assignedTo != null ? assignedTo() : this.assignedTo,
      stage: stage != null ? stage() : this.stage,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
    );
  }
}

class AddDealServiceInput {
  const AddDealServiceInput({
    required this.name,
    this.stage = DealStage.qualification,
    this.accountName,
    this.assignedTo,
    this.amount = 0,
    this.expectedCloseDate,
    this.description,
  });

  final String name;
  final DealStage stage;
  final String? accountName;
  final String? assignedTo;
  final double amount;
  final DateTime? expectedCloseDate;
  final String? description;

  factory AddDealServiceInput.fromDialogInput({
    required String name,
    DealStage stage = DealStage.qualification,
    String? accountName,
    String? owner,
    double amount = 0,
    DateTime? expectedCloseDate,
    String? description,
  }) {
    return AddDealServiceInput(
      name: name,
      stage: stage,
      accountName: accountName,
      assignedTo: owner,
      amount: amount,
      expectedCloseDate: expectedCloseDate,
      description: description,
    );
  }
}

class DealBusinessNotSelectedException implements Exception {
  const DealBusinessNotSelectedException();

  @override
  String toString() => 'No business selected';
}

class DealValidationException implements Exception {
  const DealValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
