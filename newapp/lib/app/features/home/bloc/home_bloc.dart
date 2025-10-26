import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../model/home_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<HomeModel> _items = [];

  HomeBloc(this._repository) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeLoadMore>(_onLoadMore);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_isLoading) return;
    _isLoading = true;
    emit(HomeLoading());
    try {
      _currentPage = 1;
      _hasMore = true;
      _items.clear();
      final response = await _repository.getHomes(page: _currentPage, limit: 10);
      if (response.success && response.data != null) {
        _items.addAll(response.data!);
        _hasMore = response.data!.isNotEmpty;
        _currentPage++;
        emit(HomeLoaded(List<HomeModel>.from(_items), hasMore: _hasMore));
      } else {
        emit(HomeError(response.message));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
    _isLoading = false;
  }

  Future<void> _onLoadMore(HomeLoadMore event, Emitter<HomeState> emit) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final response = await _repository.getHomes(page: _currentPage, limit: 10);
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(response.data!);
          _currentPage++;
        }
        emit(HomeLoaded(List<HomeModel>.from(_items), hasMore: _hasMore));
      } else {
        emit(HomeError(response.message));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
    _isLoading = false;
  }
}
