import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    emit(HomeLoading());
    // Add your logic here
    emit(HomeLoaded());
  }
}
