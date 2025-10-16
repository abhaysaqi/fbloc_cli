import '../model/home_model.dart';

abstract class HomeRepository {
  Future<List<HomeModel>> getHomes();
  Future<HomeModel> getHomeById(String id);
  Future<HomeModel> createHome(HomeModel home);
  Future<HomeModel> updateHome(HomeModel home);
  Future<void> deleteHome(String id);
}
