// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectDoc {

 String get id; String get title; String get author; String get imageAsset; List<String> get tags; bool get lookingForTeammate;
/// Create a copy of ProjectDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDocCopyWith<ProjectDoc> get copyWith => _$ProjectDocCopyWithImpl<ProjectDoc>(this as ProjectDoc, _$identity);

  /// Serializes this ProjectDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.lookingForTeammate, lookingForTeammate) || other.lookingForTeammate == lookingForTeammate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,imageAsset,const DeepCollectionEquality().hash(tags),lookingForTeammate);

@override
String toString() {
  return 'ProjectDoc(id: $id, title: $title, author: $author, imageAsset: $imageAsset, tags: $tags, lookingForTeammate: $lookingForTeammate)';
}


}

/// @nodoc
abstract mixin class $ProjectDocCopyWith<$Res>  {
  factory $ProjectDocCopyWith(ProjectDoc value, $Res Function(ProjectDoc) _then) = _$ProjectDocCopyWithImpl;
@useResult
$Res call({
 String id, String title, String author, String imageAsset, List<String> tags, bool lookingForTeammate
});




}
/// @nodoc
class _$ProjectDocCopyWithImpl<$Res>
    implements $ProjectDocCopyWith<$Res> {
  _$ProjectDocCopyWithImpl(this._self, this._then);

  final ProjectDoc _self;
  final $Res Function(ProjectDoc) _then;

/// Create a copy of ProjectDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? imageAsset = null,Object? tags = null,Object? lookingForTeammate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,lookingForTeammate: null == lookingForTeammate ? _self.lookingForTeammate : lookingForTeammate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectDoc].
extension ProjectDocPatterns on ProjectDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectDoc value)  $default,){
final _that = this;
switch (_that) {
case _ProjectDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectDoc value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String imageAsset,  List<String> tags,  bool lookingForTeammate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.imageAsset,_that.tags,_that.lookingForTeammate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String author,  String imageAsset,  List<String> tags,  bool lookingForTeammate)  $default,) {final _that = this;
switch (_that) {
case _ProjectDoc():
return $default(_that.id,_that.title,_that.author,_that.imageAsset,_that.tags,_that.lookingForTeammate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String author,  String imageAsset,  List<String> tags,  bool lookingForTeammate)?  $default,) {final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.imageAsset,_that.tags,_that.lookingForTeammate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectDoc implements ProjectDoc {
  const _ProjectDoc({required this.id, required this.title, required this.author, required this.imageAsset, required final  List<String> tags, this.lookingForTeammate = false}): _tags = tags;
  factory _ProjectDoc.fromJson(Map<String, dynamic> json) => _$ProjectDocFromJson(json);

@override final  String id;
@override final  String title;
@override final  String author;
@override final  String imageAsset;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool lookingForTeammate;

/// Create a copy of ProjectDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectDocCopyWith<_ProjectDoc> get copyWith => __$ProjectDocCopyWithImpl<_ProjectDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.lookingForTeammate, lookingForTeammate) || other.lookingForTeammate == lookingForTeammate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,imageAsset,const DeepCollectionEquality().hash(_tags),lookingForTeammate);

@override
String toString() {
  return 'ProjectDoc(id: $id, title: $title, author: $author, imageAsset: $imageAsset, tags: $tags, lookingForTeammate: $lookingForTeammate)';
}


}

/// @nodoc
abstract mixin class _$ProjectDocCopyWith<$Res> implements $ProjectDocCopyWith<$Res> {
  factory _$ProjectDocCopyWith(_ProjectDoc value, $Res Function(_ProjectDoc) _then) = __$ProjectDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String author, String imageAsset, List<String> tags, bool lookingForTeammate
});




}
/// @nodoc
class __$ProjectDocCopyWithImpl<$Res>
    implements _$ProjectDocCopyWith<$Res> {
  __$ProjectDocCopyWithImpl(this._self, this._then);

  final _ProjectDoc _self;
  final $Res Function(_ProjectDoc) _then;

/// Create a copy of ProjectDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? imageAsset = null,Object? tags = null,Object? lookingForTeammate = null,}) {
  return _then(_ProjectDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,lookingForTeammate: null == lookingForTeammate ? _self.lookingForTeammate : lookingForTeammate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
