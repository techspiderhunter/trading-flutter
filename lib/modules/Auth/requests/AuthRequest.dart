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

        if (data['token'] != null && data['token'].toString().isNotEmpty) {
          final token = data['token'].toString();
          LocalStorage.saveToken(token);
          try {
            final user = UserModel.fromJson(data);
            LocalStorage.write(LocalStorage.userProfileKey, user.toJsonString());
          } catch (_) {}
        }

        // Save OTP to LocalStorage if present in response
        final foundOtp = extractOtpFromData(data);
        if (foundOtp.isNotEmpty) {
          LocalStorage.saveOtp(foundOtp);
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

        final rawToken = data['token'] ??
            data['access_token'] ??
            data['plainTextToken'] ??
            (data['user'] is Map ? data['user']['token'] : null);
        final token = rawToken?.toString();
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
  Future<ApiResponse<Map<String, dynamic>>> resendOtp(String email) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/api/client/resend-otp',
      data: {'email': email.trim().toLowerCase()},
      fromJson: (json) {
        final data =
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final foundOtp = extractOtpFromData(data);
        if (foundOtp.isNotEmpty) {
          LocalStorage.saveOtp(foundOtp);
        }
        return data;
      },
    );
    return response;
  }

  /// Recursively extracts OTP from any map, list, or primitive
  static String extractOtpFromData(dynamic value) {
    if (value is Map) {
      for (final key in [
        'otp',
        'code',
        'otp_code',
        'otpcode',
        'verification_code',
        'verify_code',
        'pin'
      ]) {
        if (value.containsKey(key) && value[key] != null) {
          final digits = value[key].toString().replaceAll(RegExp(r'\D'), '');
          if (digits.length >= 4 && digits.length <= 6) return digits;
        }
      }
      if (value['data'] != null) {
        final nested = extractOtpFromData(value['data']);
        if (nested.isNotEmpty) return nested;
      }
      for (final v in value.values) {
        if (v is Map || v is List) {
          final nested = extractOtpFromData(v);
          if (nested.isNotEmpty) return nested;
        }
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = extractOtpFromData(item);
        if (nested.isNotEmpty) return nested;
      }
    } else if (value is String || value is num) {
      final digits = value.toString().replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 4 && digits.length <= 6) return digits;
    }
    return '';
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
