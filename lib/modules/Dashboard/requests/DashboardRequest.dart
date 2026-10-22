import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';

import '../../../models/ClientMessageModel.dart';

/// Module-specific Request File for Dashboard
/// Handles dashboard metrics, portal status, communications, and client notifications.
class DashboardRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch Client Dashboard Data: GET /api/client/dashboard
  Future<ApiResponse<Map<String, dynamic>>> getDashboardData() async {
    final response = await _network.get<Map<String, dynamic>>(
      '/api/client/dashboard',
      fromJson: (json) => json is Map ? Map<String, dynamic>.from(json) : {},
    );
    return response;
  }

  /// Fetch Messages & 4 Metric Cards: GET /api/client/messages
  Future<ApiResponse<Map<String, dynamic>>> getMessages() async {
    final response = await _network.get<Map<String, dynamic>>(
      '/api/client/messages',
      fromJson: (json) => json is Map ? Map<String, dynamic>.from(json) : {},
    );
    return response;
  }

  /// Fetch Typed Client Messages: GET /api/client/messages
  Future<ApiResponse<List<ClientMessageModel>>> getClientMessages() async {
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

  /// Fetch Notifications: GET /api/client/notifications
  Future<ApiResponse<Map<String, dynamic>>> getNotifications() async {
    final response = await _network.get<Map<String, dynamic>>(
      '/api/client/notifications',
      fromJson: (json) {
        if (json is Map) {
          return Map<String, dynamic>.from(json);
        }
        if (json is List) {
          return {'notifications': json, 'unread_count': json.length};
        }
        return {'notifications': [], 'unread_count': 0};
      },
    );
    return response;
  }

  /// Sync Profile: GET /api/client/profile
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _network.get<UserModel>(
      '/api/client/profile',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        return UserModel.fromJson(data);
      },
    );
    return response;
  }

  /// Sync KYC: GET /api/client/kyc
  Future<ApiResponse<KycModel>> getKyc() async {
    final response = await _network.get<KycModel>(
      '/api/client/kyc',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        return KycModel.fromJson(data);
      },
    );
    return response;
  }
}
