import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/team_member_model.dart';

final teamProvider = FutureProvider<List<TeamMember>>((ref) async {
  final client = ApiClient();
  final response = await client.dio.get('/clinic-team');
  
  if (response.data['status'] == 'success') {
    final List data = response.data['data'];
    return data.map((json) => TeamMember.fromJson(json)).toList();
  }
  
  return [];
});
