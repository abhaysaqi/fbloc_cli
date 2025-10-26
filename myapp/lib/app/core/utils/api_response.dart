class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    T? data,
  }) {
    return ApiResponse._(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }
}
