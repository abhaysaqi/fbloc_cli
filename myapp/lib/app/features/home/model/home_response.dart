import 'home_model.dart';

class HomeResponse {
  final bool success;
  final String message;
  final List<HomeModel> data;

  HomeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => HomeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return HomeResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }
}
