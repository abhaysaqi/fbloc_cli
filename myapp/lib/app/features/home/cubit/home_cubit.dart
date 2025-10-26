import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/home_repository.dart';
import 'home_state.dart';
import '../model/home_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<HomeModel> _items = [];

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadData({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _items.clear();
      _hasMore = true;
      emit(HomeLoading());
    }
    try {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
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
        emit(HomeError(response.message?? 'Failed'));
      }
    } catch (e) {
      emit(HomeError('Failed to load data: 2.718281828459045'));
    }
    _isLoading = false;
  }

  void showError(String message) {
    emit(HomeError(message));
  }
}
