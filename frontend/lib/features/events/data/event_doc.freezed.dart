// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventDoc {

 String get id; String get title; String get description; String get venue;@DateTimeConverter() DateTime get eventDate;@DateTimeConverter() DateTime? get endDate; int get maxCapacity; int get currentRegistrations;@DateTimeConverter() DateTime get registrationDeadline; Map<String, dynamic>? get customFormSchema; String get tag; String? get bannerUrl; String get createdBy;@DateTimeConverter() DateTime get createdAt;
/// Create a copy of EventDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDocCopyWith<EventDoc> get copyWith => _$EventDocCopyWithImpl<EventDoc>(this as EventDoc, _$identity);

  /// Serializes this EventDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.currentRegistrations, currentRegistrations) || other.currentRegistrations == currentRegistrations)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other.customFormSchema, customFormSchema)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,venue,eventDate,endDate,maxCapacity,currentRegistrations,registrationDeadline,const DeepCollectionEquality().hash(customFormSchema),tag,bannerUrl,createdBy,createdAt);

@override
String toString() {
  return 'EventDoc(id: $id, title: $title, description: $description, venue: $venue, eventDate: $eventDate, endDate: $endDate, maxCapacity: $maxCapacity, currentRegistrations: $currentRegistrations, registrationDeadline: $registrationDeadline, customFormSchema: $customFormSchema, tag: $tag, bannerUrl: $bannerUrl, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EventDocCopyWith<$Res>  {
  factory $EventDocCopyWith(EventDoc value, $Res Function(EventDoc) _then) = _$EventDocCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String venue,@DateTimeConverter() DateTime eventDate,@DateTimeConverter() DateTime? endDate, int maxCapacity, int currentRegistrations,@DateTimeConverter() DateTime registrationDeadline, Map<String, dynamic>? customFormSchema, String tag, String? bannerUrl, String createdBy,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$EventDocCopyWithImpl<$Res>
    implements $EventDocCopyWith<$Res> {
  _$EventDocCopyWithImpl(this._self, this._then);

  final EventDoc _self;
  final $Res Function(EventDoc) _then;

/// Create a copy of EventDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? venue = null,Object? eventDate = null,Object? endDate = freezed,Object? maxCapacity = null,Object? currentRegistrations = null,Object? registrationDeadline = null,Object? customFormSchema = freezed,Object? tag = null,Object? bannerUrl = freezed,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,currentRegistrations: null == currentRegistrations ? _self.currentRegistrations : currentRegistrations // ignore: cast_nullable_to_non_nullable
as int,registrationDeadline: null == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,customFormSchema: freezed == customFormSchema ? _self.customFormSchema : customFormSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDoc].
extension EventDocPatterns on EventDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDoc value)  $default,){
final _that = this;
switch (_that) {
case _EventDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDoc value)?  $default,){
final _that = this;
switch (_that) {
case _EventDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String venue, @DateTimeConverter()  DateTime eventDate, @DateTimeConverter()  DateTime? endDate,  int maxCapacity,  int currentRegistrations, @DateTimeConverter()  DateTime registrationDeadline,  Map<String, dynamic>? customFormSchema,  String tag,  String? bannerUrl,  String createdBy, @DateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDoc() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.venue,_that.eventDate,_that.endDate,_that.maxCapacity,_that.currentRegistrations,_that.registrationDeadline,_that.customFormSchema,_that.tag,_that.bannerUrl,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String venue, @DateTimeConverter()  DateTime eventDate, @DateTimeConverter()  DateTime? endDate,  int maxCapacity,  int currentRegistrations, @DateTimeConverter()  DateTime registrationDeadline,  Map<String, dynamic>? customFormSchema,  String tag,  String? bannerUrl,  String createdBy, @DateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventDoc():
return $default(_that.id,_that.title,_that.description,_that.venue,_that.eventDate,_that.endDate,_that.maxCapacity,_that.currentRegistrations,_that.registrationDeadline,_that.customFormSchema,_that.tag,_that.bannerUrl,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String venue, @DateTimeConverter()  DateTime eventDate, @DateTimeConverter()  DateTime? endDate,  int maxCapacity,  int currentRegistrations, @DateTimeConverter()  DateTime registrationDeadline,  Map<String, dynamic>? customFormSchema,  String tag,  String? bannerUrl,  String createdBy, @DateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventDoc() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.venue,_that.eventDate,_that.endDate,_that.maxCapacity,_that.currentRegistrations,_that.registrationDeadline,_that.customFormSchema,_that.tag,_that.bannerUrl,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventDoc implements EventDoc {
  const _EventDoc({required this.id, required this.title, required this.description, required this.venue, @DateTimeConverter() required this.eventDate, @DateTimeConverter() this.endDate, required this.maxCapacity, this.currentRegistrations = 0, @DateTimeConverter() required this.registrationDeadline, final  Map<String, dynamic>? customFormSchema, required this.tag, this.bannerUrl, required this.createdBy, @DateTimeConverter() required this.createdAt}): _customFormSchema = customFormSchema;
  factory _EventDoc.fromJson(Map<String, dynamic> json) => _$EventDocFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String venue;
@override@DateTimeConverter() final  DateTime eventDate;
@override@DateTimeConverter() final  DateTime? endDate;
@override final  int maxCapacity;
@override@JsonKey() final  int currentRegistrations;
@override@DateTimeConverter() final  DateTime registrationDeadline;
 final  Map<String, dynamic>? _customFormSchema;
@override Map<String, dynamic>? get customFormSchema {
  final value = _customFormSchema;
  if (value == null) return null;
  if (_customFormSchema is EqualUnmodifiableMapView) return _customFormSchema;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String tag;
@override final  String? bannerUrl;
@override final  String createdBy;
@override@DateTimeConverter() final  DateTime createdAt;

/// Create a copy of EventDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDocCopyWith<_EventDoc> get copyWith => __$EventDocCopyWithImpl<_EventDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDoc&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.currentRegistrations, currentRegistrations) || other.currentRegistrations == currentRegistrations)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other._customFormSchema, _customFormSchema)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,venue,eventDate,endDate,maxCapacity,currentRegistrations,registrationDeadline,const DeepCollectionEquality().hash(_customFormSchema),tag,bannerUrl,createdBy,createdAt);

@override
String toString() {
  return 'EventDoc(id: $id, title: $title, description: $description, venue: $venue, eventDate: $eventDate, endDate: $endDate, maxCapacity: $maxCapacity, currentRegistrations: $currentRegistrations, registrationDeadline: $registrationDeadline, customFormSchema: $customFormSchema, tag: $tag, bannerUrl: $bannerUrl, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventDocCopyWith<$Res> implements $EventDocCopyWith<$Res> {
  factory _$EventDocCopyWith(_EventDoc value, $Res Function(_EventDoc) _then) = __$EventDocCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String venue,@DateTimeConverter() DateTime eventDate,@DateTimeConverter() DateTime? endDate, int maxCapacity, int currentRegistrations,@DateTimeConverter() DateTime registrationDeadline, Map<String, dynamic>? customFormSchema, String tag, String? bannerUrl, String createdBy,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$EventDocCopyWithImpl<$Res>
    implements _$EventDocCopyWith<$Res> {
  __$EventDocCopyWithImpl(this._self, this._then);

  final _EventDoc _self;
  final $Res Function(_EventDoc) _then;

/// Create a copy of EventDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? venue = null,Object? eventDate = null,Object? endDate = freezed,Object? maxCapacity = null,Object? currentRegistrations = null,Object? registrationDeadline = null,Object? customFormSchema = freezed,Object? tag = null,Object? bannerUrl = freezed,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_EventDoc(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,currentRegistrations: null == currentRegistrations ? _self.currentRegistrations : currentRegistrations // ignore: cast_nullable_to_non_nullable
as int,registrationDeadline: null == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,customFormSchema: freezed == customFormSchema ? _self._customFormSchema : customFormSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
