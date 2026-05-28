import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get error => _error;

  Future<void> checkSession() async {
    _isSignedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login({required String username, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.login(
        username: username,
        password: password,
      );
      _isSignedIn = success;
      return success;
    } catch (e) {
      _error = 'Could not reach the backend server';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      return await _authService.register(
        username: username,
        email: email,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
    } catch (e) {
      _error = 'Could not reach the backend server';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isSignedIn = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    _isSignedIn = await _authService.isLoggedIn();
    notifyListeners();
    return _isSignedIn;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
