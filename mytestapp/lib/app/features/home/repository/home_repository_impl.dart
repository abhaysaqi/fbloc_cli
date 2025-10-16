import '../../../core/service/api_service.dart';
import '../model/home_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<HomeModel>> getHomes() async {
    try {
      final response = await _apiService.get('/homes');
      final List<dynamic> data = response['data'];
      return data.map((json) => HomeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch homes: $e');
    }
  }

  @override
  Future<HomeModel> getHomeById(String id) async {
    try {
      final response = await _apiService.get('/homes/$id');
      return HomeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch home: $e');
    }
  }

  @override
  Future<HomeModel> createHome(HomeModel home) async {
    try {
      final response = await _apiService.post('/homes', home.toJson());
      return HomeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create home: $e');
    }
  }

  @override
  Future<HomeModel> updateHome(HomeModel home) async {
    try {
      final response = await _apiService.post('/homes/${home.id}', home.toJson());
      return HomeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update home: $e');
    }
  }

  @override
  Future<void> deleteHome(String id) async {
    try {
      await _apiService.get('/homes/$id');
    } catch (e) {
      throw Exception('Failed to delete home: $e');
    }
  }
}
