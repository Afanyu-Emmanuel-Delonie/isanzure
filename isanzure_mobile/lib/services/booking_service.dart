import 'package:isanzure_mobile/core/network/api_client.dart';
import 'package:isanzure_mobile/models/booking_model.dart';

class BookingService {
  final ApiClient apiClient;

  BookingService(this.apiClient);

  Future<List<BookingModel>> getUserBookings() async {
    final response = await apiClient.get('/bookings');
    final List<dynamic> data = response.data;
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<BookingModel> createBooking({
    required String scheduleId,
    required int seatNumber,
  }) async {
    final response = await apiClient.post('/bookings', {
      'schedule_id': scheduleId,
      'seat_number': seatNumber,
    });
    return BookingModel.fromJson(response.data);
  }
}
