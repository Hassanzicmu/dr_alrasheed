import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/data/models/doctor_profile_model.dart';

final apiProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final doctorProfileProvider = FutureProvider<DoctorProfile>((ref) async {
  final api = ref.read(apiProvider);
  
  try {
    final response = await api.dio.get('/doctor-profile');
    
    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return DoctorProfile.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load doctor profile');
    }
  } catch (e) {
    throw Exception('Error fetching doctor profile: $e');
  }
});
