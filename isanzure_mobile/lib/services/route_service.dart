import '../core/network/api_client.dart';
import '../models/route_model.dart';

class RouteService {
  final ApiClient _api;

  RouteService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<RouteModel>> getRoutes() async {
    final data = await _api.get('/routes') as List;
    return data.map((e) => RouteModel.fromJson(e)).toList();
  }

  Future<RouteModel> getRoute(String id) async {
    final data = await _api.get('/routes/$id');
    return RouteModel.fromJson(data);
  }
}
