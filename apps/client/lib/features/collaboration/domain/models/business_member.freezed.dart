// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessMember {

 String get id;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'phone_or_email') String get phoneOrEmail; MemberStatus get status; Role get role;@JsonKey(name: 'is_owner') bool get isOwner;@JsonKey(name: 'invitation_id') String? get invitationId;@JsonKey(name: 'invited_at') DateTime get invitedAt;@JsonKey(name: 'joined_at') DateTime? get joinedAt;
/// Create a copy of BusinessMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessMemberCopyWith<BusinessMember> get copyWith => _$BusinessMemberCopyWithImpl<BusinessMember>(this as BusinessMember, _$identity);

  /// Serializes this BusinessMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessMember&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneOrEmail, phoneOrEmail) || other.phoneOrEmail == phoneOrEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneOrEmail,status,role,isOwner,invitationId,invitedAt,joinedAt);

@override
String toString() {
  return 'BusinessMember(id: $id, fullName: $fullName, phoneOrEmail: $phoneOrEmail, status: $status, role: $role, isOwner: $isOwner, invitationId: $invitationId, invitedAt: $invitedAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $BusinessMemberCopyWith<$Res>  {
  factory $BusinessMemberCopyWith(BusinessMember value, $Res Function(BusinessMember) _then) = _$BusinessMemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_or_email') String phoneOrEmail, MemberStatus status, Role role,@JsonKey(name: 'is_owner') bool isOwner,@JsonKey(name: 'invitation_id') String? invitationId,@JsonKey(name: 'invited_at') DateTime invitedAt,@JsonKey(name: 'joined_at') DateTime? joinedAt
});




}
/// @nodoc
class _$BusinessMemberCopyWithImpl<$Res>
    implements $BusinessMemberCopyWith<$Res> {
  _$BusinessMemberCopyWithImpl(this._self, this._then);

  final BusinessMember _self;
  final $Res Function(BusinessMember) _then;

/// Create a copy of BusinessMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phoneOrEmail = null,Object? status = null,Object? role = null,Object? isOwner = null,Object? invitationId = freezed,Object? invitedAt = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneOrEmail: null == phoneOrEmail ? _self.phoneOrEmail : phoneOrEmail // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,invitationId: freezed == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: null == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessMember].
extension BusinessMemberPatterns on BusinessMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessMember value)  $default,){
final _that = this;
switch (_that) {
case _BusinessMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessMember value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  MemberStatus status,  Role role, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'invitation_id')  String? invitationId, @JsonKey(name: 'invited_at')  DateTime invitedAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessMember() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneOrEmail,_that.status,_that.role,_that.isOwner,_that.invitationId,_that.invitedAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  MemberStatus status,  Role role, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'invitation_id')  String? invitationId, @JsonKey(name: 'invited_at')  DateTime invitedAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _BusinessMember():
return $default(_that.id,_that.fullName,_that.phoneOrEmail,_that.status,_that.role,_that.isOwner,_that.invitationId,_that.invitedAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_or_email')  String phoneOrEmail,  MemberStatus status,  Role role, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'invitation_id')  String? invitationId, @JsonKey(name: 'invited_at')  DateTime invitedAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _BusinessMember() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneOrEmail,_that.status,_that.role,_that.isOwner,_that.invitationId,_that.invitedAt,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessMember implements BusinessMember {
  const _BusinessMember({required this.id, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'phone_or_email') required this.phoneOrEmail, required this.status, required this.role, @JsonKey(name: 'is_owner') this.isOwner = false, @JsonKey(name: 'invitation_id') this.invitationId, @JsonKey(name: 'invited_at') required this.invitedAt, @JsonKey(name: 'joined_at') this.joinedAt});
  factory _BusinessMember.fromJson(Map<String, dynamic> json) => _$BusinessMemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'phone_or_email') final  String phoneOrEmail;
@override final  MemberStatus status;
@override final  Role role;
@override@JsonKey(name: 'is_owner') final  bool isOwner;
@override@JsonKey(name: 'invitation_id') final  String? invitationId;
@override@JsonKey(name: 'invited_at') final  DateTime invitedAt;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;

/// Create a copy of BusinessMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessMemberCopyWith<_BusinessMember> get copyWith => __$BusinessMemberCopyWithImpl<_BusinessMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessMember&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneOrEmail, phoneOrEmail) || other.phoneOrEmail == phoneOrEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneOrEmail,status,role,isOwner,invitationId,invitedAt,joinedAt);

@override
String toString() {
  return 'BusinessMember(id: $id, fullName: $fullName, phoneOrEmail: $phoneOrEmail, status: $status, role: $role, isOwner: $isOwner, invitationId: $invitationId, invitedAt: $invitedAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$BusinessMemberCopyWith<$Res> implements $BusinessMemberCopyWith<$Res> {
  factory _$BusinessMemberCopyWith(_BusinessMember value, $Res Function(_BusinessMember) _then) = __$BusinessMemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_or_email') String phoneOrEmail, MemberStatus status, Role role,@JsonKey(name: 'is_owner') bool isOwner,@JsonKey(name: 'invitation_id') String? invitationId,@JsonKey(name: 'invited_at') DateTime invitedAt,@JsonKey(name: 'joined_at') DateTime? joinedAt
});




}
/// @nodoc
class __$BusinessMemberCopyWithImpl<$Res>
    implements _$BusinessMemberCopyWith<$Res> {
  __$BusinessMemberCopyWithImpl(this._self, this._then);

  final _BusinessMember _self;
  final $Res Function(_BusinessMember) _then;

/// Create a copy of BusinessMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phoneOrEmail = null,Object? status = null,Object? role = null,Object? isOwner = null,Object? invitationId = freezed,Object? invitedAt = null,Object? joinedAt = freezed,}) {
  return _then(_BusinessMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneOrEmail: null == phoneOrEmail ? _self.phoneOrEmail : phoneOrEmail // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,invitationId: freezed == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: null == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
