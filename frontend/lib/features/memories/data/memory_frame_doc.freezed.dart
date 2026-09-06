// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_frame_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoryFrameDoc {

 String get id; String get uploadedBy; String get imageUrl; String get caption; String get eventName; String get batchYear; FrameStatus get status; String? get approvedBy; int get likesCount;@DateTimeConverter() DateTime get createdAt;
/// Create a copy of MemoryFrameDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryFrameDocCopyWith<MemoryFrameDoc> get copyWith => _$MemoryFrameDocCopyWithImpl<MemoryFrameDoc>(this as MemoryFrameDoc, _$identity);

  /// Serializes this MemoryFrameDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryFrameDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.batchYear, batchYear) || other.batchYear == batchYear)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uploadedBy,imageUrl,caption,eventName,batchYear,status,approvedBy,likesCount,createdAt);

@override
String toString() {
  return 'MemoryFrameDoc(id: $id, uploadedBy: $uploadedBy, imageUrl: $imageUrl, caption: $caption, eventName: $eventName, batchYear: $batchYear, status: $status, approvedBy: $approvedBy, likesCount: $likesCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MemoryFrameDocCopyWith<$Res>  {
  factory $MemoryFrameDocCopyWith(MemoryFrameDoc value, $Res Function(MemoryFrameDoc) _then) = _$MemoryFrameDocCopyWithImpl;
@useResult
$Res call({
 String id, String uploadedBy, String imageUrl, String caption, String eventName, String batchYear, FrameStatus status, String? approvedBy, int likesCount,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$MemoryFrameDocCopyWithImpl<$Res>
    implements $MemoryFrameDocCopyWith<$Res> {
  _$MemoryFrameDocCopyWithImpl(this._self, this._then);

  final MemoryFrameDoc _self;
  final $Res Function(MemoryFrameDoc) _then;

/// Create a copy of MemoryFrameDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uploadedBy = null,Object? imageUrl = null,Object? caption = null,Object? eventName = null,Object? batchYear = null,Object? status = null,Object? approvedBy = freezed,Object? likesCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,batchYear: null == batchYear ? _self.batchYear : batchYear // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FrameStatus,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoryFrameDoc].
extension MemoryFrameDocPatterns on MemoryFrameDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoryFrameDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoryFrameDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoryFrameDoc value)  $default,){
final _that = this;
switch (_that) {
case _MemoryFrameDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoryFrameDoc value)?  $default,){
final _that = this;
switch (_that) {
case _MemoryFrameDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uploadedBy,  String imageUrl,  String caption,  String eventName,  String batchYear,  FrameStatus status,  String? approvedBy,  int likesCount, @DateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryFrameDoc() when $default != null:
return $default(_that.id,_that.uploadedBy,_that.imageUrl,_that.caption,_that.eventName,_that.batchYear,_that.status,_that.approvedBy,_that.likesCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uploadedBy,  String imageUrl,  String caption,  String eventName,  String batchYear,  FrameStatus status,  String? approvedBy,  int likesCount, @DateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MemoryFrameDoc():
return $default(_that.id,_that.uploadedBy,_that.imageUrl,_that.caption,_that.eventName,_that.batchYear,_that.status,_that.approvedBy,_that.likesCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uploadedBy,  String imageUrl,  String caption,  String eventName,  String batchYear,  FrameStatus status,  String? approvedBy,  int likesCount, @DateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MemoryFrameDoc() when $default != null:
return $default(_that.id,_that.uploadedBy,_that.imageUrl,_that.caption,_that.eventName,_that.batchYear,_that.status,_that.approvedBy,_that.likesCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryFrameDoc implements MemoryFrameDoc {
  const _MemoryFrameDoc({required this.id, required this.uploadedBy, required this.imageUrl, required this.caption, required this.eventName, required this.batchYear, this.status = FrameStatus.pending, this.approvedBy, this.likesCount = 0, @DateTimeConverter() required this.createdAt});
  factory _MemoryFrameDoc.fromJson(Map<String, dynamic> json) => _$MemoryFrameDocFromJson(json);

@override final  String id;
@override final  String uploadedBy;
@override final  String imageUrl;
@override final  String caption;
@override final  String eventName;
@override final  String batchYear;
@override@JsonKey() final  FrameStatus status;
@override final  String? approvedBy;
@override@JsonKey() final  int likesCount;
@override@DateTimeConverter() final  DateTime createdAt;

/// Create a copy of MemoryFrameDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryFrameDocCopyWith<_MemoryFrameDoc> get copyWith => __$MemoryFrameDocCopyWithImpl<_MemoryFrameDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryFrameDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryFrameDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.batchYear, batchYear) || other.batchYear == batchYear)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uploadedBy,imageUrl,caption,eventName,batchYear,status,approvedBy,likesCount,createdAt);

@override
String toString() {
  return 'MemoryFrameDoc(id: $id, uploadedBy: $uploadedBy, imageUrl: $imageUrl, caption: $caption, eventName: $eventName, batchYear: $batchYear, status: $status, approvedBy: $approvedBy, likesCount: $likesCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryFrameDocCopyWith<$Res> implements $MemoryFrameDocCopyWith<$Res> {
  factory _$MemoryFrameDocCopyWith(_MemoryFrameDoc value, $Res Function(_MemoryFrameDoc) _then) = __$MemoryFrameDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String uploadedBy, String imageUrl, String caption, String eventName, String batchYear, FrameStatus status, String? approvedBy, int likesCount,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$MemoryFrameDocCopyWithImpl<$Res>
    implements _$MemoryFrameDocCopyWith<$Res> {
  __$MemoryFrameDocCopyWithImpl(this._self, this._then);

  final _MemoryFrameDoc _self;
  final $Res Function(_MemoryFrameDoc) _then;

/// Create a copy of MemoryFrameDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uploadedBy = null,Object? imageUrl = null,Object? caption = null,Object? eventName = null,Object? batchYear = null,Object? status = null,Object? approvedBy = freezed,Object? likesCount = null,Object? createdAt = null,}) {
  return _then(_MemoryFrameDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,batchYear: null == batchYear ? _self.batchYear : batchYear // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FrameStatus,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
