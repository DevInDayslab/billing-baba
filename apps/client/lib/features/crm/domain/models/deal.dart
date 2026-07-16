import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

enum DealStage {
  @JsonValue('qualification')
  qualification,
  @JsonValue('needs_analysis')
  needsAnalysis,
  @JsonValue('value_proposition')
  valueProposition,
  @JsonValue('identify_decision_makers')
  identifyDecisionMakers,
  @JsonValue('proposal_price_quote')
  proposalPriceQuote,
  @JsonValue('negotiation_review')
  negotiationReview,
  @JsonValue('closed_won')
  closedWon,
  @JsonValue('closed_lost')
  closedLost,
  @JsonValue('closed_lost_to_competition')
  closedLostToCompetition,
}

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    @Default(DealStage.qualification) DealStage stage,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @Default(0) double amount,
    @JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate,
    String? description,
    @JsonKey(name: 'sync_version') @Default(1) int syncVersion,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'device_id') @Default('') String deviceId,
    @JsonKey(name: 'sync_status') @Default('pending') String syncStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}

extension DealStageX on DealStage {
  String get label => switch (this) {
    DealStage.qualification => 'Qualification',
    DealStage.needsAnalysis => 'Needs Analysis',
    DealStage.valueProposition => 'Value Proposition',
    DealStage.identifyDecisionMakers => 'Id. Decision Makers',
    DealStage.proposalPriceQuote => 'Proposal/Price Quote',
    DealStage.negotiationReview => 'Negotiation/Review',
    DealStage.closedWon => 'Closed Won',
    DealStage.closedLost => 'Closed Lost',
    DealStage.closedLostToCompetition => 'Closed Lost to Competition',
  };

  int get probability => switch (this) {
    DealStage.qualification => 10,
    DealStage.needsAnalysis => 20,
    DealStage.valueProposition => 40,
    DealStage.identifyDecisionMakers => 60,
    DealStage.proposalPriceQuote => 75,
    DealStage.negotiationReview => 90,
    DealStage.closedWon => 100,
    DealStage.closedLost => 0,
    DealStage.closedLostToCompetition => 0,
  };

  bool get isClosed =>
      this == DealStage.closedWon ||
      this == DealStage.closedLost ||
      this == DealStage.closedLostToCompetition;

  bool get isWon => this == DealStage.closedWon;

  bool get isLost =>
      this == DealStage.closedLost || this == DealStage.closedLostToCompetition;

  String get wireValue => switch (this) {
    DealStage.qualification => 'qualification',
    DealStage.needsAnalysis => 'needs_analysis',
    DealStage.valueProposition => 'value_proposition',
    DealStage.identifyDecisionMakers => 'identify_decision_makers',
    DealStage.proposalPriceQuote => 'proposal_price_quote',
    DealStage.negotiationReview => 'negotiation_review',
    DealStage.closedWon => 'closed_won',
    DealStage.closedLost => 'closed_lost',
    DealStage.closedLostToCompetition => 'closed_lost_to_competition',
  };

  static DealStage fromWire(String value) {
    return DealStage.values.firstWhere(
      (stage) => stage.wireValue == value,
      orElse: () => DealStage.qualification,
    );
  }

  static List<DealStage> get pipelineStages => const [
    DealStage.qualification,
    DealStage.needsAnalysis,
    DealStage.valueProposition,
    DealStage.identifyDecisionMakers,
    DealStage.proposalPriceQuote,
    DealStage.negotiationReview,
    DealStage.closedWon,
    DealStage.closedLost,
    DealStage.closedLostToCompetition,
  ];
}

extension DealX on Deal {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static String displayOrDash(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  String get displayAccountName => displayOrDash(accountName);
  String get displayAssignedTo => displayOrDash(assignedTo);
  String get displayAmount => _currencyFormat.format(amount);
  String get displayCloseDate =>
      expectedCloseDate == null ? '—' : _dateFormat.format(expectedCloseDate!);
}
