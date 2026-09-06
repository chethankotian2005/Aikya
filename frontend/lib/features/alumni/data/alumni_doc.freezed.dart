// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alumni_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlumniDoc {

 String get uid; int get graduationYear; String get currentCompany; String get jobTitle; String get location; String get linkedinUrl; bool get isOpenForMentorship; bool get verifiedByHod;@DateTimeConverter() DateTime get createdAt;
/// Create a copy of AlumniDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlumniDocCopyWith<AlumniDoc> get copyWith => _$AlumniDocCopyWithImpl<AlumniDoc>(this as AlumniDoc, _$identity);

  /// Serializes this AlumniDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlumniDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.graduationYear, graduationYear) || other.graduationYear == graduationYear)&&(identical(other.currentCompany, currentCompany) || other.currentCompany == currentCompany)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.location, location) || other.location == location)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.isOpenForMentorship, isOpenForMentorship) || other.isOpenForMentorship == isOpenForMentorship)&&(identical(other.verifiedByHod, verifiedByHod) || other.verifiedByHod == verifiedByHod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,graduationYear,currentCompany,jobTitle,location,linkedinUrl,isOpenForMentorship,verifiedByHod,createdAt);

@override
String toString() {
  return 'AlumniDoc(uid: $uid, graduationYear: $graduationYear, currentCompany: $currentCompany, jobTitle: $jobTitle, location: $location, linkedinUrl: $linkedinUrl, isOpenForMentorship: $isOpenForMentorship, verifiedByHod: $verifiedByHod, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AlumniDocCopyWith<$Res>  {
  factory $AlumniDocCopyWith(AlumniDoc value, $Res Function(AlumniDoc) _then) = _$AlumniDocCopyWithImpl;
@useResult
$Res call({
 String uid, int graduationYear, String currentCompany, String jobTitle, String location, String linkedinUrl, bool isOpenForMentorship, bool verifiedByHod,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$AlumniDocCopyWithImpl<$Res>
    implements $AlumniDocCopyWith<$Res> {
  _$AlumniDocCopyWithImpl(this._self, this._then);

  final AlumniDoc _self;
  final $Res Function(AlumniDoc) _then;

/// Create a copy of AlumniDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? graduationYear = null,Object? currentCompany = null,Object? jobTitle = null,Object? location = null,Object? linkedinUrl = null,Object? isOpenForMentorship = null,Object? verifiedByHod = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,graduationYear: null == graduationYear ? _self.graduationYear : graduationYear // ignore: cast_nullable_to_non_nullable
as int,currentCompany: null == currentCompany ? _self.currentCompany : currentCompany // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,linkedinUrl: null == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String,isOpenForMentorship: null == isOpenForMentorship ? _self.isOpenForMentorship : isOpenForMentorship // ignore: cast_nullable_to_non_nullable
as bool,verifiedByHod: null == verifiedByHod ? _self.verifiedByHod : verifiedByHod // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AlumniDoc].
extension AlumniDocPatterns on AlumniDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlumniDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlumniDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlumniDoc value)  $default,){
final _that = this;
switch (_that) {
case _AlumniDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlumniDoc value)?  $default,){
final _that = this;
switch (_that) {
case _AlumniDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  int graduationYear,  String currentCompany,  String jobTitle,  String location,  String linkedinUrl,  bool isOpenForMentorship,  bool verifiedByHod, @DateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlumniDoc() when $default != null:
return $default(_that.uid,_that.graduationYear,_that.currentCompany,_that.jobTitle,_that.location,_that.linkedinUrl,_that.isOpenForMentorship,_that.verifiedByHod,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  int graduationYear,  String currentCompany,  String jobTitle,  String location,  String linkedinUrl,  bool isOpenForMentorship,  bool verifiedByHod, @DateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AlumniDoc():
return $default(_that.uid,_that.graduationYear,_that.currentCompany,_that.jobTitle,_that.location,_that.linkedinUrl,_that.isOpenForMentorship,_that.verifiedByHod,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  int graduationYear,  String currentCompany,  String jobTitle,  String location,  String linkedinUrl,  bool isOpenForMentorship,  bool verifiedByHod, @DateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AlumniDoc() when $default != null:
return $default(_that.uid,_that.graduationYear,_that.currentCompany,_that.jobTitle,_that.location,_that.linkedinUrl,_that.isOpenForMentorship,_that.verifiedByHod,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlumniDoc implements AlumniDoc {
  const _AlumniDoc({required this.uid, required this.graduationYear, required this.currentCompany, required this.jobTitle, required this.location, required this.linkedinUrl, this.isOpenForMentorship = false, this.verifiedByHod = false, @DateTimeConverter() required this.createdAt});
  factory _AlumniDoc.fromJson(Map<String, dynamic> json) => _$AlumniDocFromJson(json);

@override final  String uid;
@override final  int graduationYear;
@override final  String currentCompany;
@override final  String jobTitle;
@override final  String location;
@override final  String linkedinUrl;
@override@JsonKey() final  bool isOpenForMentorship;
@override@JsonKey() final  bool verifiedByHod;
@override@DateTimeConverter() final  DateTime createdAt;

/// Create a copy of AlumniDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlumniDocCopyWith<_AlumniDoc> get copyWith => __$AlumniDocCopyWithImpl<_AlumniDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlumniDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlumniDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.graduationYear, graduationYear) || other.graduationYear == graduationYear)&&(identical(other.currentCompany, currentCompany) || other.currentCompany == currentCompany)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.location, location) || other.location == location)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.isOpenForMentorship, isOpenForMentorship) || other.isOpenForMentorship == isOpenForMentorship)&&(identical(other.verifiedByHod, verifiedByHod) || other.verifiedByHod == verifiedByHod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,graduationYear,currentCompany,jobTitle,location,linkedinUrl,isOpenForMentorship,verifiedByHod,createdAt);

@override
String toString() {
  return 'AlumniDoc(uid: $uid, graduationYear: $graduationYear, currentCompany: $currentCompany, jobTitle: $jobTitle, location: $location, linkedinUrl: $linkedinUrl, isOpenForMentorship: $isOpenForMentorship, verifiedByHod: $verifiedByHod, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AlumniDocCopyWith<$Res> implements $AlumniDocCopyWith<$Res> {
  factory _$AlumniDocCopyWith(_AlumniDoc value, $Res Function(_AlumniDoc) _then) = __$AlumniDocCopyWithImpl;
@override @useResult
$Res call({
 String uid, int graduationYear, String currentCompany, String jobTitle, String location, String linkedinUrl, bool isOpenForMentorship, bool verifiedByHod,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$AlumniDocCopyWithImpl<$Res>
    implements _$AlumniDocCopyWith<$Res> {
  __$AlumniDocCopyWithImpl(this._self, this._then);

  final _AlumniDoc _self;
  final $Res Function(_AlumniDoc) _then;

/// Create a copy of AlumniDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? graduationYear = null,Object? currentCompany = null,Object? jobTitle = null,Object? location = null,Object? linkedinUrl = null,Object? isOpenForMentorship = null,Object? verifiedByHod = null,Object? createdAt = null,}) {
  return _then(_AlumniDoc(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,graduationYear: null == graduationYear ? _self.graduationYear : graduationYear // ignore: cast_nullable_to_non_nullable
as int,currentCompany: null == currentCompany ? _self.currentCompany : currentCompany // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,linkedinUrl: null == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String,isOpenForMentorship: null == isOpenForMentorship ? _self.isOpenForMentorship : isOpenForMentorship // ignore: cast_nullable_to_non_nullable
as bool,verifiedByHod: null == verifiedByHod ? _self.verifiedByHod : verifiedByHod // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
