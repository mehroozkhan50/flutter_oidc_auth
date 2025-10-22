// Demo configuration for testing OIDC flow
// This is a mock configuration for demonstration purposes

class DemoConfig {
  // Demo OIDC Provider Configuration
  static const String demoIssuer = 'https://demo.oidc-provider.com';
  static const String demoClientId = 'demo_client_id';
  static const String demoClientSecret = 'demo_client_secret';
  static const String demoRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Demo scopes
  static const List<String> demoScopes = [
    'openid',
    'profile',
    'email',
  ];
  
  // Demo configuration
  static Map<String, String> get config => {
    'issuer': demoIssuer,
    'clientId': demoClientId,
    'clientSecret': demoClientSecret,
    'redirectUri': demoRedirectUri,
  };
  
  static List<String> get scopes => demoScopes;
}
