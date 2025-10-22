# Flutter OpenID Connect Authentication Demo

A comprehensive Flutter application demonstrating OpenID Connect (OIDC) authentication with support for multiple identity providers.

## Features

- 🔐 **OpenID Connect Authentication** - Full OIDC implementation with PKCE
- 🔄 **Automatic Token Refresh** - Seamless token renewal
- 🛡️ **Secure Token Storage** - Encrypted local storage
- 👤 **User Profile Information** - Display user details from ID token
- 🎨 **Modern UI** - Beautiful Material Design interface
- ⚙️ **Multiple Providers** - Support for Google, Auth0, Keycloak, Azure AD, and custom providers
- 🔧 **Configuration Screen** - Easy setup for different providers

## Supported OIDC Providers

- **Google OAuth2/OIDC**
- **Auth0**
- **Keycloak**
- **Azure Active Directory**
- **Custom OIDC Providers**

## Project Structure

```
lib/
├── config/
│   └── oidc_config.dart          # OIDC provider configuration
├── models/
│   ├── auth_tokens.dart          # Token model with JSON serialization
│   ├── oidc_config.dart          # OIDC configuration model
│   └── user_info.dart            # User information model
├── providers/
│   └── auth_provider.dart        # Authentication state management
├── screens/
│   ├── config_screen.dart        # Provider configuration UI
│   ├── home_screen.dart          # Main authenticated screen
│   └── login_screen.dart         # Login screen
├── services/
│   ├── oidc_service.dart         # Core OIDC authentication service
│   └── token_manager.dart        # Secure token management
└── main.dart                     # App entry point
```

## Setup Instructions

### 1. Configure Your OIDC Provider

Edit `lib/config/oidc_config.dart` and update the configuration for your chosen provider:

```dart
// Example for Google OAuth2
static const String googleClientId = 'your_google_client_id.apps.googleusercontent.com';
static const String googleClientSecret = 'your_google_client_secret';
static const String googleRedirectUri = 'com.example.flutteroidcauth://oauth/callback';
```

### 2. Register Your Application

#### Google OAuth2
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your redirect URI: `com.example.flutteroidcauth://oauth/callback`

#### Auth0
1. Create an account at [Auth0](https://auth0.com/)
2. Create a new application
3. Configure allowed callback URLs
4. Note your domain, client ID, and client secret

#### Keycloak
1. Install and run Keycloak server
2. Create a new realm
3. Create a new client
4. Configure valid redirect URIs

#### Azure AD
1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to Azure Active Directory
3. Register a new application
4. Configure redirect URIs

### 3. Update Configuration

In `lib/config/oidc_config.dart`, set your provider:

```dart
static const OidcProvider selectedProvider = OidcProvider.google; // or your provider
```

### 4. Configure Redirect URI

The redirect URI must be registered with your OIDC provider and match the scheme in your app:

```
com.example.flutteroidcauth://oauth/callback
```

### 5. Run the Application

```bash
flutter pub get
flutter run
```

## Key Components

### OidcService
The core authentication service that handles:
- OIDC configuration discovery
- Authorization code flow with PKCE
- Token exchange and refresh
- User info retrieval
- Secure token storage

### TokenManager
Manages secure token storage and retrieval:
- Encrypted token storage
- Token expiry checking
- Automatic refresh logic
- Token validation

### AuthProvider
State management for authentication:
- Login/logout state
- User information
- Error handling
- Loading states

## Security Features

- **PKCE (Proof Key for Code Exchange)** - Enhanced security for public clients
- **Secure Token Storage** - Uses Flutter Secure Storage for encryption
- **State Parameter Validation** - Prevents CSRF attacks
- **Automatic Token Refresh** - Maintains session without user intervention
- **Token Expiry Management** - Proactive token renewal

## Usage Example

```dart
// Initialize authentication
final authProvider = Provider.of<AuthProvider>(context);
await authProvider.initialize();

// Check authentication status
if (authProvider.isAuthenticated) {
  // User is logged in
  final userInfo = authProvider.userInfo;
  final accessToken = await authProvider.getValidAccessToken();
}

// Login
await authProvider.login();

// Logout
await authProvider.logout();
```

## Dependencies

- `oauth2` - OAuth 2.0 client library
- `http` - HTTP client for API calls
- `url_launcher` - Launch external URLs for authentication
- `flutter_secure_storage` - Secure token storage
- `provider` - State management
- `json_annotation` - JSON serialization

## Configuration Options

The app supports configuration for multiple OIDC providers:

- **Google**: `https://accounts.google.com`
- **Auth0**: `https://your-domain.auth0.com`
- **Keycloak**: `https://your-keycloak.com/realms/your-realm`
- **Azure AD**: `https://login.microsoftonline.com/your-tenant/v2.0`
- **Custom**: Any OIDC-compliant provider

## Troubleshooting

### Common Issues

1. **Redirect URI Mismatch**
   - Ensure the redirect URI in your OIDC provider matches exactly
   - Check the scheme and path are correct

2. **Client ID/Secret Issues**
   - Verify credentials are correct
   - Check if the client is properly configured

3. **Network Issues**
   - Ensure the OIDC provider is accessible
   - Check firewall and proxy settings

4. **Token Expiry**
   - The app automatically refreshes tokens
   - Check if refresh token is valid

### Debug Information

Enable debug logging to see detailed authentication flow:

```dart
// In your main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    debugPrint('Debug mode enabled');
  }
  runApp(MyApp());
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the OIDC provider documentation
3. Open an issue on GitHub

## Security Notice

This is a demonstration application. For production use:
- Store credentials securely (not in code)
- Use proper certificate pinning
- Implement additional security measures
- Follow OIDC security best practices