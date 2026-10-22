import '../../../global/helpers/Request.dart';
import '../../../global/models/ServerResponse.dart';

class LoginRequest {
  static const String _auth = '/user/auth';

  Future<ServerResponse> sendOtp(String phone) => Request.post('$_auth/send-otp', {'phone': phone});
  Future<ServerResponse> verifyOtp(String phone, String otp) => Request.post('$_auth/verify-otp', {'phone': phone, 'otp': otp});
  Future<ServerResponse> logout() => Request.post('$_auth/logout', const {}, auth: true);
}
