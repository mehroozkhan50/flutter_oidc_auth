import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  final String sub;
  final String? name;
  final String? email;
  final String? picture;
  final String? givenName;
  final String? familyName;
  final String? preferredUsername;
  final String? locale;
  final bool? emailVerified;

  const UserInfo({
    required this.sub,
    this.name,
    this.email,
    this.picture,
    this.givenName,
    this.familyName,
    this.preferredUsername,
    this.locale,
    this.emailVerified,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
