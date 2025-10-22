import 'package:json_annotation/json_annotation.dart';

part 'oidc_config.g.dart';

@JsonSerializable()
class OidcConfig {
  final String issuer;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String userInfoEndpoint;
  final String jwksUri;
  final List<String> responseTypesSupported;
  final List<String> subjectTypesSupported;
  final List<String> idTokenSigningAlgValuesSupported;
  final List<String> scopesSupported;
  final List<String> claimsSupported;
  final List<String> grantTypesSupported;
  final List<String> tokenEndpointAuthMethodsSupported;

  const OidcConfig({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.userInfoEndpoint,
    required this.jwksUri,
    required this.responseTypesSupported,
    required this.subjectTypesSupported,
    required this.idTokenSigningAlgValuesSupported,
    required this.scopesSupported,
    required this.claimsSupported,
    required this.grantTypesSupported,
    required this.tokenEndpointAuthMethodsSupported,
  });

  factory OidcConfig.fromJson(Map<String, dynamic> json) => _$OidcConfigFromJson(json);
  Map<String, dynamic> toJson() => _$OidcConfigToJson(this);
}
