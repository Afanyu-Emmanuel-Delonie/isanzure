import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isanzure_mobile/core/network/api_client.dart';

class AuthService{
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthService(this.apiClient, this.storage);

  //Login Method
  Future<void> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', {'email': email, 'password': password});
    final token = response.data['access_token'];
    await storage.write(key: 'auth_key', value: token);
  }

  //Signup Method
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String role,
}) async {
    await apiClient.post('/v1/signup',{
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'role': role,
    });
  }

  //Logout Method
  Future<void> logout() async {
    await storage.delete(key: 'auth_key');
  }
}