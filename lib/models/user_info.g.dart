// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  sub: json['sub'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  picture: json['picture'] as String?,
  givenName: json['givenName'] as String?,
  familyName: json['familyName'] as String?,
  preferredUsername: json['preferredUsername'] as String?,
  locale: json['locale'] as String?,
  emailVerified: json['emailVerified'] as bool?,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'sub': instance.sub,
  'name': instance.name,
  'email': instance.email,
  'picture': instance.picture,
  'givenName': instance.givenName,
  'familyName': instance.familyName,
  'preferredUsername': instance.preferredUsername,
  'locale': instance.locale,
  'emailVerified': instance.emailVerified,
};
