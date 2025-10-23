import 'package:equatable/equatable.dart';
import '../model/home_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();  
  @override
  List<Object> get props => [];
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
