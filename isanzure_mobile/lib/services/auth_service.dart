import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<Map<String, String>> login(String email, String password) async {
    final data = await _api.post('/login', {'email': email, 'password': password}, auth: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, data['token']);
    await prefs.setString(AppConstants.roleKey, data['role']);
    return {'token': data['token'], 'role': data['role']};
  }

  Future<Map<String, String>> signup(String name, String email, String phone, String password, {String role = 'passenger'}) async {
    final data = await _api.post('/signup', {
      'name': name, 'email': email, 'phone': phone, 'password': password, 'role': role,
    }, auth: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, data['token']);
    await prefs.setString(AppConstants.roleKey, data['role']);
    return {'token': data['token'], 'role': data['role']};
  }

  Future<UserModel> getProfile() async {
    final data = await _api.get('/profile');
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile(String name, String phone) async {
    final data = await _api.post('/profile', {'name': name, 'phone': phone});
    return UserModel.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/forgot-password', {'email': email}, auth: false);
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _api.post('/reset-password', {'reset_token': token, 'new_password': newPassword}, auth: false);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.roleKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey) != null;
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.roleKey);
  }
}
