import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_summary.freezed.dart';
part 'business_summary.g.dart';

@freezed
abstract class BusinessSummary with _$BusinessSummary {
  const factory BusinessSummary({
    required String id,
    required String name,
    required String role,
    String? gstin,
  }) = _BusinessSummary;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) =>
      _$BusinessSummaryFromJson(json);
}
