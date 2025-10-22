import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_tokens.dart';

class TokenManager {
  static const String _storageKey = 'oidc_tokens';
  static const String _refreshKey = 'oidc_refresh_token';
  static const String _expiryKey = 'oidc_token_expiry';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Store tokens securely
  Future<void> storeTokens(AuthTokens tokens) async {
    try {
      // Store the full token object
      await _secureStorage.write(
        key: _storageKey,
        value: json.encode(tokens.toJson()),
      );
      
      // Store individual components for quick access
      if (tokens.refreshToken != null) {
        await _secureStorage.write(
          key: _refreshKey,
          value: tokens.refreshToken!,
        );
      }
      
      await _secureStorage.write(
        key: _expiryKey,
        value: tokens.issuedAt.add(Duration(seconds: tokens.expiresIn)).toIso8601String(),
      );
      
      debugPrint('Tokens stored successfully');
    } catch (e) {
      debugPrint('Failed to store tokens: $e');
      rethrow;
    }
  }
  
  /// Load tokens from secure storage
  Future<AuthTokens?> loadTokens() async {
    try {
      final tokensJson = await _secureStorage.read(key: _storageKey);
      if (tokensJson != null) {
        final tokens = AuthTokens.fromJson(json.decode(tokensJson));
        
        // Check if tokens are expired
        if (tokens.isExpired) {
          debugPrint('Stored tokens are expired');
          return null;
        }
        
        debugPrint('Tokens loaded successfully');
        return tokens;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to load tokens: $e');
      return null;
    }
  }
  
  /// Get access token if valid
  Future<String?> getAccessToken() async {
    final tokens = await loadTokens();
    return tokens?.accessToken;
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshKey);
  }
  
  /// Check if tokens are expired
  Future<bool> areTokensExpired() async {
    try {
      final expiryString = await _secureStorage.read(key: _expiryKey);
      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        return DateTime.now().isAfter(expiry);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to check token expiry: $e');
      return true;
    }
  }
  
  /// Check if tokens exist and are valid
  Future<bool> hasValidTokens() async {
    final tokens = await loadTokens();
    return tokens != null && !tokens.isExpired;
  }
  
  /// Update access token (after refresh)
  Future<void> updateAccessToken(String newAccessToken, {int? newExpiresIn}) async {
    try {
      final tokens = await loadTokens();
      if (tokens != null) {
        final updatedTokens = AuthTokens(
          accessToken: newAccessToken,
          refreshToken: tokens.refreshToken,
          idToken: tokens.idToken,
          tokenType: tokens.tokenType,
          expiresIn: newExpiresIn ?? tokens.expiresIn,
          issuedAt: DateTime.now(),
        );
        await storeTokens(updatedTokens);
        debugPrint('Access token updated successfully');
      }
    } catch (e) {
      debugPrint('Failed to update access token: $e');
      rethrow;
    }
  }
  
  /// Update tokens after refresh
  Future<void> updateTokens(AuthTokens newTokens) async {
    await storeTokens(newTokens);
    debugPrint('Tokens updated successfully');
  }
  
  /// Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _storageKey);
      await _secureStorage.delete(key: _refreshKey);
      await _secureStorage.delete(key: _expiryKey);
      debugPrint('Tokens cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear tokens: $e');
      rethrow;
    }
  }
  
  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _secureStorage.read(key: _expiryKey);
      if (expiryString != null) {
        return DateTime.parse(expiryString);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get token expiry: $e');
      return null;
    }
  }
  
  /// Get time until token expiry
  Future<Duration?> getTimeUntilExpiry() async {
    final expiry = await getTokenExpiry();
    if (expiry != null) {
      final now = DateTime.now();
      if (expiry.isAfter(now)) {
        return expiry.difference(now);
      }
    }
    return null;
  }
  
  /// Check if tokens need refresh (expire within 5 minutes)
  Future<bool> needsRefresh() async {
    final timeUntilExpiry = await getTimeUntilExpiry();
    if (timeUntilExpiry != null) {
      // Refresh if expires within 5 minutes
      return timeUntilExpiry.inMinutes < 5;
    }
    return true;
  }
  
  /// Get token information for debugging
  Future<Map<String, dynamic>> getTokenInfo() async {
    final tokens = await loadTokens();
    final expiry = await getTokenExpiry();
    final timeUntilExpiry = await getTimeUntilExpiry();
    
    return {
      'hasTokens': tokens != null,
      'isExpired': tokens?.isExpired ?? true,
      'expiry': expiry?.toIso8601String(),
      'timeUntilExpiry': timeUntilExpiry?.inMinutes,
      'needsRefresh': await needsRefresh(),
      'hasRefreshToken': tokens?.refreshToken != null,
      'tokenType': tokens?.tokenType,
    };
  }
}
