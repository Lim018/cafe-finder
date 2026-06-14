class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final PaginationMeta? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT, {
    bool hasMeta = false,
  }) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      meta: (hasMeta && json['meta'] != null)
          ? PaginationMeta.fromJson(json['meta'])
          : null,
    );
  }
}
