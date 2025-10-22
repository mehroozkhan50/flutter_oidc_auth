import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _storageKey = 'oidc_config';
  static const String _clientIdKey = 'client_id';
  static const String _clientSecretKey = 'client_secret';
  static const String _issuerKey = 'issuer';
  static const String _redirectUriKey = 'redirect_uri';
  static const String _providerKey = 'provider';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Default values
  static const String _defaultIssuer = 'https://accounts.google.com';
  static const String _defaultRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Get stored configuration
  Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'issuer': prefs.getString(_issuerKey) ?? _defaultIssuer,
      'clientId': prefs.getString(_clientIdKey) ?? '',
      'clientSecret': prefs.getString(_clientSecretKey) ?? '',
      'redirectUri': prefs.getString(_redirectUriKey) ?? _defaultRedirectUri,
      'provider': prefs.getString(_providerKey) ?? 'google',
    };
  }
  
  // Save configuration
  Future<void> saveConfig({
    required String issuer,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    required String provider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_issuerKey, issuer);
    await prefs.setString(_clientIdKey, clientId);
    await prefs.setString(_clientSecretKey, clientSecret);
    await prefs.setString(_redirectUriKey, redirectUri);
    await prefs.setString(_providerKey, provider);
  }
  
  // Check if configuration is complete
  Future<bool> isConfigComplete() async {
    final config = await getConfig();
    return config['clientId']!.isNotEmpty && 
           config['clientSecret']!.isNotEmpty &&
           config['issuer']!.isNotEmpty;
  }
  
  // Clear configuration
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_issuerKey);
    await prefs.remove(_clientIdKey);
    await prefs.remove(_clientSecretKey);
    await prefs.remove(_redirectUriKey);
    await prefs.remove(_providerKey);
  }
  
  // Get provider-specific default values
  static Map<String, String> getProviderDefaults(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return {
          'issuer': 'https://accounts.google.com',
          'redirectUri': 'com.example.flutteroidcauth://oauth/callback',
          'scopes': 'openid profile email',
        };
      case 'auth0':
        return {
          'issuer': 'https://your-domain.auth0.com',
          'redirectUri': 'com.example.flutteroidcauth://oauth/callback',
          'scopes': 'openid profile email offline_access',
        };
      case 'keycloak':
        return {
          'issuer': 'https://your-keycloak-server.com/realms/your-realm',
          'redirectUri': 'com.example.flutteroidcauth://oauth/callback',
          'scopes': 'openid profile email offline_access',
        };
      case 'azure':
        return {
          'issuer': 'https://login.microsoftonline.com/your-tenant-id/v2.0',
          'redirectUri': 'com.example.flutteroidcauth://oauth/callback',
          'scopes': 'openid profile email offline_access',
        };
      default:
        return {
          'issuer': 'https://your-oidc-provider.com',
          'redirectUri': 'com.example.flutteroidcauth://oauth/callback',
          'scopes': 'openid profile email',
        };
    }
  }
}
