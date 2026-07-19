// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invitation {

 String get id;@JsonKey(name: 'invite_code') String get inviteCode;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'phone_or_email') String get phoneOrEmail; Role get role; InvitationChannel get channel;@JsonKey(name: 'sent_at') DateTime get sentAt;@JsonKey(name: 'expires_at') DateTime get expiresAt; InvitationStatus get status;
/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCopyWith<Invitation> get copyWith => _$InvitationCopyWithImpl<Invitation>(this as Invitation, _$identity);

  /// Serializes this Invitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invitation&&(identical(other.id, id) || other.id == id)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneOrEmail, phoneOrEmail) || other.phoneOrEmail == phoneOrEmail)&&(identical(other.role, role) || other.role == role)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inviteCode,memberId,fullName,phoneOrEmail,role,channel,sentAt,expiresAt,status);

@override
String toString() {
  return 'Invitation(id: $id, inviteCode: $inviteCode, memberId: $memberId, fullName: $fullName, phoneOrEmail: $phoneOrEmail, role: $role, channel: $channel, sentAt: $sentAt, expiresAt: $expiresAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $InvitationCopyWith<$Res>  {
  factory $InvitationCopyWith(Invitation value, $Res Function(Invitation) _then) = _$InvitationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'invite_code') String inviteCode,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_or_email') String phoneOrEmail, Role role, InvitationChannel channel,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'expires_at') DateTime expiresAt, InvitationStatus status
});




}
/// @nodoc
class _$InvitationCopyWithImpl<$Res>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._self, this._then);

  final Invitation _self;
  final $Res Function(Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inviteCode = null,Object? memberId = null,Object? fullName = null,Object? phoneOrEmail = null,Object? role = null,Object? channel = null,Object? sentAt = null,Object? expiresAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneOrEmail: null == phoneOrEmail ? _self.phoneOrEmail : phoneOrEmail // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as InvitationChannel,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Invitation].
extension InvitationPatterns on Invitation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invitation value)  $default,){
final _that = this;
switch (_that) {
case _Invitation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invitation value)?  $default,){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  Role role,  InvitationChannel channel, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  InvitationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.inviteCode,_that.memberId,_that.fullName,_that.phoneOrEmail,_that.role,_that.channel,_that.sentAt,_that.expiresAt,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  Role role,  InvitationChannel channel, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  InvitationStatus status)  $default,) {final _that = this;
switch (_that) {
case _Invitation():
return $default(_that.id,_that.inviteCode,_that.memberId,_that.fullName,_that.phoneOrEmail,_that.role,_that.channel,_that.sentAt,_that.expiresAt,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  Role role,  InvitationChannel channel, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  InvitationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.inviteCode,_that.memberId,_that.fullName,_that.phoneOrEmail,_that.role,_that.channel,_that.sentAt,_that.expiresAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invitation implements Invitation {
  const _Invitation({required this.id, @JsonKey(name: 'invite_code') required this.inviteCode, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'phone_or_email') required this.phoneOrEmail, required this.role, required this.channel, @JsonKey(name: 'sent_at') required this.sentAt, @JsonKey(name: 'expires_at') required this.expiresAt, required this.status});
  factory _Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'invite_code') final  String inviteCode;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'phone_or_email') final  String phoneOrEmail;
@override final  Role role;
@override final  InvitationChannel channel;
@override@JsonKey(name: 'sent_at') final  DateTime sentAt;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override final  InvitationStatus status;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationCopyWith<_Invitation> get copyWith => __$InvitationCopyWithImpl<_Invitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invitation&&(identical(other.id, id) || other.id == id)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneOrEmail, phoneOrEmail) || other.phoneOrEmail == phoneOrEmail)&&(identical(other.role, role) || other.role == role)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inviteCode,memberId,fullName,phoneOrEmail,role,channel,sentAt,expiresAt,status);

@override
String toString() {
  return 'Invitation(id: $id, inviteCode: $inviteCode, memberId: $memberId, fullName: $fullName, phoneOrEmail: $phoneOrEmail, role: $role, channel: $channel, sentAt: $sentAt, expiresAt: $expiresAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InvitationCopyWith<$Res> implements $InvitationCopyWith<$Res> {
  factory _$InvitationCopyWith(_Invitation value, $Res Function(_Invitation) _then) = __$InvitationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'invite_code') String inviteCode,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_or_email') String phoneOrEmail, Role role, InvitationChannel channel,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'expires_at') DateTime expiresAt, InvitationStatus status
});




}
/// @nodoc
class __$InvitationCopyWithImpl<$Res>
    implements _$InvitationCopyWith<$Res> {
  __$InvitationCopyWithImpl(this._self, this._then);

  final _Invitation _self;
  final $Res Function(_Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inviteCode = null,Object? memberId = null,Object? fullName = null,Object? phoneOrEmail = null,Object? role = null,Object? channel = null,Object? sentAt = null,Object? expiresAt = null,Object? status = null,}) {
  return _then(_Invitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneOrEmail: null == phoneOrEmail ? _self.phoneOrEmail : phoneOrEmail // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as InvitationChannel,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,
  ));
}


}

// dart format on
