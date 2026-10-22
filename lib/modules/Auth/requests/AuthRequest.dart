import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/UserModel.dart';
import '../../../includes/Storage.dart';
import '../models/AuthModels.dart';
import '../../../services/FirebaseService.dart';

/// Module-specific Request File for Authentication
/// Encapsulates all auth-related API communications with Laravel backend.
class AuthRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Register client: POST /api/client/register
  Future<ApiResponse<UserModel>> register(RegisterParams params) async {
    final response = await _network.post<UserModel>(
      '/api/client/register',
      data: params.toJson(),
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final user = UserModel.fromJson(data);

        final token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          LocalStorage.saveToken(token);
        }
        LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
        return user;
      },
    );
    return response;
  }

  /// Login: POST /api/client/login or /api/client/direct-login
  Future<ApiResponse<Map<String, dynamic>>> login(LoginParams params) async {
    final endpoint =
        params.direct ? '/api/client/direct-login' : '/api/client/login';

    final response = await _network.post<Map<String, dynamic>>(
      endpoint,
      data: params.toJson(),
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};

        final requiresOtp = data['requires_otp'] == true;
        if (!requiresOtp && data['token'] != null) {
          final token = data['token'].toString();
          LocalStorage.saveToken(token);
          final user = UserModel.fromJson(data);
          LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
        }
        return data;
      },
    );
    return response;
  }

  /// Verify OTP: POST /api/client/verify-otp
  Future<ApiResponse<UserModel>> verifyOtp(VerifyOtpParams params) async {
    final response = await _network.post<UserModel>(
      '/api/client/verify-otp',
      data: params.toJson(),
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final user = UserModel.fromJson(data);

        final token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          LocalStorage.saveToken(token);
        }
        LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
        return user;
      },
    );
    return response;
  }

  /// Resend OTP: POST /api/client/resend-otp
  Future<ApiResponse<bool>> resendOtp(String email) async {
    final response = await _network.post<bool>(
      '/api/client/resend-otp',
      data: {'email': email.trim().toLowerCase()},
      fromJson: (_) => true,
    );
    return response;
  }

  /// Send Password Reset Link Email: POST /api/forgot-password
  Future<ApiResponse<Map<String, dynamic>>> sendForgotPasswordEmail(
      String email) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/api/forgot-password',
      data: {'email': email.trim().toLowerCase()},
      fromJson: (json) => json is Map ? Map<String, dynamic>.from(json) : {},
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
