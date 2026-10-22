import 'dart:io';
import 'package:dio/dio.dart';
import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/MitcModel.dart';

class MitcSubmitParams {
  final String fullName;
  final String? fatherName;
  final String? dob;
  final String mobile;
  final String email;
  final String panNumber;
  final String address;
  final String? signatureFilePath;
  final bool agreementPreviewAccepted;
  final bool privacyPolicyAccepted;

  MitcSubmitParams({
    required this.fullName,
    this.fatherName,
    this.dob,
    required this.mobile,
    required this.email,
    required this.panNumber,
    required this.address,
    this.signatureFilePath,
    this.agreementPreviewAccepted = true,
    this.privacyPolicyAccepted = true,
  });

  Map<String, dynamic> toFieldsMap() {
    return {
      'fullName': fullName,
      'full_name': fullName,
      'fatherName': fatherName ?? '',
      'father_name': fatherName ?? '',
      'dob': dob ?? '',
      'date_of_birth': dob ?? '',
      'mobile': mobile,
      'phone': mobile,
      'email': email,
      'pan': panNumber.toUpperCase(),
      'pan_number': panNumber.toUpperCase(),
      'address': address,
      'agreement_preview': agreementPreviewAccepted ? '1' : '0',
      'privacy_policy': privacyPolicyAccepted ? '1' : '0',
    };
  }
}

/// Module-specific Request File for MITC Statutory Compliance
class MitcRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch User MITC Status & Profile: GET /api/client/mitc
  Future<ApiResponse<MitcModel>> getMitcProfile() async {
    final response = await _network.get<MitcModel>(
      '/api/client/mitc',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        return MitcModel.fromJson(data);
      },
    );
    return response;
  }

  /// Submit or Re-submit MITC Agreement: POST /api/client/submit-mitc
  Future<ApiResponse<MitcModel>> submitMitc(MitcSubmitParams params) async {
    final Map<String, dynamic> formMap = params.toFieldsMap();

    // Attach Specimen Signature file
    if (params.signatureFilePath != null && params.signatureFilePath!.isNotEmpty) {
      final file = File(params.signatureFilePath!);
      if (file.existsSync()) {
        formMap['signature'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    final response = await _network.postMultipart<MitcModel>(
      '/api/client/submit-mitc',
      formData: formData,
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        return MitcModel.fromJson(data);
      },
    );
    return response;
  }

  /// Fetch Default MITC Statutory Template: GET /api/client/mitc/template
  Future<ApiResponse<String>> getTemplate() async {
    final response = await _network.get<String>(
      '/api/client/mitc/template',
      fromJson: (json) {
        if (json is Map && json['template'] != null) {
          return json['template'].toString();
        }
        return json.toString();
      },
    );
    return response;
  }

  /// Request Agreement PDF Download Metadata: GET /api/client/mitc/download-agreement?json=1
  Future<ApiResponse<Map<String, dynamic>>> getAgreementDownloadInfo() async {
    final response = await _network.get<Map<String, dynamic>>(
      '/api/client/mitc/download-agreement?json=1',
      fromJson: (json) {
        if (json is Map) {
          return Map<String, dynamic>.from(json);
        }
        return <String, dynamic>{};
      },
    );
    return response;
  }
}
