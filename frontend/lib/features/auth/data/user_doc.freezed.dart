// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDoc {

 String get uid; String get email; String get usn; String get fullName; UserRole get role; bool get profileComplete; String? get phone; String? get yearOfStudy; String? get batch; String? get instagramHandle; String? get personalWebsite; String? get profilePictureUrl; String? get bio; List<String> get skills; String? get githubUrl; String? get linkedinUrl; String? get twitterHandle; String? get discordHandle; String? get status;// e.g. pending_batch_review
@DateTimeConverter() DateTime? get createdAt;
/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDocCopyWith<UserDoc> get copyWith => _$UserDocCopyWithImpl<UserDoc>(this as UserDoc, _$identity);

  /// Serializes this UserDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.usn, usn) || other.usn == usn)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.personalWebsite, personalWebsite) || other.personalWebsite == personalWebsite)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.skills, skills)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordHandle, discordHandle) || other.discordHandle == discordHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,usn,fullName,role,profileComplete,phone,yearOfStudy,batch,instagramHandle,personalWebsite,profilePictureUrl,bio,const DeepCollectionEquality().hash(skills),githubUrl,linkedinUrl,twitterHandle,discordHandle,status,createdAt]);

@override
String toString() {
  return 'UserDoc(uid: $uid, email: $email, usn: $usn, fullName: $fullName, role: $role, profileComplete: $profileComplete, phone: $phone, yearOfStudy: $yearOfStudy, batch: $batch, instagramHandle: $instagramHandle, personalWebsite: $personalWebsite, profilePictureUrl: $profilePictureUrl, bio: $bio, skills: $skills, githubUrl: $githubUrl, linkedinUrl: $linkedinUrl, twitterHandle: $twitterHandle, discordHandle: $discordHandle, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserDocCopyWith<$Res>  {
  factory $UserDocCopyWith(UserDoc value, $Res Function(UserDoc) _then) = _$UserDocCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String usn, String fullName, UserRole role, bool profileComplete, String? phone, String? yearOfStudy, String? batch, String? instagramHandle, String? personalWebsite, String? profilePictureUrl, String? bio, List<String> skills, String? githubUrl, String? linkedinUrl, String? twitterHandle, String? discordHandle, String? status,@DateTimeConverter() DateTime? createdAt
});




}
/// @nodoc
class _$UserDocCopyWithImpl<$Res>
    implements $UserDocCopyWith<$Res> {
  _$UserDocCopyWithImpl(this._self, this._then);

  final UserDoc _self;
  final $Res Function(UserDoc) _then;

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? usn = null,Object? fullName = null,Object? role = null,Object? profileComplete = null,Object? phone = freezed,Object? yearOfStudy = freezed,Object? batch = freezed,Object? instagramHandle = freezed,Object? personalWebsite = freezed,Object? profilePictureUrl = freezed,Object? bio = freezed,Object? skills = null,Object? githubUrl = freezed,Object? linkedinUrl = freezed,Object? twitterHandle = freezed,Object? discordHandle = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,usn: null == usn ? _self.usn : usn // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,yearOfStudy: freezed == yearOfStudy ? _self.yearOfStudy : yearOfStudy // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,personalWebsite: freezed == personalWebsite ? _self.personalWebsite : personalWebsite // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,linkedinUrl: freezed == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String?,twitterHandle: freezed == twitterHandle ? _self.twitterHandle : twitterHandle // ignore: cast_nullable_to_non_nullable
as String?,discordHandle: freezed == discordHandle ? _self.discordHandle : discordHandle // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDoc].
extension UserDocPatterns on UserDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDoc value)  $default,){
final _that = this;
switch (_that) {
case _UserDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDoc value)?  $default,){
final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String usn,  String fullName,  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status, @DateTimeConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String usn,  String fullName,  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status, @DateTimeConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserDoc():
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String usn,  String fullName,  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status, @DateTimeConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDoc implements UserDoc {
  const _UserDoc({required this.uid, this.email = '', this.usn = '', this.fullName = '', this.role = UserRole.student, this.profileComplete = false, this.phone, this.yearOfStudy, this.batch, this.instagramHandle, this.personalWebsite, this.profilePictureUrl, this.bio, final  List<String> skills = const [], this.githubUrl, this.linkedinUrl, this.twitterHandle, this.discordHandle, this.status, @DateTimeConverter() this.createdAt}): _skills = skills;
  factory _UserDoc.fromJson(Map<String, dynamic> json) => _$UserDocFromJson(json);

@override final  String uid;
@override@JsonKey() final  String email;
@override@JsonKey() final  String usn;
@override@JsonKey() final  String fullName;
@override@JsonKey() final  UserRole role;
@override@JsonKey() final  bool profileComplete;
@override final  String? phone;
@override final  String? yearOfStudy;
@override final  String? batch;
@override final  String? instagramHandle;
@override final  String? personalWebsite;
@override final  String? profilePictureUrl;
@override final  String? bio;
 final  List<String> _skills;
@override@JsonKey() List<String> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}

@override final  String? githubUrl;
@override final  String? linkedinUrl;
@override final  String? twitterHandle;
@override final  String? discordHandle;
@override final  String? status;
// e.g. pending_batch_review
@override@DateTimeConverter() final  DateTime? createdAt;

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDocCopyWith<_UserDoc> get copyWith => __$UserDocCopyWithImpl<_UserDoc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDocToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.usn, usn) || other.usn == usn)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.personalWebsite, personalWebsite) || other.personalWebsite == personalWebsite)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._skills, _skills)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordHandle, discordHandle) || other.discordHandle == discordHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,usn,fullName,role,profileComplete,phone,yearOfStudy,batch,instagramHandle,personalWebsite,profilePictureUrl,bio,const DeepCollectionEquality().hash(_skills),githubUrl,linkedinUrl,twitterHandle,discordHandle,status,createdAt]);

@override
String toString() {
  return 'UserDoc(uid: $uid, email: $email, usn: $usn, fullName: $fullName, role: $role, profileComplete: $profileComplete, phone: $phone, yearOfStudy: $yearOfStudy, batch: $batch, instagramHandle: $instagramHandle, personalWebsite: $personalWebsite, profilePictureUrl: $profilePictureUrl, bio: $bio, skills: $skills, githubUrl: $githubUrl, linkedinUrl: $linkedinUrl, twitterHandle: $twitterHandle, discordHandle: $discordHandle, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserDocCopyWith<$Res> implements $UserDocCopyWith<$Res> {
  factory _$UserDocCopyWith(_UserDoc value, $Res Function(_UserDoc) _then) = __$UserDocCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String usn, String fullName, UserRole role, bool profileComplete, String? phone, String? yearOfStudy, String? batch, String? instagramHandle, String? personalWebsite, String? profilePictureUrl, String? bio, List<String> skills, String? githubUrl, String? linkedinUrl, String? twitterHandle, String? discordHandle, String? status,@DateTimeConverter() DateTime? createdAt
});




}
/// @nodoc
class __$UserDocCopyWithImpl<$Res>
    implements _$UserDocCopyWith<$Res> {
  __$UserDocCopyWithImpl(this._self, this._then);

  final _UserDoc _self;
  final $Res Function(_UserDoc) _then;

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? usn = null,Object? fullName = null,Object? role = null,Object? profileComplete = null,Object? phone = freezed,Object? yearOfStudy = freezed,Object? batch = freezed,Object? instagramHandle = freezed,Object? personalWebsite = freezed,Object? profilePictureUrl = freezed,Object? bio = freezed,Object? skills = null,Object? githubUrl = freezed,Object? linkedinUrl = freezed,Object? twitterHandle = freezed,Object? discordHandle = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_UserDoc(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,usn: null == usn ? _self.usn : usn // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,yearOfStudy: freezed == yearOfStudy ? _self.yearOfStudy : yearOfStudy // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,personalWebsite: freezed == personalWebsite ? _self.personalWebsite : personalWebsite // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,linkedinUrl: freezed == linkedinUrl ? _self.linkedinUrl : linkedinUrl // ignore: cast_nullable_to_non_nullable
as String?,twitterHandle: freezed == twitterHandle ? _self.twitterHandle : twitterHandle // ignore: cast_nullable_to_non_nullable
as String?,discordHandle: freezed == discordHandle ? _self.discordHandle : discordHandle // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
