import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../includes/Storage.dart';
import '../../../global/Validator/Validators.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../Dashboard/routes/DashboardRoutes.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../MainNav/routes/MainNavRoutes.dart';
import '../../../themes/AppColors.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';
import '../models/KycParams.dart';
import '../requests/KycRequest.dart';

/// MVC Controller for Regulatory KYC Module
/// Manages 4-step wizard form, document selection (Camera & Gallery), field validation,
/// clearForm() lifecycle, and delegates API calls to KycRequest.
class KycController extends GetxController {
  final KycRequest _kycRequest = KycRequest();
  final ImagePicker _imagePicker = ImagePicker();

  // Stepper index (0: Personal, 1: IDs & Address, 2: Financial & Risk, 3: Documents & Declaration)
  final currentStep = 0.obs;

  // Personal Info Form
  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final fatherNameController = TextEditingController();
  final gender = Rx<String?>(null);
  final maritalStatus = Rx<String?>(null);

  // Regulatory IDs & Contact
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final panNumberController = TextEditingController();
  final aadhaarNumberController = TextEditingController();

  // Address
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Static options
  static const List<String> incomeOptions = [
    'Below 5 Lakhs',
    '5 - 10 Lakhs',
    'Above 10 Lakhs',
  ];

  static const List<String> occupationOptions = [
    'Professional / Salaried',
    'Self-Employed / Business',
    'Other',
  ];

  static const List<String> experienceOptions = [
    '< 1 Year (Beginner)',
    '1 - 3 Years',
    '3+ Years',
  ];

  static const List<String> riskOptions = [
    'Moderate',
    'Moderate - Aggressive',
    'Aggressive',
  ];

  // Financial & Risk Profiling
  final annualIncome = Rx<String?>(null);
  final occupation = Rx<String?>(null);
  final tradingExperience = Rx<String?>(null);
  final riskAppetite = Rx<String?>(null);

  // Documents
  final aadhaarFrontUploaded = false.obs;
  final aadhaarBackUploaded = false.obs;
  final panFrontUploaded = false.obs;
  final bankProofUploaded = false.obs;

  final aadhaarFrontFilePath = Rx<String?>(null);
  final aadhaarBackFilePath = Rx<String?>(null);
  final panFilePath = Rx<String?>(null);

  // Declarations
  final declareTrueInfo = false.obs;
  final declareSebiCompliance = false.obs;

  // Submission loading & existing KYC state
  final isSubmitting = false.obs;
  final isLoadingKyc = false.obs;
  final isEditing = false.obs;
  final hasExistingKyc = false.obs;
  final currentKycStatus = 'not_submitted'.obs;
  final currentKyc = Rx<KycModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _readCachedKyc();
    loadExistingKycOrPrefill();
  }

  void _readCachedKyc() {
    final cachedKycJson = LocalStorage.read(LocalStorage.kycDataKey);
    if (cachedKycJson != null && cachedKycJson.isNotEmpty) {
      try {
        final kyc = KycModel.fromJsonString(cachedKycJson);
        currentKyc.value = kyc;
        currentKycStatus.value =
            kyc.isVerified ? 'verified' : kyc.verificationStatus;
        hasExistingKyc.value = true;
        if (kyc.isPending || kyc.isVerified) {
          isEditing.value = false;
        } else if (kyc.isRejected) {
          isEditing.value = false;
          _prefillFromKyc(kyc);
        } else {
          isEditing.value = true;
        }
      } catch (_) {}
    } else {
      final submittedFlag =
          LocalStorage.read(MainNavController.kycSubmittedStorageKey);
      if (submittedFlag == 'true') {
        currentKycStatus.value = 'pending';
        isEditing.value = false;
      }
    }
  }

  void startResubmission() {
    if (currentKyc.value != null) {
      _prefillFromKyc(currentKyc.value!);
    }
    isEditing.value = true;
  }

  void cancelEditing() {
    if (currentKyc.value != null && !currentKyc.value!.isNotSubmitted) {
      isEditing.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    dobController.dispose();
    fatherNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    panNumberController.dispose();
    aadhaarNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }

  /// Completely clears all KYC input fields, documents, and selections
  void clearForm() {
    fullNameController.clear();
    dobController.clear();
    fatherNameController.clear();
    gender.value = null;
    maritalStatus.value = null;

    emailController.clear();
    phoneController.clear();
    panNumberController.clear();
    aadhaarNumberController.clear();

    addressController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();

    annualIncome.value = null;
    occupation.value = null;
    tradingExperience.value = null;
    riskAppetite.value = null;

    aadhaarFrontUploaded.value = false;
    aadhaarBackUploaded.value = false;
    panFrontUploaded.value = false;
    bankProofUploaded.value = false;

    aadhaarFrontFilePath.value = null;
    aadhaarBackFilePath.value = null;
    panFilePath.value = null;

    declareTrueInfo.value = false;
    declareSebiCompliance.value = false;

    currentStep.value = 0;
  }

  /// Load KYC state. If completed / under review, keep form clean!
  /// Only prefill if rejected so user can fix specific inputs.
  Future<void> loadExistingKycOrPrefill() async {
    // Only show full loader if we don't have any cached KYC profile yet
    if (currentKyc.value == null) {
      isLoadingKyc.value = true;
    }

    if (LocalStorage.hasToken()) {
      final response = await _kycRequest.getKyc();
      if (response.success && response.data != null) {
        final kyc = response.data!;
        currentKyc.value = kyc;
        currentKycStatus.value =
            kyc.isVerified ? 'verified' : kyc.verificationStatus;
        hasExistingKyc.value = true;

        // Persist fresh server state locally
        await LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        await LocalStorage.write(
          MainNavController.kycSubmittedStorageKey,
          (kyc.isPending || kyc.isVerified) ? 'true' : 'false',
        );

        // Sync with MainNav and Dashboard controllers
        if (Get.isRegistered<MainNavController>()) {
          final mainNav = Get.find<MainNavController>();
          mainNav.kycProfile.value = kyc;
          mainNav.kycStatus.value =
              kyc.isVerified ? 'verified' : kyc.verificationStatus;
          mainNav.isKycSubmitted.value = kyc.isPending || kyc.isVerified;
        }
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.kycProfile.value = kyc;
          dash.kycStatus.value =
              kyc.isVerified ? 'verified' : kyc.verificationStatus;
          dash.isKycSubmitted.value = kyc.isPending || kyc.isVerified;
          dash.referenceId.value = kyc.referenceId;
          dash.rejectionReason.value = kyc.rejectionReason;
        }

        // If Under Review or Verified: DO NOT show form! Show Show Page or Under Review page.
        if (kyc.isPending || kyc.isVerified) {
          isEditing.value = false;
          clearForm();
          isLoadingKyc.value = false;
          return;
        }

        // If Rejected: Show Rejected card with Re-submit button
        if (kyc.isRejected) {
          isEditing.value = false;
          _prefillFromKyc(kyc);
          isLoadingKyc.value = false;
          return;
        }
      }
    }

    // Default / Not Submitted: Clear form and show 4-step wizard prefilled with account info
    isEditing.value = true;
    clearForm();
    _prefillBasicUser();
    isLoadingKyc.value = false;
  }

  void _prefillBasicUser() {
    final cachedUserJson = LocalStorage.read(LocalStorage.userProfileKey);
    if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
      try {
        final user = UserModel.fromJsonString(cachedUserJson);
        if (fullNameController.text.isEmpty)
          fullNameController.text = user.name;
        if (emailController.text.isEmpty) emailController.text = user.email;
        if (phoneController.text.isEmpty) phoneController.text = user.phone;
      } catch (_) {}
    }
  }

  void _prefillFromKyc(KycModel kyc) {
    if (kyc.fullName != null && kyc.fullName!.isNotEmpty) {
      fullNameController.text = kyc.fullName!;
    }
    if (kyc.fatherName != null) fatherNameController.text = kyc.fatherName!;
    if (kyc.dateOfBirth != null) {
      dobController.text = formatDobIso(kyc.dateOfBirth!);
    }
    if (kyc.gender != null) gender.value = kyc.gender;
    if (kyc.maritalStatus != null) maritalStatus.value = kyc.maritalStatus;

    if (kyc.email != null) emailController.text = kyc.email!;
    if (kyc.phone != null) phoneController.text = kyc.phone!;
    if (kyc.panNumber != null) panNumberController.text = kyc.panNumber!;
    if (kyc.aadhaarNumber != null)
      aadhaarNumberController.text = kyc.aadhaarNumber!;

    if (kyc.address != null) addressController.text = kyc.address!;
    if (kyc.city != null) cityController.text = kyc.city!;
    if (kyc.state != null) stateController.text = kyc.state!;
    if (kyc.pincode != null) pincodeController.text = kyc.pincode!;

    if (kyc.incomeRange != null) annualIncome.value = kyc.incomeRange;
    if (kyc.occupation != null) occupation.value = kyc.occupation;
    if (kyc.experience != null) tradingExperience.value = kyc.experience;

    if (kyc.panDocument != null) panFrontUploaded.value = true;
    if (kyc.aadhaarFrontImage != null) aadhaarFrontUploaded.value = true;
    if (kyc.aadhaarBackImage != null) aadhaarBackUploaded.value = true;
  }

  // =========================================================
  // DATE OF BIRTH & DATE PICKER HELPERS
  // =========================================================

  /// Format DOB string into strict ISO YYYY-MM-DD
  String formatDobIso(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    try {
      if (trimmed.contains('/')) {
        final parts = trimmed.split('/');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY/MM/DD
            return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
          } else {
            // DD/MM/YYYY
            return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          }
        }
      } else if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
          } else {
            // DD-MM-YYYY
            return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          }
        }
      }
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return trimmed;
  }

  /// Interactive Date Picker for Date of Birth (Ensures 18+ statutory compliance)
  Future<void> pickDob(BuildContext context) async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    final currentText = dobController.text.trim();
    if (currentText.isNotEmpty) {
      try {
        final iso = formatDobIso(currentText);
        final parsed = DateTime.tryParse(iso);
        if (parsed != null) initial = parsed;
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Select Date of Birth (18+ Required)',
      confirmText: 'CONFIRM',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      dobController.text = formatted;
    }
  }

  // =========================================================
  // STEP VALIDATIONS USING GLOBAL VALIDATORS
  // =========================================================

  bool validateStep0() {
    final nameErr = Validators.name(fullNameController.text, 'Full legal name');
    if (nameErr != null) {
      _showErrorSnackbar('Personal Details', nameErr);
      return false;
    }

    final dobErr = Validators.dob(dobController.text);
    if (dobErr != null) {
      _showErrorSnackbar('Personal Details', dobErr);
      return false;
    }

    final fatherErr =
        Validators.name(fatherNameController.text, "Father's name");
    if (fatherErr != null) {
      _showErrorSnackbar('Personal Details', fatherErr);
      return false;
    }

    if (gender.value == null || gender.value!.isEmpty) {
      _showErrorSnackbar('Personal Details', 'Please select your gender');
      return false;
    }

    if (maritalStatus.value == null || maritalStatus.value!.isEmpty) {
      _showErrorSnackbar(
          'Personal Details', 'Please select your marital status');
      return false;
    }

    return true;
  }

  bool validateStep1() {
    final emailErr = Validators.email(emailController.text);
    if (emailErr != null) {
      _showErrorSnackbar('Contact & IDs', emailErr);
      return false;
    }

    final phoneErr = Validators.phone(phoneController.text);
    if (phoneErr != null) {
      _showErrorSnackbar('Contact & IDs', phoneErr);
      return false;
    }

    final panErr = Validators.pan(panNumberController.text);
    if (panErr != null) {
      _showErrorSnackbar('Regulatory IDs', panErr);
      return false;
    }

    final aadhaarErr = Validators.aadhaar(aadhaarNumberController.text);
    if (aadhaarErr != null) {
      _showErrorSnackbar('Regulatory IDs', aadhaarErr);
      return false;
    }

    final addrErr = Validators.address(addressController.text);
    if (addrErr != null) {
      _showErrorSnackbar('Address Details', addrErr);
      return false;
    }

    final cityErr = Validators.city(cityController.text);
    if (cityErr != null) {
      _showErrorSnackbar('Address Details', cityErr);
      return false;
    }

    final stateErr = Validators.state(stateController.text);
    if (stateErr != null) {
      _showErrorSnackbar('Address Details', stateErr);
      return false;
    }

    final pinErr = Validators.pincode(pincodeController.text);
    if (pinErr != null) {
      _showErrorSnackbar('Address Details', pinErr);
      return false;
    }

    return true;
  }

  bool validateStep2() {
    if (annualIncome.value == null || annualIncome.value!.isEmpty) {
      _showErrorSnackbar(
          'Financial Profile', 'Please select your annual gross income');
      return false;
    }

    if (occupation.value == null || occupation.value!.isEmpty) {
      _showErrorSnackbar(
          'Financial Profile', 'Please select your primary occupation');
      return false;
    }

    if (tradingExperience.value == null || tradingExperience.value!.isEmpty) {
      _showErrorSnackbar(
          'Risk Profiling', 'Please select your trading experience level');
      return false;
    }

    return true;
  }

  bool validateStep3() {
    if (!panFrontUploaded.value &&
        (panFilePath.value == null || panFilePath.value!.isEmpty)) {
      _showErrorSnackbar(
          'Documents Required', 'Please attach a clear photo of your PAN card');
      return false;
    }

    if (!aadhaarFrontUploaded.value &&
        (aadhaarFrontFilePath.value == null ||
            aadhaarFrontFilePath.value!.isEmpty)) {
      _showErrorSnackbar(
          'Documents Required', 'Please attach Aadhaar front document');
      return false;
    }

    if (!declareTrueInfo.value) {
      _showErrorSnackbar('Declaration Required',
          'Please acknowledge the accuracy of provided information');
      return false;
    }

    if (!declareSebiCompliance.value) {
      _showErrorSnackbar('Declaration Required',
          'Please accept statutory SEBI advisory compliance terms');
      return false;
    }

    return true;
  }

  void nextStep() {
    bool canProceed = false;
    switch (currentStep.value) {
      case 0:
        canProceed = validateStep0();
        break;
      case 1:
        canProceed = validateStep1();
        break;
      case 2:
        canProceed = validateStep2();
        break;
      default:
        canProceed = true;
    }

    if (canProceed && currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      // Validate up to the targeted step
      if (step > currentStep.value) {
        if (currentStep.value == 0 && !validateStep0()) return;
        if (currentStep.value == 1 && !validateStep1()) return;
        if (currentStep.value == 2 && !validateStep2()) return;
      }
      currentStep.value = step;
    }
  }

  // =========================================================
  // DOCUMENT PICKERS (100% Crash-Proof: Camera & Gallery)
  // =========================================================

  Future<void> pickPanDocument() async {
    await _showDocumentSourceSheet(
      documentTitle: 'PAN Card',
      onSelected: (path, name) {
        panFilePath.value = path;
        panFrontUploaded.value = true;
      },
    );
  }

  Future<void> pickAadhaarFrontDocument() async {
    await _showDocumentSourceSheet(
      documentTitle: 'Aadhaar Card (Front)',
      onSelected: (path, name) {
        aadhaarFrontFilePath.value = path;
        aadhaarFrontUploaded.value = true;
      },
    );
  }

  Future<void> pickAadhaarBackDocument() async {
    await _showDocumentSourceSheet(
      documentTitle: 'Aadhaar Card (Back)',
      onSelected: (path, name) {
        aadhaarBackFilePath.value = path;
        aadhaarBackUploaded.value = true;
      },
    );
  }

  Future<void> _showDocumentSourceSheet({
    required String documentTitle,
    required Function(String path, String fileName) onSelected,
  }) async {
    Get.bottomSheet(
      DeskSheetContent(
          title: 'Attach $documentTitle',
          subtitle: 'Select source to capture or select document.',
          children: [
            DeskRow(
                title: 'Take Photo',
                subtitle: 'Camera',
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(
                    source: ImageSource.camera,
                    title: documentTitle,
                    onSelected: onSelected,
                  );
                }),
            const SizedBox(height: 15),
            DeskRow(
                title: 'Choose from Gallery',
                subtitle: 'Device images',
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(
                    source: ImageSource.gallery,
                    title: documentTitle,
                    onSelected: onSelected,
                  );
                })
          ]),
    );
  }

  Future<void> _pickImageFromSource({
    required ImageSource source,
    required String title,
    required Function(String path, String fileName) onSelected,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null) {
        final fileName = image.name.isNotEmpty
            ? image.name
            : '${title.replaceAll(' ', '_')}.jpg';
        onSelected(image.path, fileName);
        _showSuccessSnackbar('$title Attached', 'File ready for verification.');
      }
    } catch (e) {
      _showErrorSnackbar(
        'Attachment Error',
        'Could not attach document: $e',
      );
    }
  }

  // =========================================================
  // SUBMIT KYC VIA KYCREQUEST
  // =========================================================
  Future<void> submitKyc() async {
    // Validate all steps strictly
    if (!validateStep0()) {
      goToStep(0);
      return;
    }
    if (!validateStep1()) {
      goToStep(1);
      return;
    }
    if (!validateStep2()) {
      goToStep(2);
      return;
    }
    if (!validateStep3()) {
      goToStep(3);
      return;
    }

    isSubmitting.value = true;

    final params = SubmitKycParams(
      fullName: fullNameController.text.trim(),
      fatherName: fatherNameController.text.trim(),
      dob: formatDobIso(dobController.text.trim()),
      gender: gender.value ?? 'Male',
      maritalStatus: maritalStatus.value ?? 'Single',
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      pan: panNumberController.text.trim().toUpperCase(),
      aadhaar: aadhaarNumberController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      pincode: pincodeController.text.trim(),
      occupation: occupation.value ?? 'Salaried',
      incomeRange: annualIncome.value ?? 'Below 5 Lakhs',
      experience: tradingExperience.value ?? '< 1 Year (Beginner)',
      isPep: 0,
      panFilePath: panFilePath.value,
      aadhaarFrontFilePath: aadhaarFrontFilePath.value,
      aadhaarBackFilePath: aadhaarBackFilePath.value,
      isUpdate: hasExistingKyc.value,
    );

    final response = await _kycRequest.submitKyc(params);
    isSubmitting.value = false;

    if (response.success && response.data != null) {
      final kycData = response.data!;
      hasExistingKyc.value = true;
      currentKyc.value = kycData;
      currentKycStatus.value = kycData.verificationStatus;

      // CLEAR FORM IMMEDIATELY AS REQUESTED:
      clearForm();
      isEditing.value = false;

      // Persist KYC submission status & full KYC profile
      await LocalStorage.write(
          MainNavController.kycSubmittedStorageKey, 'true');
      await LocalStorage.write(LocalStorage.kycDataKey, kycData.toJsonString());

      // Update global state in MainNavController
      if (Get.isRegistered<MainNavController>()) {
        final mainNav = Get.find<MainNavController>();
        mainNav.currentIndex.value = 0; // Strictly ensure Dashboard tab
        mainNav.isKycSubmitted.value = true;
        mainNav.kycStatus.value = kycData.verificationStatus;
        mainNav.kycProfile.value = kycData;
        await mainNav.completeKycSubmission();
      }

      // Update DashboardController directly for instantaneous UI update without pull-to-refresh
      if (Get.isRegistered<DashboardController>()) {
        final dash = Get.find<DashboardController>();
        dash.kycProfile.value = kycData;
        dash.kycStatus.value = kycData.verificationStatus;
        dash.isKycSubmitted.value = true;
        dash.referenceId.value = kycData.referenceId;
        dash.rejectionReason.value = kycData.rejectionReason;
      }

      // Directly redirect to Dashboard as requested
      Get.offAllNamed(DashboardRoutes.dashboard);

      Get.snackbar(
        'KYC Submitted Successfully!',
        'Your regulatory documents are now under compliance review.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.primaryDark,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: Icon(Icons.check_circle_rounded, color: AppColors.primary),
        duration: const Duration(seconds: 4),
      );
    } else {
      _showErrorSnackbar('Submission Failed', response.firstErrorMessage);
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFEE2E2),
      colorText: const Color(0xFF991B1B),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.primaryDark,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.check_circle_rounded, color: AppColors.primary),
      duration: const Duration(seconds: 2),
    );
  }
}
