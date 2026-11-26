import 'dart:convert';
import '../global/requests/GlobalRequest.dart';
import '../includes/Storage.dart';

/// Complete MITC Profile & Verification Lifecycle Entity
/// Fully synchronized with Laravel ClientPortalController mitcProfile & submitMitc.
class MitcModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String fullName;
  final String? fatherName;
  final String? dob;
  final String mobile;
  final String email;
  final String? panNumber;
  final String? address;
  final String? signatureImage;
  final String? signatureUrl;
  final String? agreementDocument;
  final String? agreementUrl;
  final String? agreementPdfUrl;
  final String verificationStatus; // 'not_submitted', 'pending', 'verified', 'rejected'
  final String? verifiedAt;
  final String? rejectionReason;
  final String? referenceId;
  final String? createdAt;
  final String? template;
  final String? previewUrl;
  final String? downloadUrl;

  MitcModel({
    this.id,
    this.uuid,
    this.userId,
    required this.fullName,
    this.fatherName,
    this.dob,
    required this.mobile,
    required this.email,
    this.panNumber,
    this.address,
    this.signatureImage,
    this.signatureUrl,
    this.agreementDocument,
    this.agreementUrl,
    this.agreementPdfUrl,
    this.previewUrl,
    this.downloadUrl,
    this.verificationStatus = 'not_submitted',
    this.verifiedAt,
    this.rejectionReason,
    this.referenceId,
    this.createdAt,
    this.template,
  });

  bool get isVerified {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'verified' || s == 'approved';
  }

  bool get isPending {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'pending' || s == 'under_review' || s == 'submitted';
  }

  bool get isRejected {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'rejected' || s == 'declined' || s == 'action_required';
  }

  bool get isNotSubmitted {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'not_submitted' || s.isEmpty || id == null;
  }

  String get displayReferenceId {
    if (referenceId != null && referenceId!.isNotEmpty) {
      return referenceId!;
    }
    if (id != null && id! > 0) {
      return 'MV-MITC-${id.toString().padLeft(6, '0')}';
    }
    return 'MV-MITC-PENDING';
  }

  /// Robust URL normalizer resolving baseUrl, relative paths, localhost fallbacks & auth tokens
  static String _normalizeUrl(String? rawUrl, String defaultEndpointPath) {
    String base = GlobalRequest.currentBaseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    String url = (rawUrl ?? '').trim();
    if (url.isEmpty || url.toLowerCase() == 'null') {
      url = '$base$defaultEndpointPath';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final path = url.startsWith('/') ? url : '/$url';
      url = '$base$path';
    } else if (url.contains('127.0.0.1:8000') ||
        url.contains('localhost:8000') ||
        url.contains('10.0.2.2:8000')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final queryStr = uri.hasQuery ? '?${uri.query}' : '';
        url = '$base${uri.path}$queryStr';
      }
    }

    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty && !url.contains('token=')) {
      final sep = url.contains('?') ? '&' : '?';
      url = '$url${sep}token=$token';
    }
    return url;
  }

  String get secureSignatureUrl =>
      _normalizeUrl(signatureUrl, '/api/client/mitc/document/signature');

  String get secureDownloadUrl =>
      _normalizeUrl(downloadUrl, '/api/client/mitc/download-agreement?download=1');

  String get securePdfUrl =>
      _normalizeUrl(agreementPdfUrl ?? downloadUrl, '/api/client/mitc/download-agreement?download=1');

  String get securePreviewUrl =>
      _normalizeUrl(previewUrl, '/api/client/mitc/download-agreement?preview=1');

  factory MitcModel.fromJson(Map<String, dynamic> json) {
    // If backend returns outer wrapper with 'profile' key
    final profileData = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'])
        : json;

    final id = profileData['id'] != null
        ? int.tryParse(profileData['id'].toString())
        : null;

    final rawStatus = (profileData['verification_status'] ??
            json['verification_status'] ??
            (json['is_verified'] == true ? 'verified' : (json['is_pending'] == true ? 'pending' : (json['is_rejected'] == true ? 'rejected' : 'not_submitted'))))
        .toString()
        .toLowerCase();

    final ref = profileData['reference_id']?.toString() ??
        json['reference_id']?.toString() ??
        (id != null ? 'MV-MITC-${id.toString().padLeft(6, '0')}' : null);

    return MitcModel(
      id: id,
      uuid: profileData['uuid']?.toString(),
      userId: profileData['user_id'] != null
          ? int.tryParse(profileData['user_id'].toString())
          : null,
      fullName: profileData['full_name']?.toString() ??
          profileData['fullName']?.toString() ??
          profileData['name']?.toString() ??
          '',
      fatherName: profileData['father_name']?.toString() ??
          profileData['fatherName']?.toString(),
      dob: profileData['dob']?.toString() ??
          profileData['date_of_birth']?.toString(),
      mobile: profileData['mobile']?.toString() ??
          profileData['phone']?.toString() ??
          '',
      email: profileData['email']?.toString() ?? '',
      panNumber: profileData['pan_number']?.toString() ??
          profileData['pan']?.toString(),
      address: profileData['address']?.toString(),
      signatureImage: profileData['signature_image']?.toString(),
      signatureUrl: json['signature_url']?.toString() ??
          profileData['signature_url']?.toString(),
      agreementDocument: profileData['agreement_document']?.toString(),
      agreementUrl: json['agreement_url']?.toString(),
      agreementPdfUrl: json['agreement_pdf_url']?.toString(),
      previewUrl: json['preview_url']?.toString() ??
          json['signed_preview_url']?.toString() ??
          profileData['preview_url']?.toString() ??
          profileData['signed_preview_url']?.toString(),
      downloadUrl: json['download_url']?.toString() ??
          json['signed_download_url']?.toString() ??
          profileData['download_url']?.toString() ??
          profileData['signed_download_url']?.toString(),
      verificationStatus: rawStatus,
      verifiedAt: profileData['verified_at']?.toString(),
      rejectionReason: profileData['rejection_reason']?.toString(),
      referenceId: ref,
      createdAt: profileData['created_at']?.toString(),
      template: json['template']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'full_name': fullName,
      'father_name': fatherName,
      'dob': dob,
      'mobile': mobile,
      'email': email,
      'pan_number': panNumber,
      'address': address,
      'signature_image': signatureImage,
      'signature_url': signatureUrl,
      'preview_url': previewUrl,
      'download_url': downloadUrl,
      'agreement_document': agreementDocument,
      'agreement_url': agreementUrl,
      'agreement_pdf_url': agreementPdfUrl,
      'verification_status': verificationStatus,
      'verified_at': verifiedAt,
      'rejection_reason': rejectionReason,
      'reference_id': referenceId,
      'created_at': createdAt,
      'template': template,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory MitcModel.fromJsonString(String str) =>
      MitcModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
