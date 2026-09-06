// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accreditation_report_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccreditationReportDoc {

 String get id; String get semesterLabel; String get compiledBy; List<String> get includedEventIds; String get pdfUrl;@DateTimeConverter() DateTime get generatedAt;
/// Create a copy of AccreditationReportDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccreditationReportDocCopyWith<AccreditationReportDoc> get copyWith => _$AccreditationReportDocCopyWithImpl<AccreditationReportDoc>(this as AccreditationReportDoc, _$identity);

  /// Serializes this AccreditationReportDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccreditationReportDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.semesterLabel, semesterLabel) || other.semesterLabel == semesterLabel)&&(identical(other.compiledBy, compiledBy) || other.compiledBy == compiledBy)&&const DeepCollectionEquality().equals(other.includedEventIds, includedEventIds)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,semesterLabel,compiledBy,const DeepCollectionEquality().hash(includedEventIds),pdfUrl,generatedAt);

@override
String toString() {
  return 'AccreditationReportDoc(id: $id, semesterLabel: $semesterLabel, compiledBy: $compiledBy, includedEventIds: $includedEventIds, pdfUrl: $pdfUrl, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $AccreditationReportDocCopyWith<$Res>  {
  factory $AccreditationReportDocCopyWith(AccreditationReportDoc value, $Res Function(AccreditationReportDoc) _then) = _$AccreditationReportDocCopyWithImpl;
@useResult
$Res call({
 String id, String semesterLabel, String compiledBy, List<String> includedEventIds, String pdfUrl,@DateTimeConverter() DateTime generatedAt
});




}
/// @nodoc
class _$AccreditationReportDocCopyWithImpl<$Res>
    implements $AccreditationReportDocCopyWith<$Res> {
  _$AccreditationReportDocCopyWithImpl(this._self, this._then);

  final AccreditationReportDoc _self;
  final $Res Function(AccreditationReportDoc) _then;

/// Create a copy of AccreditationReportDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? semesterLabel = null,Object? compiledBy = null,Object? includedEventIds = null,Object? pdfUrl = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,semesterLabel: null == semesterLabel ? _self.semesterLabel : semesterLabel // ignore: cast_nullable_to_non_nullable
as String,compiledBy: null == compiledBy ? _self.compiledBy : compiledBy // ignore: cast_nullable_to_non_nullable
as String,includedEventIds: null == includedEventIds ? _self.includedEventIds : includedEventIds // ignore: cast_nullable_to_non_nullable
as List<String>,pdfUrl: null == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AccreditationReportDoc].
extension AccreditationReportDocPatterns on AccreditationReportDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccreditationReportDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccreditationReportDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccreditationReportDoc value)  $default,){
final _that = this;
switch (_that) {
case _AccreditationReportDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccreditationReportDoc value)?  $default,){
final _that = this;
switch (_that) {
case _AccreditationReportDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String semesterLabel,  String compiledBy,  List<String> includedEventIds,  String pdfUrl, @DateTimeConverter()  DateTime generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccreditationReportDoc() when $default != null:
return $default(_that.id,_that.semesterLabel,_that.compiledBy,_that.includedEventIds,_that.pdfUrl,_that.generatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String semesterLabel,  String compiledBy,  List<String> includedEventIds,  String pdfUrl, @DateTimeConverter()  DateTime generatedAt)  $default,) {final _that = this;
switch (_that) {
case _AccreditationReportDoc():
return $default(_that.id,_that.semesterLabel,_that.compiledBy,_that.includedEventIds,_that.pdfUrl,_that.generatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String semesterLabel,  String compiledBy,  List<String> includedEventIds,  String pdfUrl, @DateTimeConverter()  DateTime generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AccreditationReportDoc() when $default != null:
return $default(_that.id,_that.semesterLabel,_that.compiledBy,_that.includedEventIds,_that.pdfUrl,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccreditationReportDoc implements AccreditationReportDoc {
  const _AccreditationReportDoc({required this.id, required this.semesterLabel, required this.compiledBy, required final  List<String> includedEventIds, required this.pdfUrl, @DateTimeConverter() required this.generatedAt}): _includedEventIds = includedEventIds;
  factory _AccreditationReportDoc.fromJson(Map<String, dynamic> json) => _$AccreditationReportDocFromJson(json);

@override final  String id;
@override final  String semesterLabel;
@override final  String compiledBy;
 final  List<String> _includedEventIds;
@override List<String> get includedEventIds {
  if (_includedEventIds is EqualUnmodifiableListView) return _includedEventIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_includedEventIds);
}

@override final  String pdfUrl;
@override@DateTimeConverter() final  DateTime generatedAt;

/// Create a copy of AccreditationReportDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccreditationReportDocCopyWith<_AccreditationReportDoc> get copyWith => __$AccreditationReportDocCopyWithImpl<_AccreditationReportDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccreditationReportDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccreditationReportDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.semesterLabel, semesterLabel) || other.semesterLabel == semesterLabel)&&(identical(other.compiledBy, compiledBy) || other.compiledBy == compiledBy)&&const DeepCollectionEquality().equals(other._includedEventIds, _includedEventIds)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,semesterLabel,compiledBy,const DeepCollectionEquality().hash(_includedEventIds),pdfUrl,generatedAt);

@override
String toString() {
  return 'AccreditationReportDoc(id: $id, semesterLabel: $semesterLabel, compiledBy: $compiledBy, includedEventIds: $includedEventIds, pdfUrl: $pdfUrl, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$AccreditationReportDocCopyWith<$Res> implements $AccreditationReportDocCopyWith<$Res> {
  factory _$AccreditationReportDocCopyWith(_AccreditationReportDoc value, $Res Function(_AccreditationReportDoc) _then) = __$AccreditationReportDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String semesterLabel, String compiledBy, List<String> includedEventIds, String pdfUrl,@DateTimeConverter() DateTime generatedAt
});




}
/// @nodoc
class __$AccreditationReportDocCopyWithImpl<$Res>
    implements _$AccreditationReportDocCopyWith<$Res> {
  __$AccreditationReportDocCopyWithImpl(this._self, this._then);

  final _AccreditationReportDoc _self;
  final $Res Function(_AccreditationReportDoc) _then;

/// Create a copy of AccreditationReportDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? semesterLabel = null,Object? compiledBy = null,Object? includedEventIds = null,Object? pdfUrl = null,Object? generatedAt = null,}) {
  return _then(_AccreditationReportDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,semesterLabel: null == semesterLabel ? _self.semesterLabel : semesterLabel // ignore: cast_nullable_to_non_nullable
as String,compiledBy: null == compiledBy ? _self.compiledBy : compiledBy // ignore: cast_nullable_to_non_nullable
as String,includedEventIds: null == includedEventIds ? _self._includedEventIds : includedEventIds // ignore: cast_nullable_to_non_nullable
as List<String>,pdfUrl: null == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
