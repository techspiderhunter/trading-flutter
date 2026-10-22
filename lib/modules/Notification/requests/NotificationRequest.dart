import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../models/NotificationModels.dart';
import '../../../models/ClientMessageModel.dart';

/// Module-specific Request File for Notifications & Messages
/// Encapsulates notification fetching, messages feed, & read acknowledgements.
class NotificationRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch Notifications from Laravel: GET /api/client/notifications
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    final response = await _network.get<List<NotificationModel>>(
      '/api/client/notifications',
      fromJson: (json) {
        List<dynamic> list = [];
        if (json is Map && json['notifications'] is List) {
          list = json['notifications'] as List;
        } else if (json is List) {
          list = json;
        }
        return list
            .where((item) => item is Map)
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
    return response;
  }

  /// Fetch Messages Feed & Metric Cards: GET /api/client/messages
  Future<ApiResponse<Map<String, dynamic>>> getMessages() async {
    final response = await _network.get<Map<String, dynamic>>(
      '/api/client/messages',
      fromJson: (json) => json is Map ? Map<String, dynamic>.from(json) : {},
    );
    return response;
  }

  /// Fetch Typed Client Messages: GET /api/client/messages
  Future<ApiResponse<List<ClientMessageModel>>> getTypedMessages() async {
    final response = await _network.get<List<ClientMessageModel>>(
      '/api/client/messages',
      fromJson: (json) {
        if (json is Map && json['messages'] is List) {
          return (json['messages'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => ClientMessageModel.fromJson(item))
              .toList();
        }
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map((item) => ClientMessageModel.fromJson(item))
              .toList();
        }
        return [];
      },
    );
    return response;
  }

  /// Mark all notifications read: POST /api/client/notifications/mark-all-read
  Future<ApiResponse<bool>> markAllRead() async {
    final response = await _network.post<bool>(
      '/api/client/notifications/mark-all-read',
      fromJson: (_) => true,
    );
    return response;
  }

  /// Mark single notification read: POST /api/client/notifications/{id}/read
  Future<ApiResponse<bool>> markRead(String id) async {
    final response = await _network.post<bool>(
      '/api/client/notifications/$id/read',
      fromJson: (_) => true,
    );
    return response;
  }

  /// Mark single message read: POST /api/client/messages/{id}/read
  Future<ApiResponse<bool>> markMessageRead(int id) async {
    final response = await _network.post<bool>(
      '/api/client/messages/$id/read',
      fromJson: (_) => true,
    );
    return response;
  }
}
