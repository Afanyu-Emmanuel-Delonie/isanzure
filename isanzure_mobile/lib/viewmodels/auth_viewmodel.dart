import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;

  Future<void> checkAuthStatus() async {
    final hasToken = await _authService.hasToken();
    if (!hasToken) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _currentUser = await _authService.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _authService.logout();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Step 1: send OTP
  Future<bool> initiateSignup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      await _authService.initiateSignup(
        name: name, email: email, phone: phone, password: password, role: role,
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Could not send verification code.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Step 2: verify OTP and create account
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      await _authService.verifyOtp(
        email: email, otp: otp, name: name,
        phone: phone, password: password, role: role,
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Invalid or expired code.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _currentUser = await _authService.getCurrentUser();
      _status = AuthStatus.authenticated;
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

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Could not send reset code.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String resetToken, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(resetToken, newPassword);
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Could not reset password.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.updateProfile(name, phone);
      _setLoading(false);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e, 'Could not update profile.'));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString() ?? fallback;
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