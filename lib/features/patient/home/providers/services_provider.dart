import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/service_model.dart';

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final client = ApiClient();
  final response = await client.dio.get('/services');
  
  if (response.data['status'] == 'success') {
    final List data = response.data['data'];
    return data.map((json) => Service.fromJson(json)).toList();
  }
  
  return [];
});

final serviceDetailProvider = FutureProvider.family<Service?, int>((ref, id) async {
  final client = ApiClient();
  final response = await client.dio.get('/services/$id');
  
  if (response.data['status'] == 'success') {
    return Service.fromJson(response.data['data']);
  }
  
  return null;
});
