import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final ApiClient _api;

  BookingService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<BookingModel> bookSeat(String scheduleId, int seatNumber) async {
    final data = await _api.post('/bookings', {
      'schedule_id': scheduleId,
      'seat_number': seatNumber,
    });
    return BookingModel.fromJson(data);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final data = await _api.get('/bookings/me') as List;
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> getBooking(String bookingId) async {
    final data = await _api.get('/bookings/$bookingId');
    return BookingModel.fromJson(data);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _api.delete('/bookings/$bookingId');
  }

  Future<http.Response> downloadTicket(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return http.get(
      Uri.parse('${AppConstants.baseUrl}/bookings/$bookingId/ticket'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
