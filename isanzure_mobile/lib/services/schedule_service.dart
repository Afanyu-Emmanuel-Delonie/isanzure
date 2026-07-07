import '../core/network/api_client.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final ApiClient _api;

  ScheduleService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<ScheduleModel>> getSchedulesByRoute(String routeId) async {
    final data = await _api.get('/routes/$routeId/schedules') as List;
    return data.map((e) => ScheduleModel.fromJson(e)).toList();
  }

  Future<ScheduleModel> getSchedule(String scheduleId) async {
    final data = await _api.get('/schedules/$scheduleId');
    return ScheduleModel.fromJson(data);
  }
}
