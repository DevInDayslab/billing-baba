// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Contact {

 String get id;@JsonKey(name: 'business_id') String get businessId; String get name;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'first_name') String? get firstName;@JsonKey(name: 'last_name') String? get lastName; String? get salutation;@JsonKey(name: 'account_name') String? get accountName; String? get phone; String? get email;@JsonKey(name: 'assigned_to') String? get assignedTo; String? get title; String? get description;@JsonKey(name: 'sync_version') int get syncVersion;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;@JsonKey(name: 'device_id') String get deviceId;@JsonKey(name: 'sync_status') String get syncStatus;
/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactCopyWith<Contact> get copyWith => _$ContactCopyWithImpl<Contact>(this as Contact, _$identity);

  /// Serializes this Contact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contact&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.salutation, salutation) || other.salutation == salutation)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,businessId,name,updatedAt,createdAt,firstName,lastName,salutation,accountName,phone,email,assignedTo,title,description,syncVersion,isDeleted,deletedAt,deviceId,syncStatus]);

@override
String toString() {
  return 'Contact(id: $id, businessId: $businessId, name: $name, updatedAt: $updatedAt, createdAt: $createdAt, firstName: $firstName, lastName: $lastName, salutation: $salutation, accountName: $accountName, phone: $phone, email: $email, assignedTo: $assignedTo, title: $title, description: $description, syncVersion: $syncVersion, isDeleted: $isDeleted, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $ContactCopyWith<$Res>  {
  factory $ContactCopyWith(Contact value, $Res Function(Contact) _then) = _$ContactCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName, String? salutation,@JsonKey(name: 'account_name') String? accountName, String? phone, String? email,@JsonKey(name: 'assigned_to') String? assignedTo, String? title, String? description,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus
});




}
/// @nodoc
class _$ContactCopyWithImpl<$Res>
    implements $ContactCopyWith<$Res> {
  _$ContactCopyWithImpl(this._self, this._then);

  final Contact _self;
  final $Res Function(Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? updatedAt = null,Object? createdAt = null,Object? firstName = freezed,Object? lastName = freezed,Object? salutation = freezed,Object? accountName = freezed,Object? phone = freezed,Object? email = freezed,Object? assignedTo = freezed,Object? title = freezed,Object? description = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,salutation: freezed == salutation ? _self.salutation : salutation // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Contact].
extension ContactPatterns on Contact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contact value)  $default,){
final _that = this;
switch (_that) {
case _Contact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contact value)?  $default,){
final _that = this;
switch (_that) {
case _Contact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  String? salutation, @JsonKey(name: 'account_name')  String? accountName,  String? phone,  String? email, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? title,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.firstName,_that.lastName,_that.salutation,_that.accountName,_that.phone,_that.email,_that.assignedTo,_that.title,_that.description,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  String? salutation, @JsonKey(name: 'account_name')  String? accountName,  String? phone,  String? email, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? title,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Contact():
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.firstName,_that.lastName,_that.salutation,_that.accountName,_that.phone,_that.email,_that.assignedTo,_that.title,_that.description,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  String? salutation, @JsonKey(name: 'account_name')  String? accountName,  String? phone,  String? email, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? title,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.firstName,_that.lastName,_that.salutation,_that.accountName,_that.phone,_that.email,_that.assignedTo,_that.title,_that.description,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Contact implements Contact {
  const _Contact({required this.id, @JsonKey(name: 'business_id') required this.businessId, required this.name, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'first_name') this.firstName, @JsonKey(name: 'last_name') this.lastName, this.salutation, @JsonKey(name: 'account_name') this.accountName, this.phone, this.email, @JsonKey(name: 'assigned_to') this.assignedTo, this.title, this.description, @JsonKey(name: 'sync_version') this.syncVersion = 1, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'device_id') this.deviceId = '', @JsonKey(name: 'sync_status') this.syncStatus = 'pending'});
  factory _Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

@override final  String id;
@override@JsonKey(name: 'business_id') final  String businessId;
@override final  String name;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'first_name') final  String? firstName;
@override@JsonKey(name: 'last_name') final  String? lastName;
@override final  String? salutation;
@override@JsonKey(name: 'account_name') final  String? accountName;
@override final  String? phone;
@override final  String? email;
@override@JsonKey(name: 'assigned_to') final  String? assignedTo;
@override final  String? title;
@override final  String? description;
@override@JsonKey(name: 'sync_version') final  int syncVersion;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;
@override@JsonKey(name: 'device_id') final  String deviceId;
@override@JsonKey(name: 'sync_status') final  String syncStatus;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactCopyWith<_Contact> get copyWith => __$ContactCopyWithImpl<_Contact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contact&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.salutation, salutation) || other.salutation == salutation)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,businessId,name,updatedAt,createdAt,firstName,lastName,salutation,accountName,phone,email,assignedTo,title,description,syncVersion,isDeleted,deletedAt,deviceId,syncStatus]);

@override
String toString() {
  return 'Contact(id: $id, businessId: $businessId, name: $name, updatedAt: $updatedAt, createdAt: $createdAt, firstName: $firstName, lastName: $lastName, salutation: $salutation, accountName: $accountName, phone: $phone, email: $email, assignedTo: $assignedTo, title: $title, description: $description, syncVersion: $syncVersion, isDeleted: $isDeleted, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$ContactCopyWith<$Res> implements $ContactCopyWith<$Res> {
  factory _$ContactCopyWith(_Contact value, $Res Function(_Contact) _then) = __$ContactCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName, String? salutation,@JsonKey(name: 'account_name') String? accountName, String? phone, String? email,@JsonKey(name: 'assigned_to') String? assignedTo, String? title, String? description,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus
});




}
/// @nodoc
class __$ContactCopyWithImpl<$Res>
    implements _$ContactCopyWith<$Res> {
  __$ContactCopyWithImpl(this._self, this._then);

  final _Contact _self;
  final $Res Function(_Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? updatedAt = null,Object? createdAt = null,Object? firstName = freezed,Object? lastName = freezed,Object? salutation = freezed,Object? accountName = freezed,Object? phone = freezed,Object? email = freezed,Object? assignedTo = freezed,Object? title = freezed,Object? description = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,}) {
  return _then(_Contact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,salutation: freezed == salutation ? _self.salutation : salutation // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
