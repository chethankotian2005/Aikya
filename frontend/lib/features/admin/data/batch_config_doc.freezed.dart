// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_config_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatchConfigDoc {

 int get yearOfStudy; String get label; bool get graduated;
/// Create a copy of BatchConfigDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchConfigDocCopyWith<BatchConfigDoc> get copyWith => _$BatchConfigDocCopyWithImpl<BatchConfigDoc>(this as BatchConfigDoc, _$identity);

  /// Serializes this BatchConfigDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchConfigDoc&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.label, label) || other.label == label)&&(identical(other.graduated, graduated) || other.graduated == graduated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yearOfStudy,label,graduated);

@override
String toString() {
  return 'BatchConfigDoc(yearOfStudy: $yearOfStudy, label: $label, graduated: $graduated)';
}


}

/// @nodoc
abstract mixin class $BatchConfigDocCopyWith<$Res>  {
  factory $BatchConfigDocCopyWith(BatchConfigDoc value, $Res Function(BatchConfigDoc) _then) = _$BatchConfigDocCopyWithImpl;
@useResult
$Res call({
 int yearOfStudy, String label, bool graduated
});




}
/// @nodoc
class _$BatchConfigDocCopyWithImpl<$Res>
    implements $BatchConfigDocCopyWith<$Res> {
  _$BatchConfigDocCopyWithImpl(this._self, this._then);

  final BatchConfigDoc _self;
  final $Res Function(BatchConfigDoc) _then;

/// Create a copy of BatchConfigDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? yearOfStudy = null,Object? label = null,Object? graduated = null,}) {
  return _then(_self.copyWith(
yearOfStudy: null == yearOfStudy ? _self.yearOfStudy : yearOfStudy // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,graduated: null == graduated ? _self.graduated : graduated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchConfigDoc].
extension BatchConfigDocPatterns on BatchConfigDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchConfigDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchConfigDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchConfigDoc value)  $default,){
final _that = this;
switch (_that) {
case _BatchConfigDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchConfigDoc value)?  $default,){
final _that = this;
switch (_that) {
case _BatchConfigDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int yearOfStudy,  String label,  bool graduated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchConfigDoc() when $default != null:
return $default(_that.yearOfStudy,_that.label,_that.graduated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int yearOfStudy,  String label,  bool graduated)  $default,) {final _that = this;
switch (_that) {
case _BatchConfigDoc():
return $default(_that.yearOfStudy,_that.label,_that.graduated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int yearOfStudy,  String label,  bool graduated)?  $default,) {final _that = this;
switch (_that) {
case _BatchConfigDoc() when $default != null:
return $default(_that.yearOfStudy,_that.label,_that.graduated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchConfigDoc extends BatchConfigDoc {
  const _BatchConfigDoc({this.yearOfStudy = 1, this.label = '', this.graduated = false}): super._();
  factory _BatchConfigDoc.fromJson(Map<String, dynamic> json) => _$BatchConfigDocFromJson(json);

@override@JsonKey() final  int yearOfStudy;
@override@JsonKey() final  String label;
@override@JsonKey() final  bool graduated;

/// Create a copy of BatchConfigDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchConfigDocCopyWith<_BatchConfigDoc> get copyWith => __$BatchConfigDocCopyWithImpl<_BatchConfigDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchConfigDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchConfigDoc&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.label, label) || other.label == label)&&(identical(other.graduated, graduated) || other.graduated == graduated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yearOfStudy,label,graduated);

@override
String toString() {
  return 'BatchConfigDoc(yearOfStudy: $yearOfStudy, label: $label, graduated: $graduated)';
}


}

/// @nodoc
abstract mixin class _$BatchConfigDocCopyWith<$Res> implements $BatchConfigDocCopyWith<$Res> {
  factory _$BatchConfigDocCopyWith(_BatchConfigDoc value, $Res Function(_BatchConfigDoc) _then) = __$BatchConfigDocCopyWithImpl;
@override @useResult
$Res call({
 int yearOfStudy, String label, bool graduated
});




}
/// @nodoc
class __$BatchConfigDocCopyWithImpl<$Res>
    implements _$BatchConfigDocCopyWith<$Res> {
  __$BatchConfigDocCopyWithImpl(this._self, this._then);

  final _BatchConfigDoc _self;
  final $Res Function(_BatchConfigDoc) _then;

/// Create a copy of BatchConfigDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? yearOfStudy = null,Object? label = null,Object? graduated = null,}) {
  return _then(_BatchConfigDoc(
yearOfStudy: null == yearOfStudy ? _self.yearOfStudy : yearOfStudy // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,graduated: null == graduated ? _self.graduated : graduated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
