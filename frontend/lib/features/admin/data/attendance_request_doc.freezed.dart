// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_request_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRequestDoc {

 String get id; String get studentId; String get eventId; String get requestDetails; AttendanceStatus get status; String? get reviewedBy; String? get reviewNotes;@DateTimeConverter() DateTime get createdAt;@DateTimeConverter() DateTime get updatedAt;
/// Create a copy of AttendanceRequestDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRequestDocCopyWith<AttendanceRequestDoc> get copyWith => _$AttendanceRequestDocCopyWithImpl<AttendanceRequestDoc>(this as AttendanceRequestDoc, _$identity);

  /// Serializes this AttendanceRequestDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRequestDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.requestDetails, requestDetails) || other.requestDetails == requestDetails)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNotes, reviewNotes) || other.reviewNotes == reviewNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,requestDetails,status,reviewedBy,reviewNotes,createdAt,updatedAt);

@override
String toString() {
  return 'AttendanceRequestDoc(id: $id, studentId: $studentId, eventId: $eventId, requestDetails: $requestDetails, status: $status, reviewedBy: $reviewedBy, reviewNotes: $reviewNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceRequestDocCopyWith<$Res>  {
  factory $AttendanceRequestDocCopyWith(AttendanceRequestDoc value, $Res Function(AttendanceRequestDoc) _then) = _$AttendanceRequestDocCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String eventId, String requestDetails, AttendanceStatus status, String? reviewedBy, String? reviewNotes,@DateTimeConverter() DateTime createdAt,@DateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class _$AttendanceRequestDocCopyWithImpl<$Res>
    implements $AttendanceRequestDocCopyWith<$Res> {
  _$AttendanceRequestDocCopyWithImpl(this._self, this._then);

  final AttendanceRequestDoc _self;
  final $Res Function(AttendanceRequestDoc) _then;

/// Create a copy of AttendanceRequestDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? eventId = null,Object? requestDetails = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewNotes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,requestDetails: null == requestDetails ? _self.requestDetails : requestDetails // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNotes: freezed == reviewNotes ? _self.reviewNotes : reviewNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRequestDoc].
extension AttendanceRequestDocPatterns on AttendanceRequestDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRequestDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRequestDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRequestDoc value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRequestDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRequestDoc value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRequestDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String eventId,  String requestDetails,  AttendanceStatus status,  String? reviewedBy,  String? reviewNotes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRequestDoc() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.requestDetails,_that.status,_that.reviewedBy,_that.reviewNotes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String eventId,  String requestDetails,  AttendanceStatus status,  String? reviewedBy,  String? reviewNotes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRequestDoc():
return $default(_that.id,_that.studentId,_that.eventId,_that.requestDetails,_that.status,_that.reviewedBy,_that.reviewNotes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String eventId,  String requestDetails,  AttendanceStatus status,  String? reviewedBy,  String? reviewNotes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRequestDoc() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.requestDetails,_that.status,_that.reviewedBy,_that.reviewNotes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceRequestDoc implements AttendanceRequestDoc {
  const _AttendanceRequestDoc({required this.id, required this.studentId, required this.eventId, required this.requestDetails, this.status = AttendanceStatus.pending, this.reviewedBy, this.reviewNotes, @DateTimeConverter() required this.createdAt, @DateTimeConverter() required this.updatedAt});
  factory _AttendanceRequestDoc.fromJson(Map<String, dynamic> json) => _$AttendanceRequestDocFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String eventId;
@override final  String requestDetails;
@override@JsonKey() final  AttendanceStatus status;
@override final  String? reviewedBy;
@override final  String? reviewNotes;
@override@DateTimeConverter() final  DateTime createdAt;
@override@DateTimeConverter() final  DateTime updatedAt;

/// Create a copy of AttendanceRequestDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRequestDocCopyWith<_AttendanceRequestDoc> get copyWith => __$AttendanceRequestDocCopyWithImpl<_AttendanceRequestDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRequestDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRequestDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.requestDetails, requestDetails) || other.requestDetails == requestDetails)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNotes, reviewNotes) || other.reviewNotes == reviewNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,requestDetails,status,reviewedBy,reviewNotes,createdAt,updatedAt);

@override
String toString() {
  return 'AttendanceRequestDoc(id: $id, studentId: $studentId, eventId: $eventId, requestDetails: $requestDetails, status: $status, reviewedBy: $reviewedBy, reviewNotes: $reviewNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRequestDocCopyWith<$Res> implements $AttendanceRequestDocCopyWith<$Res> {
  factory _$AttendanceRequestDocCopyWith(_AttendanceRequestDoc value, $Res Function(_AttendanceRequestDoc) _then) = __$AttendanceRequestDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String eventId, String requestDetails, AttendanceStatus status, String? reviewedBy, String? reviewNotes,@DateTimeConverter() DateTime createdAt,@DateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class __$AttendanceRequestDocCopyWithImpl<$Res>
    implements _$AttendanceRequestDocCopyWith<$Res> {
  __$AttendanceRequestDocCopyWithImpl(this._self, this._then);

  final _AttendanceRequestDoc _self;
  final $Res Function(_AttendanceRequestDoc) _then;

/// Create a copy of AttendanceRequestDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? eventId = null,Object? requestDetails = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewNotes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AttendanceRequestDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,requestDetails: null == requestDetails ? _self.requestDetails : requestDetails // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNotes: freezed == reviewNotes ? _self.reviewNotes : reviewNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
