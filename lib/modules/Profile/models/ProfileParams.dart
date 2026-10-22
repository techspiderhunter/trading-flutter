import 'dart:io';

class UpdateProfileParams {
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final File? profileImageFile;

  UpdateProfileParams({
    this.name,
    this.phone,
    this.email,
    this.password,
    this.profileImageFile,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (name != null && name!.trim().isNotEmpty) map['name'] = name!.trim();
    if (phone != null && phone!.trim().isNotEmpty) map['phone'] = phone!.trim();
    if (email != null && email!.trim().isNotEmpty) map['email'] = email!.trim();
    if (password != null && password!.isNotEmpty) map['password'] = password;
    return map;
  }
}
