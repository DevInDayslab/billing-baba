import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_profile.freezed.dart';
part 'account_profile.g.dart';

@freezed
abstract class AccountProfile with _$AccountProfile {
  const factory AccountProfile({
    required String phone, @JsonKey(name: 'display_name') String? displayName,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('Asia/Kolkata') String timezone,
    @Default('en') String language,
  }) = _AccountProfile;

  factory AccountProfile.fromJson(Map<String, dynamic> json) =>
      _$AccountProfileFromJson(json);
}
