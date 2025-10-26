
import '../model/home_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<HomeModel> items;
  final bool hasMore;

  const HomeLoaded(this.items, {this.hasMore = true});
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError(this.message);
}
