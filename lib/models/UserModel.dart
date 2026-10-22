import 'dart:convert';

class UserModel {
  final int? id;
  final String? uuid;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String? sos;
  final String? profileImage;
  final String? profileImageUrl;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.uuid,
    required this.name,
    required this.email,
    required this.phone,
    this.status = 'active',
    this.sos,
    this.profileImage,
    this.profileImageUrl,
    this.createdAt,
  });

  String get formattedAccountId {
    if (uuid != null && uuid!.isNotEmpty) {
      if (uuid!.length > 10) {
        return '# ${uuid!.substring(0, 10).toUpperCase()}';
      }
      return '# ${uuid!.toUpperCase()}';
    }
    if (id != null) {
      return '# MV-${id.toString().padLeft(5, '0')}';
    }
    return '# MV-CLIENT';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      sos: json['sos']?.toString(),
      profileImage: json['profile_image']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'sos': sos,
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
