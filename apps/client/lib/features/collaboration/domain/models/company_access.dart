import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_access.freezed.dart';
part 'company_access.g.dart';

@freezed
abstract class CompanyAccess with _$CompanyAccess {
  const factory CompanyAccess({
    @JsonKey(name: 'business_name') required String businessName,
    @JsonKey(name: 'owner_name') required String ownerName,
    @JsonKey(name: 'owner_phone') required String ownerPhone,
    @JsonKey(name: 'total_members') required int totalMembers,
    @JsonKey(name: 'logged_in_phone') required String loggedInPhone,
  }) = _CompanyAccess;

  factory CompanyAccess.fromJson(Map<String, dynamic> json) =>
      _$CompanyAccessFromJson(json);
}
