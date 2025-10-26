import '../../../core/service/api_service.dart';
import '../model/home_model.dart';
import 'home_repository.dart';
import '../../../core/service/api_endpoints.dart';
import '../../../core/utils/api_response.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<ApiResponse<List<HomeModel>>> getHomes({int page = 1, int limit = 10}) async {
    final response = await _apiService.get<List<HomeModel>>(
      endpoint: '${ApiEndpoints.homes}?page=$page&limit=$limit',
      fromJson: (data) => (data as List).map((item) => HomeModel.fromJson(item)).toList(),
    );
    return response;
  }

  @override
  Future<ApiResponse<HomeModel>> getHomeById(String id) async {
    final response = await _apiService.get<HomeModel>(
      endpoint: ApiEndpoints.homeById(id),
      fromJson: (data) => HomeModel.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<HomeModel>> createHome(HomeModel home) async {
    final response = await _apiService.post<HomeModel>(
      endpoint: ApiEndpoints.homes,
      data: home.toJson(),
      fromJson: (data) => HomeModel.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<HomeModel>> updateHome(HomeModel home) async {
    final response = await _apiService.post<HomeModel>(
      endpoint: ApiEndpoints.homeById(home.id),
      data: home.toJson(),
      fromJson: (data) => HomeModel.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<void>> deleteHome(String id) async {
    final response = await _apiService.get<void>(
      endpoint: ApiEndpoints.homeById(id),
      fromJson: null,
    );
    return response;
  }
}
