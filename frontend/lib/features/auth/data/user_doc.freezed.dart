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
mixin _$PrivacySettings {

 bool get publicBio; bool get publicGithub; bool get publicLinkedin; bool get publicPersonalWebsite; bool get publicInstagram; bool get publicTwitter;
/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacySettingsCopyWith<PrivacySettings> get copyWith => _$PrivacySettingsCopyWithImpl<PrivacySettings>(this as PrivacySettings, _$identity);

  /// Serializes this PrivacySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacySettings&&(identical(other.publicBio, publicBio) || other.publicBio == publicBio)&&(identical(other.publicGithub, publicGithub) || other.publicGithub == publicGithub)&&(identical(other.publicLinkedin, publicLinkedin) || other.publicLinkedin == publicLinkedin)&&(identical(other.publicPersonalWebsite, publicPersonalWebsite) || other.publicPersonalWebsite == publicPersonalWebsite)&&(identical(other.publicInstagram, publicInstagram) || other.publicInstagram == publicInstagram)&&(identical(other.publicTwitter, publicTwitter) || other.publicTwitter == publicTwitter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicBio,publicGithub,publicLinkedin,publicPersonalWebsite,publicInstagram,publicTwitter);

@override
String toString() {
  return 'PrivacySettings(publicBio: $publicBio, publicGithub: $publicGithub, publicLinkedin: $publicLinkedin, publicPersonalWebsite: $publicPersonalWebsite, publicInstagram: $publicInstagram, publicTwitter: $publicTwitter)';
}


}

/// @nodoc
abstract mixin class $PrivacySettingsCopyWith<$Res>  {
  factory $PrivacySettingsCopyWith(PrivacySettings value, $Res Function(PrivacySettings) _then) = _$PrivacySettingsCopyWithImpl;
@useResult
$Res call({
 bool publicBio, bool publicGithub, bool publicLinkedin, bool publicPersonalWebsite, bool publicInstagram, bool publicTwitter
});




}
/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._self, this._then);

  final PrivacySettings _self;
  final $Res Function(PrivacySettings) _then;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicBio = null,Object? publicGithub = null,Object? publicLinkedin = null,Object? publicPersonalWebsite = null,Object? publicInstagram = null,Object? publicTwitter = null,}) {
  return _then(_self.copyWith(
publicBio: null == publicBio ? _self.publicBio : publicBio // ignore: cast_nullable_to_non_nullable
as bool,publicGithub: null == publicGithub ? _self.publicGithub : publicGithub // ignore: cast_nullable_to_non_nullable
as bool,publicLinkedin: null == publicLinkedin ? _self.publicLinkedin : publicLinkedin // ignore: cast_nullable_to_non_nullable
as bool,publicPersonalWebsite: null == publicPersonalWebsite ? _self.publicPersonalWebsite : publicPersonalWebsite // ignore: cast_nullable_to_non_nullable
as bool,publicInstagram: null == publicInstagram ? _self.publicInstagram : publicInstagram // ignore: cast_nullable_to_non_nullable
as bool,publicTwitter: null == publicTwitter ? _self.publicTwitter : publicTwitter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacySettings].
extension PrivacySettingsPatterns on PrivacySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacySettings value)  $default,){
final _that = this;
switch (_that) {
case _PrivacySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacySettings value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool publicBio,  bool publicGithub,  bool publicLinkedin,  bool publicPersonalWebsite,  bool publicInstagram,  bool publicTwitter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
return $default(_that.publicBio,_that.publicGithub,_that.publicLinkedin,_that.publicPersonalWebsite,_that.publicInstagram,_that.publicTwitter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool publicBio,  bool publicGithub,  bool publicLinkedin,  bool publicPersonalWebsite,  bool publicInstagram,  bool publicTwitter)  $default,) {final _that = this;
switch (_that) {
case _PrivacySettings():
return $default(_that.publicBio,_that.publicGithub,_that.publicLinkedin,_that.publicPersonalWebsite,_that.publicInstagram,_that.publicTwitter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool publicBio,  bool publicGithub,  bool publicLinkedin,  bool publicPersonalWebsite,  bool publicInstagram,  bool publicTwitter)?  $default,) {final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
return $default(_that.publicBio,_that.publicGithub,_that.publicLinkedin,_that.publicPersonalWebsite,_that.publicInstagram,_that.publicTwitter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivacySettings implements PrivacySettings {
  const _PrivacySettings({this.publicBio = true, this.publicGithub = true, this.publicLinkedin = true, this.publicPersonalWebsite = true, this.publicInstagram = true, this.publicTwitter = true});
  factory _PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);

@override@JsonKey() final  bool publicBio;
@override@JsonKey() final  bool publicGithub;
@override@JsonKey() final  bool publicLinkedin;
@override@JsonKey() final  bool publicPersonalWebsite;
@override@JsonKey() final  bool publicInstagram;
@override@JsonKey() final  bool publicTwitter;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacySettingsCopyWith<_PrivacySettings> get copyWith => __$PrivacySettingsCopyWithImpl<_PrivacySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivacySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacySettings&&(identical(other.publicBio, publicBio) || other.publicBio == publicBio)&&(identical(other.publicGithub, publicGithub) || other.publicGithub == publicGithub)&&(identical(other.publicLinkedin, publicLinkedin) || other.publicLinkedin == publicLinkedin)&&(identical(other.publicPersonalWebsite, publicPersonalWebsite) || other.publicPersonalWebsite == publicPersonalWebsite)&&(identical(other.publicInstagram, publicInstagram) || other.publicInstagram == publicInstagram)&&(identical(other.publicTwitter, publicTwitter) || other.publicTwitter == publicTwitter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicBio,publicGithub,publicLinkedin,publicPersonalWebsite,publicInstagram,publicTwitter);

@override
String toString() {
  return 'PrivacySettings(publicBio: $publicBio, publicGithub: $publicGithub, publicLinkedin: $publicLinkedin, publicPersonalWebsite: $publicPersonalWebsite, publicInstagram: $publicInstagram, publicTwitter: $publicTwitter)';
}


}

/// @nodoc
abstract mixin class _$PrivacySettingsCopyWith<$Res> implements $PrivacySettingsCopyWith<$Res> {
  factory _$PrivacySettingsCopyWith(_PrivacySettings value, $Res Function(_PrivacySettings) _then) = __$PrivacySettingsCopyWithImpl;
@override @useResult
$Res call({
 bool publicBio, bool publicGithub, bool publicLinkedin, bool publicPersonalWebsite, bool publicInstagram, bool publicTwitter
});




}
/// @nodoc
class __$PrivacySettingsCopyWithImpl<$Res>
    implements _$PrivacySettingsCopyWith<$Res> {
  __$PrivacySettingsCopyWithImpl(this._self, this._then);

  final _PrivacySettings _self;
  final $Res Function(_PrivacySettings) _then;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicBio = null,Object? publicGithub = null,Object? publicLinkedin = null,Object? publicPersonalWebsite = null,Object? publicInstagram = null,Object? publicTwitter = null,}) {
  return _then(_PrivacySettings(
publicBio: null == publicBio ? _self.publicBio : publicBio // ignore: cast_nullable_to_non_nullable
as bool,publicGithub: null == publicGithub ? _self.publicGithub : publicGithub // ignore: cast_nullable_to_non_nullable
as bool,publicLinkedin: null == publicLinkedin ? _self.publicLinkedin : publicLinkedin // ignore: cast_nullable_to_non_nullable
as bool,publicPersonalWebsite: null == publicPersonalWebsite ? _self.publicPersonalWebsite : publicPersonalWebsite // ignore: cast_nullable_to_non_nullable
as bool,publicInstagram: null == publicInstagram ? _self.publicInstagram : publicInstagram // ignore: cast_nullable_to_non_nullable
as bool,publicTwitter: null == publicTwitter ? _self.publicTwitter : publicTwitter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

 bool get eventsEnabled; bool get updatesEnabled; bool get memoriesEnabled;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.eventsEnabled, eventsEnabled) || other.eventsEnabled == eventsEnabled)&&(identical(other.updatesEnabled, updatesEnabled) || other.updatesEnabled == updatesEnabled)&&(identical(other.memoriesEnabled, memoriesEnabled) || other.memoriesEnabled == memoriesEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventsEnabled,updatesEnabled,memoriesEnabled);

@override
String toString() {
  return 'NotificationSettings(eventsEnabled: $eventsEnabled, updatesEnabled: $updatesEnabled, memoriesEnabled: $memoriesEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 bool eventsEnabled, bool updatesEnabled, bool memoriesEnabled
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventsEnabled = null,Object? updatesEnabled = null,Object? memoriesEnabled = null,}) {
  return _then(_self.copyWith(
eventsEnabled: null == eventsEnabled ? _self.eventsEnabled : eventsEnabled // ignore: cast_nullable_to_non_nullable
as bool,updatesEnabled: null == updatesEnabled ? _self.updatesEnabled : updatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,memoriesEnabled: null == memoriesEnabled ? _self.memoriesEnabled : memoriesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool eventsEnabled,  bool updatesEnabled,  bool memoriesEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.eventsEnabled,_that.updatesEnabled,_that.memoriesEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool eventsEnabled,  bool updatesEnabled,  bool memoriesEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.eventsEnabled,_that.updatesEnabled,_that.memoriesEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool eventsEnabled,  bool updatesEnabled,  bool memoriesEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.eventsEnabled,_that.updatesEnabled,_that.memoriesEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings implements NotificationSettings {
  const _NotificationSettings({this.eventsEnabled = true, this.updatesEnabled = true, this.memoriesEnabled = true});
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

@override@JsonKey() final  bool eventsEnabled;
@override@JsonKey() final  bool updatesEnabled;
@override@JsonKey() final  bool memoriesEnabled;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.eventsEnabled, eventsEnabled) || other.eventsEnabled == eventsEnabled)&&(identical(other.updatesEnabled, updatesEnabled) || other.updatesEnabled == updatesEnabled)&&(identical(other.memoriesEnabled, memoriesEnabled) || other.memoriesEnabled == memoriesEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventsEnabled,updatesEnabled,memoriesEnabled);

@override
String toString() {
  return 'NotificationSettings(eventsEnabled: $eventsEnabled, updatesEnabled: $updatesEnabled, memoriesEnabled: $memoriesEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool eventsEnabled, bool updatesEnabled, bool memoriesEnabled
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventsEnabled = null,Object? updatesEnabled = null,Object? memoriesEnabled = null,}) {
  return _then(_NotificationSettings(
eventsEnabled: null == eventsEnabled ? _self.eventsEnabled : eventsEnabled // ignore: cast_nullable_to_non_nullable
as bool,updatesEnabled: null == updatesEnabled ? _self.updatesEnabled : updatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,memoriesEnabled: null == memoriesEnabled ? _self.memoriesEnabled : memoriesEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UserDoc {

 String get uid; String get email; String get usn; String get fullName;@JsonKey(unknownEnumValue: UserRole.student) UserRole get role; bool get profileComplete; String? get phone; String? get yearOfStudy; String? get batch; String? get instagramHandle; String? get personalWebsite; String? get profilePictureUrl; String? get bio; List<String> get skills; String? get githubUrl; String? get linkedinUrl; String? get twitterHandle; String? get discordHandle; String? get status;// e.g. pending_batch_review
 bool get mustResetPassword; String? get facultyId; String? get designation; String? get club; String? get fcmToken; PrivacySettings get privacySettings; NotificationSettings get notificationSettings;@DateTimeConverter() DateTime? get createdAt;
/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDocCopyWith<UserDoc> get copyWith => _$UserDocCopyWithImpl<UserDoc>(this as UserDoc, _$identity);

  /// Serializes this UserDoc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.usn, usn) || other.usn == usn)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.personalWebsite, personalWebsite) || other.personalWebsite == personalWebsite)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.skills, skills)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordHandle, discordHandle) || other.discordHandle == discordHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.mustResetPassword, mustResetPassword) || other.mustResetPassword == mustResetPassword)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.designation, designation) || other.designation == designation)&&(identical(other.club, club) || other.club == club)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.privacySettings, privacySettings) || other.privacySettings == privacySettings)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,usn,fullName,role,profileComplete,phone,yearOfStudy,batch,instagramHandle,personalWebsite,profilePictureUrl,bio,const DeepCollectionEquality().hash(skills),githubUrl,linkedinUrl,twitterHandle,discordHandle,status,mustResetPassword,facultyId,designation,club,fcmToken,privacySettings,notificationSettings,createdAt]);

@override
String toString() {
  return 'UserDoc(uid: $uid, email: $email, usn: $usn, fullName: $fullName, role: $role, profileComplete: $profileComplete, phone: $phone, yearOfStudy: $yearOfStudy, batch: $batch, instagramHandle: $instagramHandle, personalWebsite: $personalWebsite, profilePictureUrl: $profilePictureUrl, bio: $bio, skills: $skills, githubUrl: $githubUrl, linkedinUrl: $linkedinUrl, twitterHandle: $twitterHandle, discordHandle: $discordHandle, status: $status, mustResetPassword: $mustResetPassword, facultyId: $facultyId, designation: $designation, club: $club, fcmToken: $fcmToken, privacySettings: $privacySettings, notificationSettings: $notificationSettings, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserDocCopyWith<$Res>  {
  factory $UserDocCopyWith(UserDoc value, $Res Function(UserDoc) _then) = _$UserDocCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String usn, String fullName,@JsonKey(unknownEnumValue: UserRole.student) UserRole role, bool profileComplete, String? phone, String? yearOfStudy, String? batch, String? instagramHandle, String? personalWebsite, String? profilePictureUrl, String? bio, List<String> skills, String? githubUrl, String? linkedinUrl, String? twitterHandle, String? discordHandle, String? status, bool mustResetPassword, String? facultyId, String? designation, String? club, String? fcmToken, PrivacySettings privacySettings, NotificationSettings notificationSettings,@DateTimeConverter() DateTime? createdAt
});


$PrivacySettingsCopyWith<$Res> get privacySettings;$NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class _$UserDocCopyWithImpl<$Res>
    implements $UserDocCopyWith<$Res> {
  _$UserDocCopyWithImpl(this._self, this._then);

  final UserDoc _self;
  final $Res Function(UserDoc) _then;

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? usn = null,Object? fullName = null,Object? role = null,Object? profileComplete = null,Object? phone = freezed,Object? yearOfStudy = freezed,Object? batch = freezed,Object? instagramHandle = freezed,Object? personalWebsite = freezed,Object? profilePictureUrl = freezed,Object? bio = freezed,Object? skills = null,Object? githubUrl = freezed,Object? linkedinUrl = freezed,Object? twitterHandle = freezed,Object? discordHandle = freezed,Object? status = freezed,Object? mustResetPassword = null,Object? facultyId = freezed,Object? designation = freezed,Object? club = freezed,Object? fcmToken = freezed,Object? privacySettings = null,Object? notificationSettings = null,Object? createdAt = freezed,}) {
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
as String?,mustResetPassword: null == mustResetPassword ? _self.mustResetPassword : mustResetPassword // ignore: cast_nullable_to_non_nullable
as bool,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,designation: freezed == designation ? _self.designation : designation // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,privacySettings: null == privacySettings ? _self.privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as PrivacySettings,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivacySettingsCopyWith<$Res> get privacySettings {
  
  return $PrivacySettingsCopyWith<$Res>(_self.privacySettings, (value) {
    return _then(_self.copyWith(privacySettings: value));
  });
}/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String usn,  String fullName, @JsonKey(unknownEnumValue: UserRole.student)  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status,  bool mustResetPassword,  String? facultyId,  String? designation,  String? club,  String? fcmToken,  PrivacySettings privacySettings,  NotificationSettings notificationSettings, @DateTimeConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.mustResetPassword,_that.facultyId,_that.designation,_that.club,_that.fcmToken,_that.privacySettings,_that.notificationSettings,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String usn,  String fullName, @JsonKey(unknownEnumValue: UserRole.student)  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status,  bool mustResetPassword,  String? facultyId,  String? designation,  String? club,  String? fcmToken,  PrivacySettings privacySettings,  NotificationSettings notificationSettings, @DateTimeConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserDoc():
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.mustResetPassword,_that.facultyId,_that.designation,_that.club,_that.fcmToken,_that.privacySettings,_that.notificationSettings,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String usn,  String fullName, @JsonKey(unknownEnumValue: UserRole.student)  UserRole role,  bool profileComplete,  String? phone,  String? yearOfStudy,  String? batch,  String? instagramHandle,  String? personalWebsite,  String? profilePictureUrl,  String? bio,  List<String> skills,  String? githubUrl,  String? linkedinUrl,  String? twitterHandle,  String? discordHandle,  String? status,  bool mustResetPassword,  String? facultyId,  String? designation,  String? club,  String? fcmToken,  PrivacySettings privacySettings,  NotificationSettings notificationSettings, @DateTimeConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserDoc() when $default != null:
return $default(_that.uid,_that.email,_that.usn,_that.fullName,_that.role,_that.profileComplete,_that.phone,_that.yearOfStudy,_that.batch,_that.instagramHandle,_that.personalWebsite,_that.profilePictureUrl,_that.bio,_that.skills,_that.githubUrl,_that.linkedinUrl,_that.twitterHandle,_that.discordHandle,_that.status,_that.mustResetPassword,_that.facultyId,_that.designation,_that.club,_that.fcmToken,_that.privacySettings,_that.notificationSettings,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDoc implements UserDoc {
  const _UserDoc({required this.uid, this.email = '', this.usn = '', this.fullName = '', @JsonKey(unknownEnumValue: UserRole.student) this.role = UserRole.student, this.profileComplete = false, this.phone, this.yearOfStudy, this.batch, this.instagramHandle, this.personalWebsite, this.profilePictureUrl, this.bio, final  List<String> skills = const [], this.githubUrl, this.linkedinUrl, this.twitterHandle, this.discordHandle, this.status, this.mustResetPassword = false, this.facultyId, this.designation, this.club, this.fcmToken, this.privacySettings = const PrivacySettings(), this.notificationSettings = const NotificationSettings(), @DateTimeConverter() this.createdAt}): _skills = skills;
  factory _UserDoc.fromJson(Map<String, dynamic> json) => _$UserDocFromJson(json);

@override final  String uid;
@override@JsonKey() final  String email;
@override@JsonKey() final  String usn;
@override@JsonKey() final  String fullName;
@override@JsonKey(unknownEnumValue: UserRole.student) final  UserRole role;
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
@override@JsonKey() final  bool mustResetPassword;
@override final  String? facultyId;
@override final  String? designation;
@override final  String? club;
@override final  String? fcmToken;
@override@JsonKey() final  PrivacySettings privacySettings;
@override@JsonKey() final  NotificationSettings notificationSettings;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDoc&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.usn, usn) || other.usn == usn)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearOfStudy, yearOfStudy) || other.yearOfStudy == yearOfStudy)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.personalWebsite, personalWebsite) || other.personalWebsite == personalWebsite)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._skills, _skills)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.linkedinUrl, linkedinUrl) || other.linkedinUrl == linkedinUrl)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordHandle, discordHandle) || other.discordHandle == discordHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.mustResetPassword, mustResetPassword) || other.mustResetPassword == mustResetPassword)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.designation, designation) || other.designation == designation)&&(identical(other.club, club) || other.club == club)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.privacySettings, privacySettings) || other.privacySettings == privacySettings)&&(identical(other.notificationSettings, notificationSettings) || other.notificationSettings == notificationSettings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,usn,fullName,role,profileComplete,phone,yearOfStudy,batch,instagramHandle,personalWebsite,profilePictureUrl,bio,const DeepCollectionEquality().hash(_skills),githubUrl,linkedinUrl,twitterHandle,discordHandle,status,mustResetPassword,facultyId,designation,club,fcmToken,privacySettings,notificationSettings,createdAt]);

@override
String toString() {
  return 'UserDoc(uid: $uid, email: $email, usn: $usn, fullName: $fullName, role: $role, profileComplete: $profileComplete, phone: $phone, yearOfStudy: $yearOfStudy, batch: $batch, instagramHandle: $instagramHandle, personalWebsite: $personalWebsite, profilePictureUrl: $profilePictureUrl, bio: $bio, skills: $skills, githubUrl: $githubUrl, linkedinUrl: $linkedinUrl, twitterHandle: $twitterHandle, discordHandle: $discordHandle, status: $status, mustResetPassword: $mustResetPassword, facultyId: $facultyId, designation: $designation, club: $club, fcmToken: $fcmToken, privacySettings: $privacySettings, notificationSettings: $notificationSettings, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserDocCopyWith<$Res> implements $UserDocCopyWith<$Res> {
  factory _$UserDocCopyWith(_UserDoc value, $Res Function(_UserDoc) _then) = __$UserDocCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String usn, String fullName,@JsonKey(unknownEnumValue: UserRole.student) UserRole role, bool profileComplete, String? phone, String? yearOfStudy, String? batch, String? instagramHandle, String? personalWebsite, String? profilePictureUrl, String? bio, List<String> skills, String? githubUrl, String? linkedinUrl, String? twitterHandle, String? discordHandle, String? status, bool mustResetPassword, String? facultyId, String? designation, String? club, String? fcmToken, PrivacySettings privacySettings, NotificationSettings notificationSettings,@DateTimeConverter() DateTime? createdAt
});


@override $PrivacySettingsCopyWith<$Res> get privacySettings;@override $NotificationSettingsCopyWith<$Res> get notificationSettings;

}
/// @nodoc
class __$UserDocCopyWithImpl<$Res>
    implements _$UserDocCopyWith<$Res> {
  __$UserDocCopyWithImpl(this._self, this._then);

  final _UserDoc _self;
  final $Res Function(_UserDoc) _then;

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? usn = null,Object? fullName = null,Object? role = null,Object? profileComplete = null,Object? phone = freezed,Object? yearOfStudy = freezed,Object? batch = freezed,Object? instagramHandle = freezed,Object? personalWebsite = freezed,Object? profilePictureUrl = freezed,Object? bio = freezed,Object? skills = null,Object? githubUrl = freezed,Object? linkedinUrl = freezed,Object? twitterHandle = freezed,Object? discordHandle = freezed,Object? status = freezed,Object? mustResetPassword = null,Object? facultyId = freezed,Object? designation = freezed,Object? club = freezed,Object? fcmToken = freezed,Object? privacySettings = null,Object? notificationSettings = null,Object? createdAt = freezed,}) {
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
as String?,mustResetPassword: null == mustResetPassword ? _self.mustResetPassword : mustResetPassword // ignore: cast_nullable_to_non_nullable
as bool,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,designation: freezed == designation ? _self.designation : designation // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,privacySettings: null == privacySettings ? _self.privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as PrivacySettings,notificationSettings: null == notificationSettings ? _self.notificationSettings : notificationSettings // ignore: cast_nullable_to_non_nullable
as NotificationSettings,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivacySettingsCopyWith<$Res> get privacySettings {
  
  return $PrivacySettingsCopyWith<$Res>(_self.privacySettings, (value) {
    return _then(_self.copyWith(privacySettings: value));
  });
}/// Create a copy of UserDoc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notificationSettings {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notificationSettings, (value) {
    return _then(_self.copyWith(notificationSettings: value));
  });
}
}

// dart format on
