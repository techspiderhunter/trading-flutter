import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../includes/Storage.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';
import '../../../models/MitcModel.dart';
import '../../../themes/AppColors.dart';
import '../requests/MitcRequest.dart';
import '../views/widgets/MitcAgreementPreviewModal.dart';

class MitcController extends GetxController {
  final MitcRequest _mitcRequest = MitcRequest();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isEditing = false.obs;
  final isDownloadingPdf = false.obs;
  final downloadProgress = 0.0.obs;

  final mitcProfile = Rx<MitcModel?>(null);
  final currentStatus = 'not_submitted'.obs; // 'not_submitted', 'pending', 'verified', 'rejected'
  final referenceId = Rx<String?>(null);
  final rejectionReason = Rx<String?>(null);
  final templateText = ''.obs;

  // Form Fields
  final fullNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final panController = TextEditingController();
  final addressController = TextEditingController();

  final signaturePath = Rx<String?>(null);
  final agreementPreviewAccepted = true.obs;
  final privacyPolicyAccepted = true.obs;

  @override
  void onInit() {
    super.onInit();
    _readCachedMitc();
    loadMitcProfile();
  }

  void _readCachedMitc() {
    final cachedMitcJson = LocalStorage.read(LocalStorage.mitcDataKey);
    if (cachedMitcJson != null && cachedMitcJson.isNotEmpty) {
      try {
        final profile = MitcModel.fromJsonString(cachedMitcJson);
        mitcProfile.value = profile;
        currentStatus.value = profile.verificationStatus;
        referenceId.value = profile.displayReferenceId;
        rejectionReason.value = profile.rejectionReason;
        if (profile.template != null && profile.template!.isNotEmpty) {
          templateText.value = profile.template!;
        }
        _prefillFromMitc(profile);

        if (profile.isVerified || profile.isPending) {
          isEditing.value = false;
        } else if (profile.isRejected) {
          isEditing.value = false;
        } else {
          isEditing.value = true;
        }
      } catch (_) {}
    }
  }

  Future<void> loadMitcProfile() async {
    if (!LocalStorage.hasToken()) return;

    try {
      if (mitcProfile.value == null) {
        isLoading.value = true;
      }
      final res = await _mitcRequest.getMitcProfile();

      if (res.success && res.data != null) {
        final profile = res.data!;
        mitcProfile.value = profile;
        currentStatus.value = profile.verificationStatus;
        referenceId.value = profile.displayReferenceId;
        rejectionReason.value = profile.rejectionReason;
        if (profile.template != null && profile.template!.isNotEmpty) {
          templateText.value = profile.template!;
        }

        // Cache fresh MITC
        await LocalStorage.write(LocalStorage.mitcDataKey, profile.toJsonString());

        // Prefill form values in case of re-submission
        _prefillFromMitc(profile);

        if (profile.isVerified || profile.isPending) {
          isEditing.value = false;
        } else if (profile.isRejected) {
          isEditing.value = false; // Show rejected card first with 'Re-submit' CTA
        } else {
          isEditing.value = true;
        }
      } else {
        // No MITC created yet -> prefill from User & KYC
        currentStatus.value = 'not_submitted';
        isEditing.value = true;
        _prefillFromUserAndKyc();
      }
    } catch (_) {
      if (mitcProfile.value == null) {
        currentStatus.value = 'not_submitted';
        isEditing.value = true;
        _prefillFromUserAndKyc();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _prefillFromMitc(MitcModel profile) {
    if (fullNameController.text.isEmpty && profile.fullName.isNotEmpty) {
      fullNameController.text = profile.fullName;
    }
    if (fatherNameController.text.isEmpty && profile.fatherName != null) {
      fatherNameController.text = profile.fatherName!;
    }
    if (dobController.text.isEmpty && profile.dob != null) {
      dobController.text = profile.dob!;
    }
    if (mobileController.text.isEmpty && profile.mobile.isNotEmpty) {
      mobileController.text = profile.mobile;
    }
    if (emailController.text.isEmpty && profile.email.isNotEmpty) {
      emailController.text = profile.email;
    }
    if (panController.text.isEmpty && profile.panNumber != null) {
      panController.text = profile.panNumber!;
    }
    if (addressController.text.isEmpty && profile.address != null) {
      addressController.text = profile.address!;
    }
  }

  void _prefillFromUserAndKyc() {
    // 1. From UserModel
    final userJson = LocalStorage.read(LocalStorage.userProfileKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final user = UserModel.fromJsonString(userJson);
        if (fullNameController.text.isEmpty && user.name.isNotEmpty) {
          fullNameController.text = user.name;
        }
        if (emailController.text.isEmpty && user.email.isNotEmpty) {
          emailController.text = user.email;
        }
        if (mobileController.text.isEmpty && user.phone.isNotEmpty) {
          mobileController.text = user.phone;
        }
      } catch (_) {}
    }

    // 2. From KycModel
    final kycJson = LocalStorage.read(LocalStorage.kycDataKey);
    if (kycJson != null && kycJson.isNotEmpty) {
      try {
        final kyc = KycModel.fromJsonString(kycJson);
        if (fullNameController.text.isEmpty && kyc.fullName != null) {
          fullNameController.text = kyc.fullName!;
        }
        if (fatherNameController.text.isEmpty && kyc.fatherName != null) {
          fatherNameController.text = kyc.fatherName!;
        }
        if (dobController.text.isEmpty && kyc.dateOfBirth != null) {
          dobController.text = kyc.dateOfBirth!;
        }
        if (panController.text.isEmpty && kyc.panNumber != null) {
          panController.text = kyc.panNumber!;
        }
        if (addressController.text.isEmpty && kyc.address != null) {
          addressController.text = kyc.address!;
        }
      } catch (_) {}
    }
  }

  Future<void> pickSignature(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file != null) {
        signaturePath.value = file.path;
      }
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Could not access image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    }
  }

  void startResubmission() {
    isEditing.value = true;
  }

  void cancelEditing() {
    if (mitcProfile.value != null && mitcProfile.value!.id != null) {
      isEditing.value = false;
    }
  }

  Future<void> submitAgreement() async {
    final name = fullNameController.text.trim();
    final fatherName = fatherNameController.text.trim();
    final dob = dobController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final pan = panController.text.trim().toUpperCase();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      _showError('Full Name Required', 'Please enter your full legal name as per PAN card.');
      return;
    }
    if (mobile.isEmpty) {
      _showError('Mobile Required', 'Please enter your active registered mobile number.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Valid Email Required', 'Please enter a valid registered email address.');
      return;
    }
    if (pan.length != 10) {
      _showError('Valid PAN Required', 'Please enter a valid 10-character PAN card number.');
      return;
    }
    if (address.isEmpty) {
      _showError('Address Required', 'Please enter your full residential address.');
      return;
    }

    final hasExistingSignature = mitcProfile.value?.signatureImage != null &&
        mitcProfile.value!.signatureImage!.isNotEmpty;
    if (signaturePath.value == null && !hasExistingSignature) {
      _showError('Signature Required', 'Please upload your specimen digital signature.');
      return;
    }

    if (!agreementPreviewAccepted.value || !privacyPolicyAccepted.value) {
      _showError('Acceptance Required', 'Please confirm and accept the Agreement preview & statutory conditions.');
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _mitcRequest.submitMitc(
        MitcSubmitParams(
          fullName: name,
          fatherName: fatherName.isNotEmpty ? fatherName : null,
          dob: dob.isNotEmpty ? dob : null,
          mobile: mobile,
          email: email,
          panNumber: pan,
          address: address,
          signatureFilePath: signaturePath.value,
          agreementPreviewAccepted: true,
          privacyPolicyAccepted: true,
        ),
      );

      if (res.success && res.data != null) {
        mitcProfile.value = res.data!;
        currentStatus.value = 'pending';
        referenceId.value = res.data!.displayReferenceId;
        isEditing.value = false;
        await LocalStorage.write(LocalStorage.mitcDataKey, res.data!.toJsonString());

        Get.snackbar(
          'MITC Agreement Submitted!',
          'Your compliance agreement has been submitted and is now under audit by Moneyara Compliance.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successBg,
          colorText: AppColors.primaryDark,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        );
      } else {
        _showError('Submission Failed', res.firstErrorMessage);
      }
    } catch (e) {
      _showError('Submission Error', 'Failed to submit agreement: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Download / Open official MITC Agreement PDF via native Download Manager / PDF Viewer
  Future<void> downloadAgreementPdf() async {
    final profile = mitcProfile.value;
    if (profile == null) {
      _showError('Agreement Not Found', 'Please complete your MITC agreement first.');
      return;
    }

    try {
      isDownloadingPdf.value = true;
      downloadProgress.value = 0.0;

      // 1. Fetch fresh signed download URL from backend API
      String? targetUrl;
      try {
        final res = await _mitcRequest.getAgreementDownloadInfo();
        targetUrl = res.data?['download_url']?.toString() ??
            res.data?['signed_download_url']?.toString();
      } catch (_) {}

      // Fallback to normalized profile download url
      if (targetUrl == null || targetUrl.isEmpty) {
        targetUrl = profile.secureDownloadUrl.isNotEmpty
            ? profile.secureDownloadUrl
            : profile.securePdfUrl;
      }

      if (targetUrl.isEmpty) {
        _showError('Unavailable', 'Download link is currently unavailable.');
        return;
      }

      // 2. Always copy link to clipboard for user convenience
      await Clipboard.setData(ClipboardData(text: targetUrl));

      // 3. Delegate to Android / iOS native download manager & browser (which downloads the complete PDF)
      final uri = Uri.parse(targetUrl);
      bool launched = false;

      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      Get.snackbar(
        'Downloading Agreement PDF',
        'Opening in download manager / PDF viewer...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 28),
      );
    } catch (e) {
      final fallbackUrl = profile.secureDownloadUrl.isNotEmpty
          ? profile.secureDownloadUrl
          : profile.securePdfUrl;
      Clipboard.setData(ClipboardData(text: fallbackUrl));
      Get.snackbar(
        'Download Link Copied',
        'Direct link copied to clipboard. Open in browser to download your agreement.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.link_rounded, color: AppColors.primary),
      );
    } finally {
      isDownloadingPdf.value = false;
      downloadProgress.value = 0.0;
    }
  }

  /// Open in-app agreement preview modal with the official A4 UI layout
  Future<void> showAgreementPreview({
    BuildContext? context,
    String? previewUrlOverride,
  }) async {
    final profile = mitcProfile.value;
    if (profile == null) {
      _showError('Agreement Not Found', 'Please complete your MITC agreement first.');
      return;
    }

    String? targetPreviewUrl = previewUrlOverride ?? profile.previewUrl;

    if (targetPreviewUrl == null || targetPreviewUrl.isEmpty) {
      try {
        final res = await _mitcRequest.getAgreementDownloadInfo();
        targetPreviewUrl = res.data?['preview_url']?.toString() ??
            res.data?['signed_preview_url']?.toString();
      } catch (_) {}
    }

    targetPreviewUrl ??= profile.securePreviewUrl;

    // Ensure preview=1 parameter is present to render the full A4 agreement UI
    if (!targetPreviewUrl.contains('preview=')) {
      final sep = targetPreviewUrl.contains('?') ? '&' : '?';
      targetPreviewUrl = '$targetPreviewUrl${sep}preview=1';
    }

    if (context != null && !context.mounted) return;
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    MitcAgreementPreviewModal.show(
      ctx,
      previewUrl: targetPreviewUrl,
      onDownload: () => downloadAgreementPdf(),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorBg,
      colorText: AppColors.error,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.error),
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    fatherNameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    emailController.dispose();
    panController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
