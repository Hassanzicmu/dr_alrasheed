import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import 'package:dr_abdulaziz_al_rasheed/core/models/app_settings_model.dart';

final settingsProvider = FutureProvider<AppSettings?>((ref) async {
  try {
    final client = ApiClient();
    final response = await client.dio.get('/settings');
    
    if (response.data['status'] == true) {
      return AppSettings.fromJson(response.data['data']);
    }
  } catch (e) {
    print('Failed to load settings: $e');
  }
  return null;
});
