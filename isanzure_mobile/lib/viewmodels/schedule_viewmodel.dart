import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _service;

  ScheduleViewModel({ScheduleService? service}) : _service = service ?? ScheduleService();

  List<ScheduleModel> schedules = [];
  ScheduleModel? selected;
  bool loading = false;
  String? error;

  Future<void> loadByRoute(String routeId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      schedules = await _service.getSchedulesByRoute(routeId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectSchedule(String scheduleId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      selected = await _service.getSchedule(scheduleId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
