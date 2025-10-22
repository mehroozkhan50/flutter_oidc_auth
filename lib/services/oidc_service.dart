import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/oidc_config.dart' as oidc_models;
import '../models/user_info.dart';
import '../models/auth_tokens.dart';
import 'token_manager.dart';
import 'config_service.dart';

class OidcService {
  static const String _configKey = 'oidc_config';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TokenManager _tokenManager = TokenManager();
  final ConfigService _configService = ConfigService();
  
  // Dynamic configuration
  String _clientId = '';
  String _clientSecret = '';
  String _redirectUri = '';
  String _issuer = '';
  List<String> _scopes = ['openid', 'profile', 'email'];
  
  oidc_models.OidcConfig? _config;
  AuthTokens? _tokens;
  UserInfo? _userInfo;

  // Getters
  oidc_models.OidcConfig? get config => _config;
  AuthTokens? get tokens => _tokens;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _tokens != null && !_tokens!.isExpired;

  /// Initialize the OIDC service by loading configuration and tokens
  Future<void> initialize() async {
    await _loadUserConfig();
    await _loadConfig();
    await _loadTokens();
    if (_tokens != null && !_tokens!.isExpired) {
      await _loadUserInfo();
    }
  }
  
  /// Load user configuration from storage
  Future<void> _loadUserConfig() async {
    final config = await _configService.getConfig();
    _clientId = config['clientId'] ?? '';
    _clientSecret = config['clientSecret'] ?? '';
    _redirectUri = config['redirectUri'] ?? '';
    _issuer = config['issuer'] ?? '';
    
    // Set scopes based on provider
    final provider = config['provider'] ?? 'google';
    switch (provider) {
      case 'google':
        _scopes = ['openid', 'profile', 'email'];
        break;
      case 'auth0':
      case 'keycloak':
      case 'azure':
        _scopes = ['openid', 'profile', 'email', 'offline_access'];
        break;
      default:
        _scopes = ['openid', 'profile', 'email'];
    }
  }

  /// Load OIDC configuration from the issuer
  Future<void> _loadConfig() async {
    try {
      // Check if configuration is complete
      if (_clientId.isEmpty || _clientSecret.isEmpty || _issuer.isEmpty) {
        throw Exception('OIDC configuration not set up. Please configure your OIDC provider in the settings.');
      }
      
      final configUrl = Uri.parse('$_issuer/.well-known/openid_configuration');
      final response = await http.get(configUrl);
      
      if (response.statusCode == 200) {
        _config = oidc_models.OidcConfig.fromJson(json.decode(response.body));
        await _secureStorage.write(key: _configKey, value: response.body);
      } else {
        throw Exception('Failed to load OIDC configuration: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if network fails
      final cachedConfig = await _secureStorage.read(key: _configKey);
      if (cachedConfig != null) {
        _config = oidc_models.OidcConfig.fromJson(json.decode(cachedConfig));
      } else {
        rethrow;
      }
    }
  }

  /// Load stored tokens from secure storage
  Future<void> _loadTokens() async {
    _tokens = await _tokenManager.loadTokens();
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
    await _tokenManager.storeTokens(tokens);
  }

  /// Load user information using the access token
  Future<void> _loadUserInfo() async {
    if (_tokens == null || _config == null) return;

    try {
      final response = await http.get(
        Uri.parse(_config!.userInfoEndpoint),
        headers: {
          'Authorization': '${_tokens!.tokenType} ${_tokens!.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        _userInfo = UserInfo.fromJson(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('Failed to load user info: $e');
    }
  }

  /// Generate a secure random state parameter
  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Generate a secure random code verifier for PKCE
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Generate code challenge from code verifier
  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Start the OIDC authentication flow
  Future<bool> authenticate() async {
    if (_config == null) {
      await _loadConfig();
    }

    if (_config == null) {
      throw Exception('OIDC configuration not available');
    }

    final state = _generateState();
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    // Store state and code verifier for verification
    await _secureStorage.write(key: 'oidc_state', value: state);
    await _secureStorage.write(key: 'oidc_code_verifier', value: codeVerifier);

    final authUrl = Uri.parse(_config!.authorizationEndpoint).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': _clientId,
        'redirect_uri': _redirectUri,
        'scope': _scopes.join(' '),
        'state': state,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );

    try {
      final launched = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      return launched;
    } catch (e) {
      debugPrint('Failed to launch authentication URL: $e');
      return false;
    }
  }

  /// Handle the OAuth callback with authorization code
  Future<bool> handleCallback(String code, String state) async {
    if (_config == null) {
      throw Exception('OIDC configuration not available');
    }

    // Verify state parameter
    final storedState = await _secureStorage.read(key: 'oidc_state');
    if (storedState != state) {
      throw Exception('Invalid state parameter');
    }

    final codeVerifier = await _secureStorage.read(key: 'oidc_code_verifier');
    if (codeVerifier == null) {
      throw Exception('Code verifier not found');
    }

    try {
      // Exchange authorization code for tokens using HTTP
      final tokenResponse = await http.post(
        Uri.parse(_config!.tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': code,
          'redirect_uri': _redirectUri,
          'code_verifier': codeVerifier,
        },
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = json.decode(tokenResponse.body);
        
        // Create AuthTokens object
        final tokens = AuthTokens(
          accessToken: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          idToken: tokenData['id_token'],
          tokenType: tokenData['token_type'] ?? 'Bearer',
          expiresIn: tokenData['expires_in'] ?? 3600,
          issuedAt: DateTime.now(),
        );

        await _saveTokens(tokens);
        await _loadUserInfo();

        // Clean up temporary values
        await _secureStorage.delete(key: 'oidc_state');
        await _secureStorage.delete(key: 'oidc_code_verifier');

        return true;
      } else {
        throw Exception('Token exchange failed: ${tokenResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to exchange authorization code: $e');
      return false;
    }
  }

  /// Refresh the access token using the refresh token
  Future<bool> refreshToken() async {
    if (_tokens?.refreshToken == null || _config == null) {
      return false;
    }

    try {
      final refreshResponse = await http.post(
        Uri.parse(_config!.tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': _tokens!.refreshToken!,
        },
      );

      if (refreshResponse.statusCode == 200) {
        final tokenData = json.decode(refreshResponse.body);
        
        final newTokens = AuthTokens(
          accessToken: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'] ?? _tokens!.refreshToken,
          idToken: tokenData['id_token'] ?? _tokens!.idToken,
          tokenType: tokenData['token_type'] ?? 'Bearer',
          expiresIn: tokenData['expires_in'] ?? 3600,
          issuedAt: DateTime.now(),
        );

        await _saveTokens(newTokens);
        return true;
      } else {
        throw Exception('Token refresh failed: ${refreshResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to refresh token: $e');
      return false;
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    _tokens = null;
    _userInfo = null;
    await _tokenManager.clearTokens();
    await _secureStorage.delete(key: _configKey);
  }

  /// Get a valid access token, refreshing if necessary
  Future<String?> getValidAccessToken() async {
    if (_tokens == null) return null;

    if (_tokens!.isExpired) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        await logout();
        return null;
      }
    }

    return _tokens!.accessToken;
  }
}
