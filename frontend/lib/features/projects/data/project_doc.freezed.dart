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

 String get id; String get title; String get description; String get author;// Keep for backward compatibility/display name
 String get ownerId; List<String> get contributorIds; List<String> get imageUrls; List<String> get tags; bool get lookingForTeammate;
/// Create a copy of ProjectDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDocCopyWith<ProjectDoc> get copyWith => _$ProjectDocCopyWithImpl<ProjectDoc>(this as ProjectDoc, _$identity);

  /// Serializes this ProjectDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.contributorIds, contributorIds)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.lookingForTeammate, lookingForTeammate) || other.lookingForTeammate == lookingForTeammate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,author,ownerId,const DeepCollectionEquality().hash(contributorIds),const DeepCollectionEquality().hash(imageUrls),const DeepCollectionEquality().hash(tags),lookingForTeammate);

@override
String toString() {
  return 'ProjectDoc(id: $id, title: $title, description: $description, author: $author, ownerId: $ownerId, contributorIds: $contributorIds, imageUrls: $imageUrls, tags: $tags, lookingForTeammate: $lookingForTeammate)';
}


}

/// @nodoc
abstract mixin class $ProjectDocCopyWith<$Res>  {
  factory $ProjectDocCopyWith(ProjectDoc value, $Res Function(ProjectDoc) _then) = _$ProjectDocCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String author, String ownerId, List<String> contributorIds, List<String> imageUrls, List<String> tags, bool lookingForTeammate
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? author = null,Object? ownerId = null,Object? contributorIds = null,Object? imageUrls = null,Object? tags = null,Object? lookingForTeammate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,contributorIds: null == contributorIds ? _self.contributorIds : contributorIds // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String author,  String ownerId,  List<String> contributorIds,  List<String> imageUrls,  List<String> tags,  bool lookingForTeammate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.author,_that.ownerId,_that.contributorIds,_that.imageUrls,_that.tags,_that.lookingForTeammate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String author,  String ownerId,  List<String> contributorIds,  List<String> imageUrls,  List<String> tags,  bool lookingForTeammate)  $default,) {final _that = this;
switch (_that) {
case _ProjectDoc():
return $default(_that.id,_that.title,_that.description,_that.author,_that.ownerId,_that.contributorIds,_that.imageUrls,_that.tags,_that.lookingForTeammate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String author,  String ownerId,  List<String> contributorIds,  List<String> imageUrls,  List<String> tags,  bool lookingForTeammate)?  $default,) {final _that = this;
switch (_that) {
case _ProjectDoc() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.author,_that.ownerId,_that.contributorIds,_that.imageUrls,_that.tags,_that.lookingForTeammate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectDoc implements ProjectDoc {
  const _ProjectDoc({required this.id, required this.title, this.description = '', required this.author, required this.ownerId, final  List<String> contributorIds = const [], final  List<String> imageUrls = const [], required final  List<String> tags, this.lookingForTeammate = false}): _contributorIds = contributorIds,_imageUrls = imageUrls,_tags = tags;
  factory _ProjectDoc.fromJson(Map<String, dynamic> json) => _$ProjectDocFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override final  String author;
// Keep for backward compatibility/display name
@override final  String ownerId;
 final  List<String> _contributorIds;
@override@JsonKey() List<String> get contributorIds {
  if (_contributorIds is EqualUnmodifiableListView) return _contributorIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contributorIds);
}

 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other._contributorIds, _contributorIds)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.lookingForTeammate, lookingForTeammate) || other.lookingForTeammate == lookingForTeammate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,author,ownerId,const DeepCollectionEquality().hash(_contributorIds),const DeepCollectionEquality().hash(_imageUrls),const DeepCollectionEquality().hash(_tags),lookingForTeammate);

@override
String toString() {
  return 'ProjectDoc(id: $id, title: $title, description: $description, author: $author, ownerId: $ownerId, contributorIds: $contributorIds, imageUrls: $imageUrls, tags: $tags, lookingForTeammate: $lookingForTeammate)';
}


}

/// @nodoc
abstract mixin class _$ProjectDocCopyWith<$Res> implements $ProjectDocCopyWith<$Res> {
  factory _$ProjectDocCopyWith(_ProjectDoc value, $Res Function(_ProjectDoc) _then) = __$ProjectDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String author, String ownerId, List<String> contributorIds, List<String> imageUrls, List<String> tags, bool lookingForTeammate
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? author = null,Object? ownerId = null,Object? contributorIds = null,Object? imageUrls = null,Object? tags = null,Object? lookingForTeammate = null,}) {
  return _then(_ProjectDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,contributorIds: null == contributorIds ? _self._contributorIds : contributorIds // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,lookingForTeammate: null == lookingForTeammate ? _self.lookingForTeammate : lookingForTeammate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
