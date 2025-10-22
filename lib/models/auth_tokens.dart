import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
  });

  bool get isExpired {
    final expirationTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expirationTime);
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}
