class OidcConfig {
  // OIDC Provider Configuration
  // Replace these values with your actual OIDC provider details
  
  // Example configurations for popular providers:
  
  // Google OAuth2/OIDC
  static const String googleIssuer = 'https://accounts.google.com';
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  static const String googleClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  static const String googleRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Auth0
  static const String auth0Issuer = 'https://your-domain.auth0.com';
  static const String auth0ClientId = 'your_auth0_client_id';
  static const String auth0ClientSecret = 'your_auth0_client_secret';
  static const String auth0RedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Keycloak
  static const String keycloakIssuer = 'https://your-keycloak-server.com/realms/your-realm';
  static const String keycloakClientId = 'your_keycloak_client_id';
  static const String keycloakClientSecret = 'your_keycloak_client_secret';
  static const String keycloakRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Azure AD
  static const String azureIssuer = 'https://login.microsoftonline.com/your-tenant-id/v2.0';
  static const String azureClientId = 'your_azure_client_id';
  static const String azureClientSecret = 'your_azure_client_secret';
  static const String azureRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Default configuration (replace with your provider)
  static const String defaultIssuer = 'https://your-oidc-provider.com';
  static const String defaultClientId = 'your_client_id';
  static const String defaultClientSecret = 'your_client_secret';
  static const String defaultRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
  
  // Scopes to request
  static const List<String> defaultScopes = [
    'openid',
    'profile',
    'email',
    'offline_access', // For refresh tokens
  ];
  
  // Additional scopes for specific providers
  static const List<String> googleScopes = [
    'openid',
    'profile',
    'email',
  ];
  
  static const List<String> auth0Scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
  
  static const List<String> keycloakScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
  
  static const List<String> azureScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
  
  // Provider selection
  static const OidcProvider selectedProvider = OidcProvider.google;
  
  // Get configuration based on selected provider
  static Map<String, String> get config {
    switch (selectedProvider) {
      case OidcProvider.google:
        return {
          'issuer': googleIssuer,
          'clientId': googleClientId,
          'clientSecret': googleClientSecret,
          'redirectUri': googleRedirectUri,
        };
      case OidcProvider.auth0:
        return {
          'issuer': auth0Issuer,
          'clientId': auth0ClientId,
          'clientSecret': auth0ClientSecret,
          'redirectUri': auth0RedirectUri,
        };
      case OidcProvider.keycloak:
        return {
          'issuer': keycloakIssuer,
          'clientId': keycloakClientId,
          'clientSecret': keycloakClientSecret,
          'redirectUri': keycloakRedirectUri,
        };
      case OidcProvider.azure:
        return {
          'issuer': azureIssuer,
          'clientId': azureClientId,
          'clientSecret': azureClientSecret,
          'redirectUri': azureRedirectUri,
        };
      case OidcProvider.custom:
        return {
          'issuer': defaultIssuer,
          'clientId': defaultClientId,
          'clientSecret': defaultClientSecret,
          'redirectUri': defaultRedirectUri,
        };
    }
  }
  
  // Get scopes based on selected provider
  static List<String> get scopes {
    switch (selectedProvider) {
      case OidcProvider.google:
        return googleScopes;
      case OidcProvider.auth0:
        return auth0Scopes;
      case OidcProvider.keycloak:
        return keycloakScopes;
      case OidcProvider.azure:
        return azureScopes;
      case OidcProvider.custom:
        return defaultScopes;
    }
  }
}

enum OidcProvider {
  google,
  auth0,
  keycloak,
  azure,
  custom,
}
