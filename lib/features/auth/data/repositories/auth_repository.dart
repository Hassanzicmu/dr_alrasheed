import 'package:dio/dio.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final response = await _apiClient.dio.post('/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      });
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? currentPassword,
    String? photoPath,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (password != null) {
        data['password'] = password;
        data['current_password'] = currentPassword;
      }
      
      if (photoPath != null) {
        data['photo'] = await MultipartFile.fromFile(photoPath, filename: 'profile.jpg');
      }

      FormData formData = FormData.fromMap(data);
      
      final response = await _apiClient.dio.post('/profile', data: formData);
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiClient.dio.delete('/profile');
    } catch (e) {
      rethrow;
    }
  }
}
