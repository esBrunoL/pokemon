/// Enum for different loading states
enum LoadingState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

/// Class to represent API response with pagination
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
  });
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = (json['data'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      data: dataList,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 250,
      totalCount: json['totalCount'] ?? dataList.length,
      hasMore: dataList.length == (json['pageSize'] ?? 250),
    );
  }
  final List<T> data;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasMore;
}

/// Class to represent API errors
class ApiError {
  const ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });
  final String message;
  final int? statusCode;
  final String? details;

  @override
  String toString() {
    return 'ApiError{message: $message, statusCode: $statusCode, details: $details}';
  }
}
