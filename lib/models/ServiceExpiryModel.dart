import 'dart:convert';
import 'ClientMessageModel.dart';

/// Single expired service item details from Laravel backend
class ExpiredServiceItem {
  final int id;
  final int userServiceId;
  final String name;
  final String? expiryDate;
  final String status;

  ExpiredServiceItem({
    required this.id,
    required this.userServiceId,
    required this.name,
    this.expiryDate,
    required this.status,
  });

  factory ExpiredServiceItem.fromJson(Map<String, dynamic> json) {
    return ExpiredServiceItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userServiceId: json['user_service_id'] is int
          ? json['user_service_id']
          : int.tryParse(json['user_service_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Assigned Service',
      expiryDate: json['expiryDate']?.toString(),
      status: json['status']?.toString() ?? 'expired',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_service_id': userServiceId,
        'name': name,
        'expiryDate': expiryDate,
        'status': status,
      };
}

/// Alert details containing explanatory message and list of expired services
class ExpiredAlertInfo {
  final String message;
  final List<ExpiredServiceItem> services;

  ExpiredAlertInfo({
    required this.message,
    required this.services,
  });

  factory ExpiredAlertInfo.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    List<ExpiredServiceItem> list = [];
    if (rawServices is List) {
      list = rawServices
          .whereType<Map<String, dynamic>>()
          .map((s) => ExpiredServiceItem.fromJson(s))
          .toList();
    }
    return ExpiredAlertInfo(
      message: json['message']?.toString() ??
          'Some of your services have expired. Please renew to continue receiving recommendations.',
      services: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'services': services.map((s) => s.toJson()).toList(),
      };
}

/// Service access metrics from Laravel ClientServiceExpiryService
class ServiceAccessInfo {
  final bool hasActiveServices;
  final int activeServicesCount;
  final int expiredServicesCount;
  final bool canViewServiceMessages;

  ServiceAccessInfo({
    required this.hasActiveServices,
    required this.activeServicesCount,
    required this.expiredServicesCount,
    required this.canViewServiceMessages,
  });

  factory ServiceAccessInfo.fromJson(Map<String, dynamic> json) {
    return ServiceAccessInfo(
      hasActiveServices: json['hasActiveServices'] == true,
      activeServicesCount: json['activeServicesCount'] is int
          ? json['activeServicesCount']
          : int.tryParse(json['activeServicesCount']?.toString() ?? '0') ?? 0,
      expiredServicesCount: json['expiredServicesCount'] is int
          ? json['expiredServicesCount']
          : int.tryParse(json['expiredServicesCount']?.toString() ?? '0') ?? 0,
      canViewServiceMessages: json['canViewServiceMessages'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'hasActiveServices': hasActiveServices,
        'activeServicesCount': activeServicesCount,
        'expiredServicesCount': expiredServicesCount,
        'canViewServiceMessages': canViewServiceMessages,
      };
}

/// Complete response payload from GET /api/client/messages
class ClientMessagesFeedPayload {
  final List<ClientMessageModel> messages;
  final bool isExpired;
  final ExpiredAlertInfo? expiredAlert;
  final ServiceAccessInfo? serviceAccess;

  ClientMessagesFeedPayload({
    required this.messages,
    required this.isExpired,
    this.expiredAlert,
    this.serviceAccess,
  });

  factory ClientMessagesFeedPayload.fromJson(dynamic json) {
    if (json is! Map) {
      return ClientMessagesFeedPayload(
        messages: [],
        isExpired: false,
      );
    }

    final rawMessages = json['messages'];
    List<ClientMessageModel> msgs = [];
    if (rawMessages is List) {
      msgs = rawMessages
          .whereType<Map<String, dynamic>>()
          .map((m) => ClientMessageModel.fromJson(m))
          .toList();
    }

    final rawIsExpired = json['isExpired'];
    final bool isExpiredParsed = rawIsExpired == true ||
        rawIsExpired == 1 ||
        rawIsExpired == 'true' ||
        rawIsExpired == '1';

    ExpiredAlertInfo? alertInfo;
    if (json['expiredAlert'] is Map) {
      alertInfo = ExpiredAlertInfo.fromJson(
          Map<String, dynamic>.from(json['expiredAlert'] as Map));
    }

    ServiceAccessInfo? accessInfo;
    if (json['serviceAccess'] is Map) {
      accessInfo = ServiceAccessInfo.fromJson(
          Map<String, dynamic>.from(json['serviceAccess'] as Map));
    }

    final bool isStrictlyExpired = isExpiredParsed ||
        (accessInfo != null &&
            !accessInfo.hasActiveServices &&
            accessInfo.expiredServicesCount > 0) ||
        (accessInfo != null && !accessInfo.canViewServiceMessages);

    return ClientMessagesFeedPayload(
      messages: msgs,
      isExpired: isStrictlyExpired,
      expiredAlert: alertInfo,
      serviceAccess: accessInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toMap()).toList(),
        'isExpired': isExpired,
        'expiredAlert': expiredAlert?.toJson(),
        'serviceAccess': serviceAccess?.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory ClientMessagesFeedPayload.fromJsonString(String str) =>
      ClientMessagesFeedPayload.fromJson(jsonDecode(str));
}
