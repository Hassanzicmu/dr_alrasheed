import 'package:dio/dio.dart';
import 'package:dr_abdulaziz_al_rasheed/core/api_client.dart';
import '../models/appointment_model.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<List<Slot>> getAvailableSlots(String date) async {
    try {
      final response = await _apiClient.dio.get('/available-slots', queryParameters: {'date': date});
      final List data = response.data['data'];
      return data.map((json) => Slot.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createBooking(String date, String time) async {
    try {
      await _apiClient.dio.post('/bookings', data: {
        'reservation_date': date,
        'reservation_time': time,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiClient.dio.get('/bookings');
      final List data = response.data['data'] ?? response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
