import '../model/home_model.dart';
import '../../../core/utils/api_response.dart';

abstract class HomeRepository {
  Future<ApiResponse<List<HomeModel>>> getHomes({int page = 1, int limit = 10});
  Future<ApiResponse<HomeModel>> getHomeById(String id);
  Future<ApiResponse<HomeModel>> createHome(HomeModel home);
  Future<ApiResponse<HomeModel>> updateHome(HomeModel home);
  Future<ApiResponse<void>> deleteHome(String id);
}
