import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isGuest;

  AuthState({this.user, this.isLoading = false, this.error, this.isGuest = false});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error, bool? isGuest}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository) : super(AuthState()) {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userData));
        state = state.copyWith(user: user);
      } catch (e) {
        print('Error decoding stored user: $e');
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      await _storage.write(key: 'auth_token', value: response.token);
      await _saveUserToStorage(response.user);
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e, stack) {
      print('DEBUG LOGIN ERROR: $e');
      print('DEBUG STACKTRACE: $stack');
      String errorMessage = 'An unexpected error occurred';
      if (e is DioException) {
        print('DEBUG DIO ERROR: ${e.response?.data}');
        errorMessage = e.response?.data['message'] ?? e.message ?? e.toString();
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      print('DEBUG REGISTER SUCCESS: ${response.user.name}');
      await _storage.write(key: 'auth_token', value: response.token);
      await _saveUserToStorage(response.user);
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e, stack) {
      print('DEBUG REGISTER ERROR: $e');
      print('DEBUG STACKTRACE: $stack');
      String errorMessage = 'An unexpected error occurred';
      if (e is DioException) {
        print('DEBUG DIO ERROR: ${e.response?.data}');
        errorMessage = e.response?.data['message'] ?? e.message ?? e.toString();
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? currentPassword,
    String? photoPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        password: password,
        currentPassword: currentPassword,
        photoPath: photoPath,
      );
      
      await _saveUserToStorage(response.user);
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to update profile';
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? e.message ?? e.toString();
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    }
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    await _storage.write(key: 'user_data', value: jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'gender': user.gender,
      'date_of_birth': user.dateOfBirth,
      'photo': user.photo,
    }));
  }

  Future<void> loginAsGuest() async {
    state = state.copyWith(isGuest: true, user: null, error: null);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    state = AuthState();
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAccount();
      await logout();
    } catch (e) {
      String errorMessage = 'Failed to delete account';
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? e.message ?? e.toString();
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    }
  }
}
