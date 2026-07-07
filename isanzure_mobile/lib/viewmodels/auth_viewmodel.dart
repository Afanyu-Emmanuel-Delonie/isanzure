import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;

  AuthViewModel({AuthService? service}) : _service = service ?? AuthService();

  AuthState state = AuthState.idle;
  UserModel? user;
  String? error;
  String? role;

  Future<void> checkAuth() async {
    final loggedIn = await _service.isLoggedIn();
    role = await _service.getRole();
    state = loggedIn ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final result = await _service.login(email, password);
      role = result['role'];
      state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String phone, String password) async {
    _setLoading();
    try {
      final result = await _service.signup(name, email, phone, password);
      role = result['role'];
      state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> loadProfile() async {
    _setLoading();
    try {
      user = await _service.getProfile();
      state = AuthState.authenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    _setLoading();
    try {
      user = await _service.updateProfile(name, phone);
      state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    role = null;
    state = AuthState.unauthenticated;
    notifyListeners();
  }

  void _setLoading() {
    state = AuthState.loading;
    error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    error = msg;
    state = AuthState.error;
    notifyListeners();
  }
}
