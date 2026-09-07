class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? photo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      photo: json['photo'],
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle the {"status": "success", "data": {...}} wrapper
    final payload = json['data'] ?? json;
    
    // Extract patient/user data
    final userData = payload['patient'] ?? payload['user'] ?? payload;
    
    return AuthResponse(
      user: UserModel.fromJson(userData is Map<String, dynamic> ? userData : {}),
      token: payload['token'] ?? payload['access_token'] ?? '',
    );
  }
}
