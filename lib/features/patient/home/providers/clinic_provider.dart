import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/clinic_branch_model.dart';

final clinicBranchesProvider = FutureProvider<List<ClinicBranch>>((ref) async {
  final client = ApiClient();
  final response = await client.dio.get('/clinic-branches');
  
  if (response.data['status'] == 'success') {
    final List data = response.data['data'];
    return data.map((json) => ClinicBranch.fromJson(json)).toList();
  }
  
  return [];
});
