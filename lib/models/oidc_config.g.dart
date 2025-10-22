// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OidcConfig _$OidcConfigFromJson(Map<String, dynamic> json) => OidcConfig(
  issuer: json['issuer'] as String,
  authorizationEndpoint: json['authorizationEndpoint'] as String,
  tokenEndpoint: json['tokenEndpoint'] as String,
  userInfoEndpoint: json['userInfoEndpoint'] as String,
  jwksUri: json['jwksUri'] as String,
  responseTypesSupported: (json['responseTypesSupported'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  subjectTypesSupported: (json['subjectTypesSupported'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  idTokenSigningAlgValuesSupported:
      (json['idTokenSigningAlgValuesSupported'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  scopesSupported: (json['scopesSupported'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  claimsSupported: (json['claimsSupported'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  grantTypesSupported: (json['grantTypesSupported'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tokenEndpointAuthMethodsSupported:
      (json['tokenEndpointAuthMethodsSupported'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$OidcConfigToJson(
  OidcConfig instance,
) => <String, dynamic>{
  'issuer': instance.issuer,
  'authorizationEndpoint': instance.authorizationEndpoint,
  'tokenEndpoint': instance.tokenEndpoint,
  'userInfoEndpoint': instance.userInfoEndpoint,
  'jwksUri': instance.jwksUri,
  'responseTypesSupported': instance.responseTypesSupported,
  'subjectTypesSupported': instance.subjectTypesSupported,
  'idTokenSigningAlgValuesSupported': instance.idTokenSigningAlgValuesSupported,
  'scopesSupported': instance.scopesSupported,
  'claimsSupported': instance.claimsSupported,
  'grantTypesSupported': instance.grantTypesSupported,
  'tokenEndpointAuthMethodsSupported':
      instance.tokenEndpointAuthMethodsSupported,
};
