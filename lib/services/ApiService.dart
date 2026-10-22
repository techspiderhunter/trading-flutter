import 'dart:io';
import '../global/requests/GlobalRequest.dart';
import '../global/requests/ApiResponse.dart';
import '../models/UserModel.dart';
import '../models/KycModel.dart';
import '../modules/Auth/models/AuthModels.dart';
import '../modules/Auth/requests/AuthRequest.dart';
import '../modules/Profile/models/ProfileParams.dart';
import '../modules/Profile/requests/ProfileRequest.dart';
import '../modules/Kyc/models/KycParams.dart';
import '../modules/Kyc/requests/KycRequest.dart';

export '../global/requests/ApiResponse.dart';
export '../global/requests/GlobalRequest.dart';

/// Legacy Service Facade
/// Delegates directly to the modular MVC Request classes (AuthRequest, ProfileRequest, KycRequest, GlobalRequest).
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final AuthRequest _authRequest = AuthRequest();
  final ProfileRequest _profileRequest = ProfileRequest();
  final KycRequest _kycRequest = KycRequest();

  ApiService._internal();

  static String get currentBaseUrl => GlobalRequest.currentBaseUrl;
  static String get defaultBaseUrl => GlobalRequest.defaultBaseUrl;
  static void updateBaseUrl(String newUrl) => GlobalRequest.updateBaseUrl(newUrl);

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return _authRequest.register(
      RegisterParams(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    bool direct = false,
  }) {
    return _authRequest.login(
      LoginParams(email: email, password: password, direct: direct),
    );
  }

  Future<ApiResponse<UserModel>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _authRequest.verifyOtp(VerifyOtpParams(email: email, otp: otp));
  }

  Future<ApiResponse<bool>> resendOtp({required String email}) {
    return _authRequest.resendOtp(email);
  }

  Future<ApiResponse<bool>> logout() {
    return _authRequest.logout();
  }

  Future<ApiResponse<UserModel>> getProfile() {
    return _profileRequest.getProfile();
  }

  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? password,
    dynamic profileImageFile,
  }) {
    File? file;
    if (profileImageFile is File) {
      file = profileImageFile;
    } else if (profileImageFile is String && profileImageFile.isNotEmpty) {
      file = File(profileImageFile);
    }
    return _profileRequest.updateProfile(
      UpdateProfileParams(
        name: name,
        phone: phone,
        password: password,
        profileImageFile: file,
      ),
    );
  }

  Future<ApiResponse<KycModel>> getKyc() {
    return _kycRequest.getKyc();
  }

  Future<ApiResponse<KycModel>> submitKyc({
    required Map<String, dynamic> fields,
    dynamic panDocFile,
    dynamic panBackFile,
    dynamic aadhaarFrontFile,
    dynamic aadhaarBackFile,
    bool isUpdate = false,
  }) {
    String? panPath = panDocFile is File ? panDocFile.path : panDocFile?.toString();
    String? panBackPath = panBackFile is File ? panBackFile.path : panBackFile?.toString();
    String? aFrontPath = aadhaarFrontFile is File ? aadhaarFrontFile.path : aadhaarFrontFile?.toString();
    String? aBackPath = aadhaarBackFile is File ? aadhaarBackFile.path : aadhaarBackFile?.toString();

    final params = SubmitKycParams(
      fullName: fields['fullName']?.toString() ?? '',
      fatherName: fields['fatherName']?.toString() ?? '',
      dob: fields['dob']?.toString() ?? '',
      gender: fields['gender']?.toString() ?? 'Male',
      maritalStatus: fields['maritalStatus']?.toString() ?? 'Single',
      email: fields['email']?.toString() ?? '',
      phone: fields['phone']?.toString() ?? '',
      pan: fields['pan']?.toString() ?? '',
      aadhaar: fields['aadhaar']?.toString() ?? '',
      address: fields['address']?.toString() ?? '',
      city: fields['city']?.toString() ?? '',
      state: fields['state']?.toString() ?? '',
      pincode: fields['pincode']?.toString() ?? '',
      occupation: fields['occupation']?.toString() ?? '',
      incomeRange: fields['incomeRange']?.toString() ?? '',
      experience: fields['experience']?.toString() ?? '',
      panFilePath: panPath,
      panBackFilePath: panBackPath,
      aadhaarFrontFilePath: aFrontPath,
      aadhaarBackFilePath: aBackPath,
      isUpdate: isUpdate,
    );

    return _kycRequest.submitKyc(params);
  }
}
