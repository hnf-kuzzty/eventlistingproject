import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  // Safe notify listeners method
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasListeners) return;
      notifyListeners();
    });
  }

  Future<void> checkAuthStatus() async {
    if (_isInitialized) return; // Prevent multiple calls

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final token = await AuthService.getToken();
      final userData = await AuthService.getUserData();

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // Clear any corrupted data
      await AuthService.clearAuth();
    }

    _isLoading = false;
    _isInitialized = true;
    _safeNotifyListeners();
  }

  Future<String?> login(String studentNumber, String password) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final response = await ApiService.login(
        studentNumber: studentNumber,
        password: password,
      );

      if (response.success && response.data != null) {
        _token = response.data!['token'];
        _user = User.fromJson(response.data!['user']);
        _isAuthenticated = true;

        await AuthService.saveToken(_token!);
        await AuthService.saveUserData(jsonEncode(response.data!['user']));

        _isLoading = false;
        _safeNotifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        _safeNotifyListeners();
        return response.message;
      }
    } catch (e) {
      _isLoading = false;
      _safeNotifyListeners();
      return 'Login failed: $e';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        studentNumber: studentNumber,
        major: major,
        classYear: classYear,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        _token = response.data!['token'];
        _user = User.fromJson(response.data!['user']);
        _isAuthenticated = true;

        await AuthService.saveToken(_token!);
        await AuthService.saveUserData(jsonEncode(response.data!['user']));

        _isLoading = false;
        _safeNotifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        _safeNotifyListeners();
        return response.message;
      }
    } catch (e) {
      _isLoading = false;
      _safeNotifyListeners();
      return 'Registration failed: $e';
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    _isInitialized = false;

    try {
      await AuthService.clearAuth();
    } catch (e) {
      print('Error during logout: $e');
    }

    _safeNotifyListeners();
  }
}