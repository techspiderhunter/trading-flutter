import 'dart:convert';
import '../includes/Storage.dart';
import '../global/requests/GlobalRequest.dart';

/// Complete KYC Profile & Verification Lifecycle Entity
/// Fully synchronized with Laravel ClientPortalController formatKycStatusResponse.
class KycModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? panNumber;
  final String? aadhaarNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? fatherName;
  final String? motherName;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? occupation;
  final String? incomeRange;
  final String? experience;
  final bool? isPep;
  final String? panDocument;
  final String? panBackImage;
  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;
  final String verificationStatus; // 'not_submitted', 'pending', 'verified', 'rejected'
  final String? verifiedAt;
  final String? rejectionReason;
  final String? adminRemarks;

  // Rich lifecycle metadata returned by Laravel API
  final String? referenceId;
  final String? statusLabel;
  final String? statusSubtitle;
  final String? statusMessage;
  final int progressPercent;
  final bool isUnderReview;
  final bool canSubmit;
  final bool canResubmit;
  final Map<String, dynamic>? documents;
  final List<dynamic>? timeline;

  KycModel({
    this.id,
    this.uuid,
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.panNumber,
    this.aadhaarNumber,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.fatherName,
    this.motherName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.occupation,
    this.incomeRange,
    this.experience,
    this.isPep,
    this.panDocument,
    this.panBackImage,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.verificationStatus = 'not_submitted',
    this.verifiedAt,
    this.rejectionReason,
    this.adminRemarks,
    this.referenceId,
    this.statusLabel,
    this.statusSubtitle,
    this.statusMessage,
    this.progressPercent = 0,
    this.isUnderReview = false,
    this.canSubmit = true,
    this.canResubmit = false,
    this.documents,
    this.timeline,
  });

  bool get isVerified {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'verified';
  }

  bool get isPending {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'pending' ||
        s == 'under_review' ||
        s == 'in_review' ||
        s == 'processing' ||
        s == 'submitted' ||
        isUnderReview;
  }

  bool get isRejected {
    final s = verificationStatus.trim().toLowerCase();
    return s == 'rejected' || s == 'declined' || s == 'action_required';
  }

  bool get isNotSubmitted =>
      verificationStatus.isEmpty ||
      verificationStatus == 'not_submitted' ||
      (!isVerified && !isPending && !isRejected);

  String get displayReferenceId {
    if (referenceId != null && referenceId!.isNotEmpty) {
      return referenceId!;
    }
    if (id != null && id! > 0) {
      return 'MV-KYC-${id.toString().padLeft(6, '0')}';
    }
    return 'MV-KYC-PENDING';
  }

  String get statusDisplay {
    if (statusLabel != null && statusLabel!.isNotEmpty) {
      return statusLabel!;
    }
    if (isVerified) return 'Verified';
    if (isPending) return 'Under Review';
    if (isRejected) return 'Action Required';
    return 'Not Done';
  }

  String? get securePanDocumentUrl {
    if (documents != null && documents!['pan_document_url'] != null) {
      return documents!['pan_document_url'].toString();
    }
    final token = LocalStorage.getToken() ?? '';
    var base = GlobalRequest.currentBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base/api/client/kyc/document/pan?token=$token';
  }

  String? get securePanBackUrl {
    if (documents != null && documents!['pan_back_url'] != null) {
      return documents!['pan_back_url'].toString();
    }
    final token = LocalStorage.getToken() ?? '';
    var base = GlobalRequest.currentBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base/api/client/kyc/document/pan-back?token=$token';
  }

  String? get secureAadhaarFrontUrl {
    if (documents != null && documents!['aadhaar_front_url'] != null) {
      return documents!['aadhaar_front_url'].toString();
    }
    final token = LocalStorage.getToken() ?? '';
    var base = GlobalRequest.currentBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base/api/client/kyc/document/aadhaar-front?token=$token';
  }

  String? get secureAadhaarBackUrl {
    if (documents != null && documents!['aadhaar_back_url'] != null) {
      return documents!['aadhaar_back_url'].toString();
    }
    final token = LocalStorage.getToken() ?? '';
    var base = GlobalRequest.currentBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base/api/client/kyc/document/aadhaar-back?token=$token';
  }

  factory KycModel.fromJson(Map<String, dynamic> rawJson) {
    // Merge nested profile/kyc object with top-level lifecycle fields if present
    final Map<String, dynamic> json = rawJson['kyc'] is Map
        ? {
            ...Map<String, dynamic>.from(rawJson['kyc'] as Map),
            ...rawJson,
          }
        : (rawJson['profile'] is Map
            ? {
                ...Map<String, dynamic>.from(rawJson['profile'] as Map),
                ...rawJson,
              }
            : rawJson);

    String rawStatus = json['verification_status']?.toString() ?? 'not_submitted';
    rawStatus = rawStatus.trim().toLowerCase();
    if (rawStatus == 'active') {
      rawStatus = 'not_submitted';
    }

    // Check strict lifecycle flags
    if (json['has_kyc'] == false || json['is_not_submitted'] == true) {
      rawStatus = 'not_submitted';
    } else if (json['is_verified'] == true || json['is_approved'] == true) {
      rawStatus = 'verified';
    } else if (json['is_pending'] == true || json['is_under_review'] == true) {
      rawStatus = 'pending';
    } else if (json['is_rejected'] == true) {
      rawStatus = 'rejected';
    } else if (rawStatus == 'under_review' ||
        rawStatus == 'in_review' ||
        rawStatus == 'submitted' ||
        rawStatus == 'processing') {
      rawStatus = 'pending';
    } else if (rawStatus == 'declined' || rawStatus == 'action_required') {
      rawStatus = 'rejected';
    }

    final isReview = rawStatus == 'pending' ||
        rawStatus == 'under_review' ||
        json['is_under_review'] == true;

    final progress = json['progress_percent'] is int
        ? json['progress_percent'] as int
        : (json['progress_percentage'] is int
            ? json['progress_percentage'] as int
            : int.tryParse(json['progress_percent']?.toString() ?? '') ??
                (rawStatus == 'verified' ? 100 : (isReview ? 50 : 0)));

    return KycModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      panNumber: json['pan_number']?.toString() ?? json['pan']?.toString() ?? json['panNumber']?.toString(),
      aadhaarNumber: json['aadhaar_number']?.toString() ??
          json['aadhaar']?.toString() ??
          json['aadhaarNumber']?.toString(),
      dateOfBirth:
          json['date_of_birth']?.toString() ?? json['dob']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString() ??
          json['maritalStatus']?.toString(),
      fatherName: json['father_name']?.toString() ??
          json['fatherName']?.toString() ??
          json['fatherSpouseName']?.toString(),
      motherName: json['mother_name']?.toString() ??
          json['motherName']?.toString(),
      address: json['address']?.toString() ?? json['address1']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString() ?? json['pin_code']?.toString(),
      country: json['country']?.toString() ?? 'India',
      occupation: json['occupation']?.toString(),
      incomeRange: json['income_range']?.toString() ??
          json['incomeRange']?.toString(),
      experience: json['experience']?.toString(),
      isPep: json['is_pep'] == true || json['is_pep'] == 1,
      panDocument: json['pan_document']?.toString() ?? json['panDoc']?.toString(),
      panBackImage: json['pan_back_image']?.toString() ?? json['panBack']?.toString(),
      aadhaarFrontImage: json['aadhaar_front_image']?.toString() ??
          json['aadhaarFront']?.toString(),
      aadhaarBackImage: json['aadhaar_back_image']?.toString() ??
          json['aadhaarBack']?.toString(),
      verificationStatus: rawStatus,
      verifiedAt: json['verified_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      adminRemarks: json['admin_remarks']?.toString(),
      referenceId: json['reference_id']?.toString() ?? json['referenceId']?.toString(),
      statusLabel: json['status_label']?.toString() ?? json['status_title']?.toString(),
      statusSubtitle: json['status_subtitle']?.toString(),
      statusMessage: json['status_message']?.toString(),
      progressPercent: progress,
      isUnderReview: isReview,
      canSubmit: json['can_submit'] == true || rawStatus == 'not_submitted',
      canResubmit: json['can_resubmit'] == true || rawStatus == 'rejected',
      documents: json['documents'] is Map ? Map<String, dynamic>.from(json['documents'] as Map) : null,
      timeline: json['timeline'] is List ? json['timeline'] as List : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'pan_number': panNumber,
      'aadhaar_number': aadhaarNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'marital_status': maritalStatus,
      'father_name': fatherName,
      'mother_name': motherName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'occupation': occupation,
      'income_range': incomeRange,
      'experience': experience,
      'is_pep': isPep,
      'pan_document': panDocument,
      'pan_back_image': panBackImage,
      'aadhaar_front_image': aadhaarFrontImage,
      'aadhaar_back_image': aadhaarBackImage,
      'verification_status': verificationStatus,
      'verified_at': verifiedAt,
      'rejection_reason': rejectionReason,
      'admin_remarks': adminRemarks,
      'reference_id': referenceId,
      'status_label': statusLabel,
      'status_subtitle': statusSubtitle,
      'status_message': statusMessage,
      'progress_percent': progressPercent,
      'is_under_review': isUnderReview,
      'can_submit': canSubmit,
      'can_resubmit': canResubmit,
      'documents': documents,
      'timeline': timeline,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory KycModel.fromJsonString(String source) =>
      KycModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
