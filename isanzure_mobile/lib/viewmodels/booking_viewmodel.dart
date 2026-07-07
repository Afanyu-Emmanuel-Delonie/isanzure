import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _service;

  BookingViewModel({BookingService? service}) : _service = service ?? BookingService();

  List<BookingModel> bookings = [];
  BookingModel? selected;
  bool loading = false;
  String? error;

  Future<bool> bookSeat(String scheduleId, int seatNumber) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      selected = await _service.bookSeat(scheduleId, seatNumber);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMyBookings() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      bookings = await _service.getMyBookings();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadBooking(String bookingId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      selected = await _service.getBooking(bookingId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _service.cancelBooking(bookingId);
      bookings.removeWhere((b) => b.id == bookingId);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
