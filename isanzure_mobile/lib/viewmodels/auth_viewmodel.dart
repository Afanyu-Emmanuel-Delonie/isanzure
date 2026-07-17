import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Login failed. Please try again.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: password,
        role: role,
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Registration failed. Please check your details.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Pulls the message field from the server JSON response if available
  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          fallback;
    }
    return fallback;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
