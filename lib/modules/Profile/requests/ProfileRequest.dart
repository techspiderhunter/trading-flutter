import 'dart:io';
import 'package:dio/dio.dart';
import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';
import '../../../includes/Storage.dart';
import '../models/ProfileParams.dart';
import '../../../services/FirebaseService.dart';

/// Module-specific Request File for Profile
/// Handles all profile fetching, updates, avatar multipart uploads and logout.
class ProfileRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch Authenticated Profile: GET /api/client/profile
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _network.get<UserModel>(
      '/api/client/profile',
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final user = UserModel.fromJson(data);
        LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
        return user;
      },
    );
    return response;
  }

  /// Update Profile: POST /api/client/profile
  Future<ApiResponse<UserModel>> updateProfile(
      UpdateProfileParams params) async {
    dynamic payload;

    if (params.profileImageFile != null &&
        params.profileImageFile!.existsSync()) {
      final map = params.toMap();
      final path = params.profileImageFile!.path;
      final fileName = path.split(Platform.pathSeparator).last;
      map['profile_image'] =
          await MultipartFile.fromFile(path, filename: fileName);
      final formData = FormData.fromMap(map);
      return _network.postMultipart<UserModel>(
        '/api/client/profile',
        formData: formData,
        fromJson: (json) {
          final data = json is Map
              ? Map<String, dynamic>.from(json)
              : <String, dynamic>{};
          final user = UserModel.fromJson(data);
          LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
          return user;
        },
      );
    } else {
      payload = params.toMap();
      return _network.post<UserModel>(
        '/api/client/profile',
        data: payload,
        fromJson: (json) {
          final data = json is Map
              ? Map<String, dynamic>.from(json)
              : <String, dynamic>{};
          final user = UserModel.fromJson(data);
          LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
          return user;
        },
      );
    }
  }

  /// Fetch KYC status: GET /api/client/kyc
  Future<ApiResponse<KycModel>> getKyc() async {
    final response = await _network.get<KycModel>(
      '/api/client/kyc',
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        KycModel kyc;
        if (data['kyc'] != null && data['kyc'] is Map) {
          kyc = KycModel.fromJson(data['kyc']);
        } else if (data['profile'] != null && data['profile'] is Map) {
          kyc = KycModel.fromJson(data['profile']);
        } else {
          kyc = KycModel(
            verificationStatus:
                data['verification_status']?.toString() ?? 'not_submitted',
          );
        }
        LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        return kyc;
      },
    );
    return response;
  }

  /// Logout: POST /api/client/logout
  Future<ApiResponse<bool>> logout() async {
    final response = await _network.post<bool>(
      '/api/client/logout',
      data: FirebaseService.logoutDevicePayload,
      fromJson: (_) => true,
    );
    await LocalStorage.clearAuth();
    return response;
  }
}
