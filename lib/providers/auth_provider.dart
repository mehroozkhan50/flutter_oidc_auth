import 'package:flutter/foundation.dart';
import '../models/user_info.dart';
import '../models/auth_tokens.dart';
import '../services/oidc_service.dart';

class AuthProvider with ChangeNotifier {
  final OidcService _oidcService = OidcService();
  
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _oidcService.isAuthenticated;
  UserInfo? get userInfo => _oidcService.userInfo;
  AuthTokens? get tokens => _oidcService.tokens;

  /// Initialize the authentication provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _oidcService.initialize();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Start the authentication process
  Future<bool> login() async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _oidcService.authenticate();
      if (!success) {
        _setError('Failed to start authentication process');
      }
      return success;
    } catch (e) {
      _setError('Authentication failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handle the OAuth callback
  Future<bool> handleCallback(String code, String state) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _oidcService.handleCallback(code, state);
      if (success) {
        notifyListeners();
      } else {
        _setError('Failed to complete authentication');
      }
      return success;
    } catch (e) {
      _setError('Callback handling failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _oidcService.logout();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a valid access token
  Future<String?> getValidAccessToken() async {
    try {
      return await _oidcService.getValidAccessToken();
    } catch (e) {
      _setError('Failed to get access token: $e');
      return null;
    }
  }

  /// Clear any error messages
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set an error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
