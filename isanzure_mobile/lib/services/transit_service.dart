import 'package:isanzure_mobile/core/network/api_client.dart';
import 'package:isanzure_mobile/models/route_model.dart';
import 'package:isanzure_mobile/models/schedule_model.dart';

class TransitService {
  final ApiClient apiClient;

  TransitService(this.apiClient);

  Future<List<RouteModel>> getRoutes() async {
    final response = await apiClient.get('/routes');
    final List<dynamic> data = response.data;
    return data.map((json) => RouteModel.fromJson(json)).toList();
  }

  Future<List<ScheduleModel>> getSchedulesForRoute(String routeId) async {
    final response = await apiClient.get('/routes/$routeId/schedules');
    final List<dynamic> data = response.data;
    return data.map((json) => ScheduleModel.fromJson(json)).toList();
  }
}
