// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentDoc {

 String get id; String get userId; String get commentText;@DateTimeConverter() DateTime get createdAt; String? get sentimentLabel; double? get sentimentScore;
/// Create a copy of CommentDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentDocCopyWith<CommentDoc> get copyWith => _$CommentDocCopyWithImpl<CommentDoc>(this as CommentDoc, _$identity);

  /// Serializes this CommentDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.commentText, commentText) || other.commentText == commentText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sentimentLabel, sentimentLabel) || other.sentimentLabel == sentimentLabel)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,commentText,createdAt,sentimentLabel,sentimentScore);

@override
String toString() {
  return 'CommentDoc(id: $id, userId: $userId, commentText: $commentText, createdAt: $createdAt, sentimentLabel: $sentimentLabel, sentimentScore: $sentimentScore)';
}


}

/// @nodoc
abstract mixin class $CommentDocCopyWith<$Res>  {
  factory $CommentDocCopyWith(CommentDoc value, $Res Function(CommentDoc) _then) = _$CommentDocCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String commentText,@DateTimeConverter() DateTime createdAt, String? sentimentLabel, double? sentimentScore
});




}
/// @nodoc
class _$CommentDocCopyWithImpl<$Res>
    implements $CommentDocCopyWith<$Res> {
  _$CommentDocCopyWithImpl(this._self, this._then);

  final CommentDoc _self;
  final $Res Function(CommentDoc) _then;

/// Create a copy of CommentDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? commentText = null,Object? createdAt = null,Object? sentimentLabel = freezed,Object? sentimentScore = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,commentText: null == commentText ? _self.commentText : commentText // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sentimentLabel: freezed == sentimentLabel ? _self.sentimentLabel : sentimentLabel // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentDoc].
extension CommentDocPatterns on CommentDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentDoc value)  $default,){
final _that = this;
switch (_that) {
case _CommentDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentDoc value)?  $default,){
final _that = this;
switch (_that) {
case _CommentDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String commentText, @DateTimeConverter()  DateTime createdAt,  String? sentimentLabel,  double? sentimentScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentDoc() when $default != null:
return $default(_that.id,_that.userId,_that.commentText,_that.createdAt,_that.sentimentLabel,_that.sentimentScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String commentText, @DateTimeConverter()  DateTime createdAt,  String? sentimentLabel,  double? sentimentScore)  $default,) {final _that = this;
switch (_that) {
case _CommentDoc():
return $default(_that.id,_that.userId,_that.commentText,_that.createdAt,_that.sentimentLabel,_that.sentimentScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String commentText, @DateTimeConverter()  DateTime createdAt,  String? sentimentLabel,  double? sentimentScore)?  $default,) {final _that = this;
switch (_that) {
case _CommentDoc() when $default != null:
return $default(_that.id,_that.userId,_that.commentText,_that.createdAt,_that.sentimentLabel,_that.sentimentScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentDoc implements CommentDoc {
  const _CommentDoc({required this.id, required this.userId, required this.commentText, @DateTimeConverter() required this.createdAt, this.sentimentLabel, this.sentimentScore});
  factory _CommentDoc.fromJson(Map<String, dynamic> json) => _$CommentDocFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String commentText;
@override@DateTimeConverter() final  DateTime createdAt;
@override final  String? sentimentLabel;
@override final  double? sentimentScore;

/// Create a copy of CommentDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentDocCopyWith<_CommentDoc> get copyWith => __$CommentDocCopyWithImpl<_CommentDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.commentText, commentText) || other.commentText == commentText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sentimentLabel, sentimentLabel) || other.sentimentLabel == sentimentLabel)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,commentText,createdAt,sentimentLabel,sentimentScore);

@override
String toString() {
  return 'CommentDoc(id: $id, userId: $userId, commentText: $commentText, createdAt: $createdAt, sentimentLabel: $sentimentLabel, sentimentScore: $sentimentScore)';
}


}

/// @nodoc
abstract mixin class _$CommentDocCopyWith<$Res> implements $CommentDocCopyWith<$Res> {
  factory _$CommentDocCopyWith(_CommentDoc value, $Res Function(_CommentDoc) _then) = __$CommentDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String commentText,@DateTimeConverter() DateTime createdAt, String? sentimentLabel, double? sentimentScore
});




}
/// @nodoc
class __$CommentDocCopyWithImpl<$Res>
    implements _$CommentDocCopyWith<$Res> {
  __$CommentDocCopyWithImpl(this._self, this._then);

  final _CommentDoc _self;
  final $Res Function(_CommentDoc) _then;

/// Create a copy of CommentDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? commentText = null,Object? createdAt = null,Object? sentimentLabel = freezed,Object? sentimentScore = freezed,}) {
  return _then(_CommentDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,commentText: null == commentText ? _self.commentText : commentText // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sentimentLabel: freezed == sentimentLabel ? _self.sentimentLabel : sentimentLabel // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
