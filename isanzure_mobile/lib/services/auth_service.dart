import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isanzure_mobile/core/network/api_client.dart';
import 'package:isanzure_mobile/models/user_model.dart';

class AuthService {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthService(this.apiClient, this.storage);

  Future<bool> hasToken() async {
    final token = await storage.read(key: 'auth_key');
    return token != null && token.isNotEmpty;
  }

  // Step 1 of signup — sends OTP to email
  Future<void> initiateSignup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    await apiClient.post('/auth/signup', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    });
  }

  // Step 2 of signup — verifies OTP and creates account, returns token
  Future<String> verifyOtp({
    required String email,
    required String otp,
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await apiClient.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
      'name': name,
      'phone': phone,
      'password': password,
      'role': role,
    });
    return response.data['token'] as String;
  }

  Future<void> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = response.data['token'] as String;
    await storage.write(key: 'auth_key', value: token);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get('/auth/profile');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await apiClient.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    await apiClient.post('/auth/reset-password', {
      'reset_token': resetToken,
      'new_password': newPassword,
    });
  }

  Future<UserModel> updateProfile(String name, String phone) async {
    final response = await apiClient.put('/auth/profile', {
      'name': name,
      'phone': phone,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await storage.delete(key: 'auth_key');
  }
}