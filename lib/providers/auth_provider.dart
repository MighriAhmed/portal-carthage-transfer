import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:portal_carthage_transfer/models/user.dart';
import 'package:portal_carthage_transfer/utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      _token = await _storage.read(key: AppConstants.tokenKey);
      final userData = await _storage.read(key: AppConstants.userKey);
      
      if (_token != null && userData != null) {
        // Verify token is still valid
        if (!JwtDecoder.isExpired(_token!)) {
          _user = User.fromJson(jsonDecode(userData));
        } else {
          // Token expired, clear storage
          await _clearAuth();
        }
      }
    } catch (e) {
      await _clearAuth();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Convert to form data format
      final body = 'username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';

      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        
        // Decode JWT to get user info
        final decodedToken = JwtDecoder.decode(_token!);
        _user = User.fromJson(decodedToken);

        // Store auth data
        await _storage.write(key: AppConstants.tokenKey, value: _token);
        await _storage.write(key: AppConstants.userKey, value: jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        
        // Handle different error response formats
        if (errorData['detail'] is List) {
          // Handle validation errors (422 status)
          final validationErrors = errorData['detail'] as List;
          final errorMessages = validationErrors
              .map((error) => error['msg'] ?? 'Validation error')
              .join(', ');
          _error = errorMessages;
        } else if (errorData['detail'] is String) {
          _error = errorData['detail'];
        } else {
          _error = 'Login failed';
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuth();
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get authorization header for API requests
  Map<String, String> get authHeaders {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }
} 