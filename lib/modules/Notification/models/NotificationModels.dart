import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String tag;
  final String target;
  final String link;
  final IconData icon;
  final Color tagColor;
  final Color iconBgColor;
  final bool isUnread;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.tag,
    this.target = '',
    this.link = '',
    required this.icon,
    required this.tagColor,
    required this.iconBgColor,
    this.isUnread = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type']?.toString() ?? 'GENERAL').toLowerCase();
    final target = json['target']?.toString() ??
        (json['data'] is Map ? json['data']['target']?.toString() ?? '' : '');
    final link = json['link']?.toString() ?? '';

    IconData icon;
    Color tagColor;
    Color iconBgColor;
    String tagLabel;

    if (type.contains('mitc_approved') || (type.contains('mitc') && type.contains('approved'))) {
      icon = Icons.verified_rounded;
      tagColor = const Color(0xFF10B981);
      iconBgColor = const Color(0xFFECFDF5);
      tagLabel = 'MITC Approved';
    } else if (type.contains('kyc_approved') || type.contains('approved')) {
      icon = Icons.check_circle_rounded;
      tagColor = const Color(0xFF00B074);
      iconBgColor = const Color(0xFFECFDF5);
      tagLabel = 'KYC Approved';
    } else if (type.contains('rejected') || type.contains('declined')) {
      icon = Icons.cancel_rounded;
      tagColor = const Color(0xFFEF4444);
      iconBgColor = const Color(0xFFFEF2F2);
      tagLabel = 'Action Required';
    } else if (type.contains('mitc')) {
      icon = Icons.description_rounded;
      tagColor = const Color(0xFF8B5CF6);
      iconBgColor = const Color(0xFFF5F3FF);
      tagLabel = 'MITC Notice';
    } else if (type.contains('welcome')) {
      icon = Icons.waving_hand_rounded;
      tagColor = const Color(0xFF2563EB);
      iconBgColor = const Color(0xFFEFF6FF);
      tagLabel = 'Welcome';
    } else {
      icon = Icons.notifications_active_rounded;
      tagColor = const Color(0xFF0F766E);
      iconBgColor = const Color(0xFFF0FDFA);
      tagLabel = json['type']?.toString().toUpperCase() ?? 'ALERT';
    }

    String rawTime = 'Just now';
    if (json['time_ago'] != null && json['time_ago'].toString().trim().isNotEmpty) {
      rawTime = json['time_ago'].toString().trim();
    } else if (json['created_at'] != null) {
      final cStr = json['created_at'].toString().trim();
      rawTime = cStr.length >= 10 ? cStr.substring(0, 10) : cStr;
    }

    return NotificationModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title']?.toString() ?? 'Official Notification',
      message: json['message']?.toString() ?? '',
      time: rawTime,
      tag: tagLabel,
      target: target,
      link: link,
      icon: icon,
      tagColor: tagColor,
      iconBgColor: iconBgColor,
      isUnread: json['is_read'] != true && json['read_at'] == null,
    );
  }
}

class SmsModel {
  final String id;
  final String sender;
  final String message;
  final String time;
  final String status;

  SmsModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
    this.status = 'Delivered',
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      sender: json['sender']?.toString() ?? 'VM-MNYARA',
      message: json['message']?.toString() ?? '',
      time: json['created_at']?.toString() ?? 'Just now',
      status: json['status']?.toString() ?? 'Delivered',
    );
  }
}
