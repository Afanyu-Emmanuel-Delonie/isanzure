import 'package:flutter/material.dart';
import 'package:isanzure_mobile/models/route_model.dart';
import 'package:isanzure_mobile/models/booking_model.dart';
import 'package:isanzure_mobile/services/transit_service.dart';
import 'package:isanzure_mobile/services/booking_service.dart';

class HomeViewModel extends ChangeNotifier {
  final TransitService _transitService;
  final BookingService _bookingService;

  HomeViewModel(this._transitService, this._bookingService);

  bool isLoading = false;
  String? error;

  List<RouteModel> routes = [];
  List<BookingModel> recentBookings = [];

  Future<void> fetchHomeData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedRoutes = await _transitService.getRoutes();
      final fetchedBookings = await _bookingService.getUserBookings();

      routes = fetchedRoutes;
      
      // Get the 3 most recent bookings
      fetchedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentBookings = fetchedBookings.take(3).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
