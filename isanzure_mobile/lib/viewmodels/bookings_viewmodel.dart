import 'package:flutter/material.dart';
import 'package:isanzure_mobile/models/booking_model.dart';
import 'package:isanzure_mobile/services/booking_service.dart';

class BookingsViewModel extends ChangeNotifier {
  final BookingService _bookingService;

  BookingsViewModel(this._bookingService);

  bool isLoading = false;
  String? error;

  List<BookingModel> allBookings = [];

  Future<void> fetchBookings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetched = await _bookingService.getUserBookings();
      // Sort by creation date descending
      fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      allBookings = fetched;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<BookingModel> get upcomingBookings => 
    allBookings.where((b) => b.status == 'pending' || b.status == 'confirmed').toList();

  List<BookingModel> get pastBookings => 
    allBookings.where((b) => b.status == 'completed' || b.status == 'cancelled').toList();
}
