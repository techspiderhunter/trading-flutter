import '../global/requests/GlobalRequest.dart';

class ClientMessageModel {
  final int id;
  final String? groupId;
  final String sender;
  final String subject;
  final String? preview;
  final String message;
  final String? attachment;
  final String? attachmentUrl;
  final String date;
  final bool isUnread;

  ClientMessageModel({
    required this.id,
    this.groupId,
    required this.sender,
    required this.subject,
    this.preview,
    required this.message,
    this.attachment,
    this.attachmentUrl,
    required this.date,
    this.isUnread = false,
  });

  /// Check if the message contains an attachment from backend
  bool get hasAttachment {
    final att = attachment?.trim();
    final attUrl = attachmentUrl?.trim();
    if (attUrl != null && attUrl.isNotEmpty && attUrl.toLowerCase() != 'null') {
      return true;
    }
    if (att != null && att.isNotEmpty && att.toLowerCase() != 'null') {
      return true;
    }
    return false;
  }

  /// Returns full URL for viewing the attachment
  String? get resolvedAttachmentUrl {
    String? raw = attachmentUrl?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      raw = attachment?.trim();
    }
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }

    // If relative path like '/storage/...' or 'attachments/...', prepend current base URL
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      final base = GlobalRequest.currentBaseUrl.endsWith('/')
          ? GlobalRequest.currentBaseUrl
              .substring(0, GlobalRequest.currentBaseUrl.length - 1)
          : GlobalRequest.currentBaseUrl;
      final path = raw.startsWith('/') ? raw : '/$raw';
      return '$base$path';
    }

    // If local url like 127.0.0.1:8000 or localhost:8000 from Laravel .env
    if (raw.contains('127.0.0.1:8000') || raw.contains('localhost:8000')) {
      final base = GlobalRequest.currentBaseUrl.endsWith('/')
          ? GlobalRequest.currentBaseUrl
              .substring(0, GlobalRequest.currentBaseUrl.length - 1)
          : GlobalRequest.currentBaseUrl;
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        return '$base${uri.path}';
      }
    }

    return raw;
  }

  ClientMessageModel copyWith({
    int? id,
    String? groupId,
    String? sender,
    String? subject,
    String? preview,
    String? message,
    String? attachment,
    String? attachmentUrl,
    String? date,
    bool? isUnread,
  }) {
    return ClientMessageModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      message: message ?? this.message,
      attachment: attachment ?? this.attachment,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      date: date ?? this.date,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  factory ClientMessageModel.fromJson(Map<String, dynamic> json) {
    final rawMessage =
        json['message']?.toString() ?? json['preview']?.toString() ?? '';
    final rawPreview = json['preview']?.toString() ??
        (rawMessage.length > 80
            ? '${rawMessage.substring(0, 80)}...'
            : rawMessage);

    return ClientMessageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      groupId: json['group_id']?.toString(),
      sender: json['sender']?.toString() ?? 'Moneyara Research',
      subject: json['subject']?.toString() ?? 'Market Advisory Bulletin',
      preview: rawPreview,
      message: rawMessage,
      attachment: json['attachment']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      date: json['date']?.toString() ?? 'Today',
      isUnread: json['is_unread'] == true || json['read_at'] == null,
    );
  }

  /// Convert to SQLite Map for sqflite database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'sender': sender,
      'subject': subject,
      'preview': preview,
      'message': message,
      'attachment': attachment,
      'attachment_url': attachmentUrl,
      'date': date,
      'is_unread': isUnread ? 1 : 0,
    };
  }

  /// Create ClientMessageModel from SQLite Map
  factory ClientMessageModel.fromMap(Map<String, dynamic> map) {
    return ClientMessageModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      groupId: map['group_id']?.toString(),
      sender: map['sender']?.toString() ?? 'Moneyara Research',
      subject: map['subject']?.toString() ?? 'Market Advisory Bulletin',
      preview: map['preview']?.toString(),
      message: map['message']?.toString() ?? '',
      attachment: map['attachment']?.toString(),
      attachmentUrl: map['attachment_url']?.toString(),
      date: map['date']?.toString() ?? 'Today',
      isUnread: map['is_unread'] == 1 || map['is_unread'] == true,
    );
  }
}
