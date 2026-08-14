// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovementDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'item_name') String get itemName;@JsonKey(name: 'godown_id') String get godownId;@JsonKey(name: 'godown_name') String get godownName;@JsonKey(name: 'movement_type') String get movementType;@JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson) String get quantityDelta;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson) String? get costPerUnit; String? get unit;@JsonKey(name: 'reference_id') String? get referenceId;@JsonKey(name: 'reference_type') String? get referenceType;@JsonKey(name: 'reference_number') String? get referenceNumber;@JsonKey(name: 'party_name') String? get partyName;@JsonKey(name: 'created_by') String? get createdBy;@JsonKey(name: 'created_by_name') String? get createdByName; String? get notes;
/// Create a copy of MovementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementDtoCopyWith<MovementDto> get copyWith => _$MovementDtoCopyWithImpl<MovementDto>(this as MovementDto, _$identity);

  /// Serializes this MovementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.movementType, movementType) || other.movementType == movementType)&&(identical(other.quantityDelta, quantityDelta) || other.quantityDelta == quantityDelta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.costPerUnit, costPerUnit) || other.costPerUnit == costPerUnit)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,godownId,godownName,movementType,quantityDelta,createdAt,costPerUnit,unit,referenceId,referenceType,referenceNumber,partyName,createdBy,createdByName,notes);

@override
String toString() {
  return 'MovementDto(id: $id, itemId: $itemId, itemName: $itemName, godownId: $godownId, godownName: $godownName, movementType: $movementType, quantityDelta: $quantityDelta, createdAt: $createdAt, costPerUnit: $costPerUnit, unit: $unit, referenceId: $referenceId, referenceType: $referenceType, referenceNumber: $referenceNumber, partyName: $partyName, createdBy: $createdBy, createdByName: $createdByName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MovementDtoCopyWith<$Res>  {
  factory $MovementDtoCopyWith(MovementDto value, $Res Function(MovementDto) _then) = _$MovementDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName,@JsonKey(name: 'movement_type') String movementType,@JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson) String quantityDelta,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson) String? costPerUnit, String? unit,@JsonKey(name: 'reference_id') String? referenceId,@JsonKey(name: 'reference_type') String? referenceType,@JsonKey(name: 'reference_number') String? referenceNumber,@JsonKey(name: 'party_name') String? partyName,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'created_by_name') String? createdByName, String? notes
});




}
/// @nodoc
class _$MovementDtoCopyWithImpl<$Res>
    implements $MovementDtoCopyWith<$Res> {
  _$MovementDtoCopyWithImpl(this._self, this._then);

  final MovementDto _self;
  final $Res Function(MovementDto) _then;

/// Create a copy of MovementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? godownId = null,Object? godownName = null,Object? movementType = null,Object? quantityDelta = null,Object? createdAt = null,Object? costPerUnit = freezed,Object? unit = freezed,Object? referenceId = freezed,Object? referenceType = freezed,Object? referenceNumber = freezed,Object? partyName = freezed,Object? createdBy = freezed,Object? createdByName = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,movementType: null == movementType ? _self.movementType : movementType // ignore: cast_nullable_to_non_nullable
as String,quantityDelta: null == quantityDelta ? _self.quantityDelta : quantityDelta // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,costPerUnit: freezed == costPerUnit ? _self.costPerUnit : costPerUnit // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,partyName: freezed == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementDto].
extension MovementDtoPatterns on MovementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementDto value)  $default,){
final _that = this;
switch (_that) {
case _MovementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementDto value)?  $default,){
final _that = this;
switch (_that) {
case _MovementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName, @JsonKey(name: 'movement_type')  String movementType, @JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson)  String quantityDelta, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson)  String? costPerUnit,  String? unit, @JsonKey(name: 'reference_id')  String? referenceId, @JsonKey(name: 'reference_type')  String? referenceType, @JsonKey(name: 'reference_number')  String? referenceNumber, @JsonKey(name: 'party_name')  String? partyName, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.movementType,_that.quantityDelta,_that.createdAt,_that.costPerUnit,_that.unit,_that.referenceId,_that.referenceType,_that.referenceNumber,_that.partyName,_that.createdBy,_that.createdByName,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName, @JsonKey(name: 'movement_type')  String movementType, @JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson)  String quantityDelta, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson)  String? costPerUnit,  String? unit, @JsonKey(name: 'reference_id')  String? referenceId, @JsonKey(name: 'reference_type')  String? referenceType, @JsonKey(name: 'reference_number')  String? referenceNumber, @JsonKey(name: 'party_name')  String? partyName, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MovementDto():
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.movementType,_that.quantityDelta,_that.createdAt,_that.costPerUnit,_that.unit,_that.referenceId,_that.referenceType,_that.referenceNumber,_that.partyName,_that.createdBy,_that.createdByName,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName, @JsonKey(name: 'movement_type')  String movementType, @JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson)  String quantityDelta, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson)  String? costPerUnit,  String? unit, @JsonKey(name: 'reference_id')  String? referenceId, @JsonKey(name: 'reference_type')  String? referenceType, @JsonKey(name: 'reference_number')  String? referenceNumber, @JsonKey(name: 'party_name')  String? partyName, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MovementDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.movementType,_that.quantityDelta,_that.createdAt,_that.costPerUnit,_that.unit,_that.referenceId,_that.referenceType,_that.referenceNumber,_that.partyName,_that.createdBy,_that.createdByName,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovementDto implements MovementDto {
  const _MovementDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'item_name') required this.itemName, @JsonKey(name: 'godown_id') required this.godownId, @JsonKey(name: 'godown_name') required this.godownName, @JsonKey(name: 'movement_type') required this.movementType, @JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson) required this.quantityDelta, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson) this.costPerUnit, this.unit, @JsonKey(name: 'reference_id') this.referenceId, @JsonKey(name: 'reference_type') this.referenceType, @JsonKey(name: 'reference_number') this.referenceNumber, @JsonKey(name: 'party_name') this.partyName, @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'created_by_name') this.createdByName, this.notes});
  factory _MovementDto.fromJson(Map<String, dynamic> json) => _$MovementDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'item_name') final  String itemName;
@override@JsonKey(name: 'godown_id') final  String godownId;
@override@JsonKey(name: 'godown_name') final  String godownName;
@override@JsonKey(name: 'movement_type') final  String movementType;
@override@JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson) final  String quantityDelta;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson) final  String? costPerUnit;
@override final  String? unit;
@override@JsonKey(name: 'reference_id') final  String? referenceId;
@override@JsonKey(name: 'reference_type') final  String? referenceType;
@override@JsonKey(name: 'reference_number') final  String? referenceNumber;
@override@JsonKey(name: 'party_name') final  String? partyName;
@override@JsonKey(name: 'created_by') final  String? createdBy;
@override@JsonKey(name: 'created_by_name') final  String? createdByName;
@override final  String? notes;

/// Create a copy of MovementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementDtoCopyWith<_MovementDto> get copyWith => __$MovementDtoCopyWithImpl<_MovementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.movementType, movementType) || other.movementType == movementType)&&(identical(other.quantityDelta, quantityDelta) || other.quantityDelta == quantityDelta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.costPerUnit, costPerUnit) || other.costPerUnit == costPerUnit)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,godownId,godownName,movementType,quantityDelta,createdAt,costPerUnit,unit,referenceId,referenceType,referenceNumber,partyName,createdBy,createdByName,notes);

@override
String toString() {
  return 'MovementDto(id: $id, itemId: $itemId, itemName: $itemName, godownId: $godownId, godownName: $godownName, movementType: $movementType, quantityDelta: $quantityDelta, createdAt: $createdAt, costPerUnit: $costPerUnit, unit: $unit, referenceId: $referenceId, referenceType: $referenceType, referenceNumber: $referenceNumber, partyName: $partyName, createdBy: $createdBy, createdByName: $createdByName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MovementDtoCopyWith<$Res> implements $MovementDtoCopyWith<$Res> {
  factory _$MovementDtoCopyWith(_MovementDto value, $Res Function(_MovementDto) _then) = __$MovementDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName,@JsonKey(name: 'movement_type') String movementType,@JsonKey(name: 'quantity_delta', fromJson: decimalStringFromJson) String quantityDelta,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'cost_per_unit', fromJson: nullableDecimalStringFromJson) String? costPerUnit, String? unit,@JsonKey(name: 'reference_id') String? referenceId,@JsonKey(name: 'reference_type') String? referenceType,@JsonKey(name: 'reference_number') String? referenceNumber,@JsonKey(name: 'party_name') String? partyName,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'created_by_name') String? createdByName, String? notes
});




}
/// @nodoc
class __$MovementDtoCopyWithImpl<$Res>
    implements _$MovementDtoCopyWith<$Res> {
  __$MovementDtoCopyWithImpl(this._self, this._then);

  final _MovementDto _self;
  final $Res Function(_MovementDto) _then;

/// Create a copy of MovementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? godownId = null,Object? godownName = null,Object? movementType = null,Object? quantityDelta = null,Object? createdAt = null,Object? costPerUnit = freezed,Object? unit = freezed,Object? referenceId = freezed,Object? referenceType = freezed,Object? referenceNumber = freezed,Object? partyName = freezed,Object? createdBy = freezed,Object? createdByName = freezed,Object? notes = freezed,}) {
  return _then(_MovementDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,movementType: null == movementType ? _self.movementType : movementType // ignore: cast_nullable_to_non_nullable
as String,quantityDelta: null == quantityDelta ? _self.quantityDelta : quantityDelta // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,costPerUnit: freezed == costPerUnit ? _self.costPerUnit : costPerUnit // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,partyName: freezed == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
