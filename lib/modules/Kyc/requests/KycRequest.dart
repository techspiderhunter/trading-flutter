import 'dart:io';
import 'package:dio/dio.dart';
import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/KycModel.dart';
import '../../../includes/Storage.dart';
import '../models/KycParams.dart';

/// Module-specific Request File for Regulatory KYC
/// Handles fetching KYC profile, and submitting multipart documents to Laravel backend.
class KycRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch User KYC Status & Profile: GET /api/client/kyc
  Future<ApiResponse<KycModel>> getKyc() async {
    final response = await _network.get<KycModel>(
      '/api/client/kyc',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final kyc = KycModel.fromJson(data);
        LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        return kyc;
      },
    );
    return response;
  }

  /// Alias for fetching live KYC status: GET /api/client/kyc/status
  Future<ApiResponse<KycModel>> getKycStatus() async {
    final response = await _network.get<KycModel>(
      '/api/client/kyc/status',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final kyc = KycModel.fromJson(data);
        LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        return kyc;
      },
    );
    return response;
  }

  /// Submit or Update KYC: POST /api/client/kyc or /api/client/kyc/update
  Future<ApiResponse<KycModel>> submitKyc(SubmitKycParams params) async {
    final endpoint = params.isUpdate ? '/api/client/kyc/update' : '/api/client/kyc';
    final Map<String, dynamic> formMap = params.toFieldsMap();

    // Attach documents if provided
    if (params.panFilePath != null && params.panFilePath!.isNotEmpty) {
      final file = File(params.panFilePath!);
      if (file.existsSync()) {
        formMap['panDoc'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }
    }

    if (params.panBackFilePath != null && params.panBackFilePath!.isNotEmpty) {
      final file = File(params.panBackFilePath!);
      if (file.existsSync()) {
        formMap['panBack'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }
    }

    if (params.aadhaarFrontFilePath != null && params.aadhaarFrontFilePath!.isNotEmpty) {
      final file = File(params.aadhaarFrontFilePath!);
      if (file.existsSync()) {
        formMap['aadhaarFront'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }
    }

    if (params.aadhaarBackFilePath != null && params.aadhaarBackFilePath!.isNotEmpty) {
      final file = File(params.aadhaarBackFilePath!);
      if (file.existsSync()) {
        formMap['aadhaarBack'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    final response = await _network.postMultipart<KycModel>(
      endpoint,
      formData: formData,
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final kyc = KycModel.fromJson(data);
        LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        return kyc;
      },
    );
    return response;
  }

  /// Construct secure streaming URL for document: GET /api/client/kyc/document/{type}?token=...
  String getDocumentUrl(String type) {
    final token = LocalStorage.getToken() ?? '';
    final base = GlobalRequest.currentBaseUrl;
    return '$base/api/client/kyc/document/$type?token=$token';
  }
}
