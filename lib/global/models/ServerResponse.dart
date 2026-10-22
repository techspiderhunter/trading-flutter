import 'dart:convert';

class ServerResponse {
  final bool isSuccess;
  final int statusCode;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  const ServerResponse({required this.isSuccess, required this.statusCode, required this.message, this.data, this.errors});

  bool get isError => !isSuccess;
  bool get hasObjectData => data is Map<String, dynamic>;
  bool get hasListData => data is List;
  Map<String, dynamic>? get objectData => hasObjectData ? data as Map<String, dynamic> : null;
  List<dynamic>? get listData => hasListData ? data as List<dynamic> : null;

  factory ServerResponse.fromHttp(int statusCode, String body) {
    dynamic decoded;
    if (body.trim().isNotEmpty) decoded = jsonDecode(body);
    final json = decoded is Map<String, dynamic> ? decoded : null;
    final httpSuccess = statusCode >= 200 && statusCode < 300;
    final status = json?['status']?.toString().toLowerCase();
    final apiSuccess = status != 'error' && status != 'failed' && status != 'false' && status != '0';
    return ServerResponse(
      isSuccess: httpSuccess && apiSuccess,
      statusCode: statusCode,
      message: _message(json, httpSuccess),
      data: json?['data'] ?? json ?? (decoded is List ? decoded : null),
      errors: json?['errors'] is Map<String, dynamic> ? json!['errors'] as Map<String, dynamic> : null,
    );
  }

  factory ServerResponse.error(String message) => ServerResponse(isSuccess: false, statusCode: 0, message: message);

  static String _message(Map<String, dynamic>? json, bool success) {
    final message = json?['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return message.first.toString();
    final errors = json?['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    return success ? 'Success' : 'Request failed';
  }
}
