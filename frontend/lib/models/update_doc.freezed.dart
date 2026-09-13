// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateDoc {

 String get id; String get content; String? get imageUrl;@DateTimeConverter() DateTime? get deadlineDate; String get authorId; String get authorName; String get authorDesignation; String? get club;@DateTimeConverter() DateTime get createdAt;
/// Create a copy of UpdateDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateDocCopyWith<UpdateDoc> get copyWith => _$UpdateDocCopyWithImpl<UpdateDoc>(this as UpdateDoc, _$identity);

  /// Serializes this UpdateDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.deadlineDate, deadlineDate) || other.deadlineDate == deadlineDate)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorDesignation, authorDesignation) || other.authorDesignation == authorDesignation)&&(identical(other.club, club) || other.club == club)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,deadlineDate,authorId,authorName,authorDesignation,club,createdAt);

@override
String toString() {
  return 'UpdateDoc(id: $id, content: $content, imageUrl: $imageUrl, deadlineDate: $deadlineDate, authorId: $authorId, authorName: $authorName, authorDesignation: $authorDesignation, club: $club, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UpdateDocCopyWith<$Res>  {
  factory $UpdateDocCopyWith(UpdateDoc value, $Res Function(UpdateDoc) _then) = _$UpdateDocCopyWithImpl;
@useResult
$Res call({
 String id, String content, String? imageUrl,@DateTimeConverter() DateTime? deadlineDate, String authorId, String authorName, String authorDesignation, String? club,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$UpdateDocCopyWithImpl<$Res>
    implements $UpdateDocCopyWith<$Res> {
  _$UpdateDocCopyWithImpl(this._self, this._then);

  final UpdateDoc _self;
  final $Res Function(UpdateDoc) _then;

/// Create a copy of UpdateDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? deadlineDate = freezed,Object? authorId = null,Object? authorName = null,Object? authorDesignation = null,Object? club = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,deadlineDate: freezed == deadlineDate ? _self.deadlineDate : deadlineDate // ignore: cast_nullable_to_non_nullable
as DateTime?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorDesignation: null == authorDesignation ? _self.authorDesignation : authorDesignation // ignore: cast_nullable_to_non_nullable
as String,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateDoc].
extension UpdateDocPatterns on UpdateDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateDoc value)  $default,){
final _that = this;
switch (_that) {
case _UpdateDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateDoc value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String? imageUrl, @DateTimeConverter()  DateTime? deadlineDate,  String authorId,  String authorName,  String authorDesignation,  String? club, @DateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateDoc() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.deadlineDate,_that.authorId,_that.authorName,_that.authorDesignation,_that.club,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String? imageUrl, @DateTimeConverter()  DateTime? deadlineDate,  String authorId,  String authorName,  String authorDesignation,  String? club, @DateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UpdateDoc():
return $default(_that.id,_that.content,_that.imageUrl,_that.deadlineDate,_that.authorId,_that.authorName,_that.authorDesignation,_that.club,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String? imageUrl, @DateTimeConverter()  DateTime? deadlineDate,  String authorId,  String authorName,  String authorDesignation,  String? club, @DateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UpdateDoc() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.deadlineDate,_that.authorId,_that.authorName,_that.authorDesignation,_that.club,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateDoc implements UpdateDoc {
  const _UpdateDoc({required this.id, required this.content, this.imageUrl, @DateTimeConverter() this.deadlineDate, required this.authorId, required this.authorName, required this.authorDesignation, this.club, @DateTimeConverter() required this.createdAt});
  factory _UpdateDoc.fromJson(Map<String, dynamic> json) => _$UpdateDocFromJson(json);

@override final  String id;
@override final  String content;
@override final  String? imageUrl;
@override@DateTimeConverter() final  DateTime? deadlineDate;
@override final  String authorId;
@override final  String authorName;
@override final  String authorDesignation;
@override final  String? club;
@override@DateTimeConverter() final  DateTime createdAt;

/// Create a copy of UpdateDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateDocCopyWith<_UpdateDoc> get copyWith => __$UpdateDocCopyWithImpl<_UpdateDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.deadlineDate, deadlineDate) || other.deadlineDate == deadlineDate)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorDesignation, authorDesignation) || other.authorDesignation == authorDesignation)&&(identical(other.club, club) || other.club == club)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,deadlineDate,authorId,authorName,authorDesignation,club,createdAt);

@override
String toString() {
  return 'UpdateDoc(id: $id, content: $content, imageUrl: $imageUrl, deadlineDate: $deadlineDate, authorId: $authorId, authorName: $authorName, authorDesignation: $authorDesignation, club: $club, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UpdateDocCopyWith<$Res> implements $UpdateDocCopyWith<$Res> {
  factory _$UpdateDocCopyWith(_UpdateDoc value, $Res Function(_UpdateDoc) _then) = __$UpdateDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String? imageUrl,@DateTimeConverter() DateTime? deadlineDate, String authorId, String authorName, String authorDesignation, String? club,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$UpdateDocCopyWithImpl<$Res>
    implements _$UpdateDocCopyWith<$Res> {
  __$UpdateDocCopyWithImpl(this._self, this._then);

  final _UpdateDoc _self;
  final $Res Function(_UpdateDoc) _then;

/// Create a copy of UpdateDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? deadlineDate = freezed,Object? authorId = null,Object? authorName = null,Object? authorDesignation = null,Object? club = freezed,Object? createdAt = null,}) {
  return _then(_UpdateDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,deadlineDate: freezed == deadlineDate ? _self.deadlineDate : deadlineDate // ignore: cast_nullable_to_non_nullable
as DateTime?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorDesignation: null == authorDesignation ? _self.authorDesignation : authorDesignation // ignore: cast_nullable_to_non_nullable
as String,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
