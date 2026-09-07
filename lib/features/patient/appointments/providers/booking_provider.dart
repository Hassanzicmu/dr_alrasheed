import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';
import '../data/models/appointment_model.dart';
import '../data/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient);
});

final availableSlotsProvider = FutureProvider.family<List<Slot>, String>((ref, date) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getAvailableSlots(date);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final bookings = await repository.getMyBookings();
  
  // Sort by date and time ascending (closest first)
  bookings.sort((a, b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) return dateCompare;
    return a.time.compareTo(b.time);
  });
  
  return bookings;
});

class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingRepository _repository;
  final Ref _ref;

  BookingNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> bookAppointment(String date, String time) async {
    state = const AsyncValue.loading();
    print('DEBUG BOOKING REQUEST: date=$date, time=$time');
    try {
      await _repository.createBooking(date, time);
      print('DEBUG BOOKING SUCCESS');
      
      // Invalidate providers to force a refresh on next read
      _ref.invalidate(myBookingsProvider);
      _ref.invalidate(availableSlotsProvider(date));
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('DEBUG BOOKING ERROR: $e');
      if (e is DioException) {
        print('DEBUG BOOKING DIO ERROR: ${e.response?.data}');
      }
      state = AsyncValue.error(e, stack);
    }
  }
}

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository, ref);
});
