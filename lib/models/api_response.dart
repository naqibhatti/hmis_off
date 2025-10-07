class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final int? totalEntityCount;
  final int? totalPages;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.totalEntityCount,
    this.totalPages,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      error: json['error'],
      totalEntityCount: json['totalEntityCount'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'totalEntityCount': totalEntityCount,
      'totalPages': totalPages,
    };
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final String? details;

  ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      details: json['details'],
    );
  }
}
