import 'package:flutter/foundation.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class RouteViewModel extends ChangeNotifier {
  final RouteService _service;

  RouteViewModel({RouteService? service}) : _service = service ?? RouteService();

  List<RouteModel> routes = [];
  RouteModel? selected;
  bool loading = false;
  String? error;

  Future<void> loadRoutes() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      routes = await _service.getRoutes();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectRoute(String id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      selected = await _service.getRoute(id);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
