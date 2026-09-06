// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistrationDoc {

 String get eventId; String get studentUid; Map<String, dynamic> get formResponses;@DateTimeConverter() DateTime get registeredAt;
/// Create a copy of RegistrationDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationDocCopyWith<RegistrationDoc> get copyWith => _$RegistrationDocCopyWithImpl<RegistrationDoc>(this as RegistrationDoc, _$identity);

  /// Serializes this RegistrationDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationDoc&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.studentUid, studentUid) || other.studentUid == studentUid)&&const DeepCollectionEquality().equals(other.formResponses, formResponses)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,studentUid,const DeepCollectionEquality().hash(formResponses),registeredAt);

@override
String toString() {
  return 'RegistrationDoc(eventId: $eventId, studentUid: $studentUid, formResponses: $formResponses, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class $RegistrationDocCopyWith<$Res>  {
  factory $RegistrationDocCopyWith(RegistrationDoc value, $Res Function(RegistrationDoc) _then) = _$RegistrationDocCopyWithImpl;
@useResult
$Res call({
 String eventId, String studentUid, Map<String, dynamic> formResponses,@DateTimeConverter() DateTime registeredAt
});




}
/// @nodoc
class _$RegistrationDocCopyWithImpl<$Res>
    implements $RegistrationDocCopyWith<$Res> {
  _$RegistrationDocCopyWithImpl(this._self, this._then);

  final RegistrationDoc _self;
  final $Res Function(RegistrationDoc) _then;

/// Create a copy of RegistrationDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? studentUid = null,Object? formResponses = null,Object? registeredAt = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,studentUid: null == studentUid ? _self.studentUid : studentUid // ignore: cast_nullable_to_non_nullable
as String,formResponses: null == formResponses ? _self.formResponses : formResponses // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrationDoc].
extension RegistrationDocPatterns on RegistrationDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationDoc value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationDoc value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  String studentUid,  Map<String, dynamic> formResponses, @DateTimeConverter()  DateTime registeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationDoc() when $default != null:
return $default(_that.eventId,_that.studentUid,_that.formResponses,_that.registeredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  String studentUid,  Map<String, dynamic> formResponses, @DateTimeConverter()  DateTime registeredAt)  $default,) {final _that = this;
switch (_that) {
case _RegistrationDoc():
return $default(_that.eventId,_that.studentUid,_that.formResponses,_that.registeredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  String studentUid,  Map<String, dynamic> formResponses, @DateTimeConverter()  DateTime registeredAt)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationDoc() when $default != null:
return $default(_that.eventId,_that.studentUid,_that.formResponses,_that.registeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrationDoc implements RegistrationDoc {
  const _RegistrationDoc({required this.eventId, required this.studentUid, required final  Map<String, dynamic> formResponses, @DateTimeConverter() required this.registeredAt}): _formResponses = formResponses;
  factory _RegistrationDoc.fromJson(Map<String, dynamic> json) => _$RegistrationDocFromJson(json);

@override final  String eventId;
@override final  String studentUid;
 final  Map<String, dynamic> _formResponses;
@override Map<String, dynamic> get formResponses {
  if (_formResponses is EqualUnmodifiableMapView) return _formResponses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_formResponses);
}

@override@DateTimeConverter() final  DateTime registeredAt;

/// Create a copy of RegistrationDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationDocCopyWith<_RegistrationDoc> get copyWith => __$RegistrationDocCopyWithImpl<_RegistrationDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationDoc&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.studentUid, studentUid) || other.studentUid == studentUid)&&const DeepCollectionEquality().equals(other._formResponses, _formResponses)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,studentUid,const DeepCollectionEquality().hash(_formResponses),registeredAt);

@override
String toString() {
  return 'RegistrationDoc(eventId: $eventId, studentUid: $studentUid, formResponses: $formResponses, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class _$RegistrationDocCopyWith<$Res> implements $RegistrationDocCopyWith<$Res> {
  factory _$RegistrationDocCopyWith(_RegistrationDoc value, $Res Function(_RegistrationDoc) _then) = __$RegistrationDocCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String studentUid, Map<String, dynamic> formResponses,@DateTimeConverter() DateTime registeredAt
});




}
/// @nodoc
class __$RegistrationDocCopyWithImpl<$Res>
    implements _$RegistrationDocCopyWith<$Res> {
  __$RegistrationDocCopyWithImpl(this._self, this._then);

  final _RegistrationDoc _self;
  final $Res Function(_RegistrationDoc) _then;

/// Create a copy of RegistrationDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? studentUid = null,Object? formResponses = null,Object? registeredAt = null,}) {
  return _then(_RegistrationDoc(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,studentUid: null == studentUid ? _self.studentUid : studentUid // ignore: cast_nullable_to_non_nullable
as String,formResponses: null == formResponses ? _self._formResponses : formResponses // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
