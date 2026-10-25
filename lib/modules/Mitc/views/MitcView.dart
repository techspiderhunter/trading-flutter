import '../../../widgets/DeskUi.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../includes/Storage.dart';
import '../../../themes/AppColors.dart';
import '../../../models/MitcModel.dart';
import '../controllers/MitcController.dart';

class MitcView extends StatelessWidget {
  const MitcView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MitcController>()
        ? Get.find<MitcController>()
        : Get.put(MitcController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: DeskAppBar(
          group: 'MITC',
          onBack: () {
            if (controller.isEditing.value &&
                controller.mitcProfile.value != null) {
              controller.cancelEditing();
            } else {
              Get.back();
            }
          },
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.textSecondary, size: 22),
              tooltip: 'Refresh Status',
              onPressed: controller.loadMitcProfile,
            ),
            const SizedBox(width: 6),
          ]),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.primary),
            );
          }

          final profile = controller.mitcProfile.value;
          final status = controller.currentStatus.value.toLowerCase().trim();
          final isEditing = controller.isEditing.value;

          // 1. If user is in Form/Edit mode (new submission OR re-submitting after rejection)
          if (isEditing || status == 'not_submitted' || profile == null) {
            return _buildMitcForm(controller, context);
          }

          // 2. Direct Show Page when Verified / Approved
          if (status == 'verified' ||
              status == 'approved' ||
              profile.isVerified) {
            return _buildVerifiedShowPage(controller, profile, context);
          }

          // 3. Under Review / Pending State
          if (status == 'pending' ||
              status == 'under_review' ||
              profile.isPending) {
            return _buildPendingReviewPage(controller, profile, context);
          }

          // 4. Rejected / Action Required State
          if (status == 'rejected' ||
              status == 'declined' ||
              profile.isRejected) {
            return _buildRejectedPage(controller, profile, context);
          }

          // Fallback to Form
          return _buildMitcForm(controller, context);
        }),
      ),
    );
  }

  // =========================================================================
  // 1. VERIFIED SHOW PAGE (Direct view when MITC is verified & approved)
  // =========================================================================
  Widget _buildVerifiedShowPage(
      MitcController controller, MitcModel profile, BuildContext context) {
    final token = LocalStorage.getToken() ?? '';
    return DeskBody(children: [
      const DeskHero(title: 'MITC Agreement'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: profile.displayReferenceId,
          title: 'Verified',
          description: 'Your advisory agreement is active.',
          color: AppColors.success,
          icon: Icons.check_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Investor identity',
          icon: Icons.person_outline_rounded,
          children: [
            _buildInfoRow('Full Legal Name', profile.fullName),
            _buildInfoRow(
                'Father\'s Name', profile.fatherName ?? 'Not specified'),
            _buildInfoRow('Date of Birth', profile.dob ?? 'Not specified'),
            _buildInfoRow('Permanent Account (PAN)',
                profile.panNumber ?? 'Not specified'),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Contact information',
          icon: Icons.alternate_email_rounded,
          children: [
            _buildInfoRow('Mobile Number', profile.mobile),
            _buildInfoRow('Email Address', profile.email),
            _buildInfoRow(
                'Residential Address', profile.address ?? 'Not specified'),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Compliance details',
          icon: Icons.verified_user_outlined,
          children: [
            if (profile.verifiedAt != null)
              _buildInfoRow('Verified On', profile.verifiedAt!),
            _buildInfoRow('Compliance Standard', 'SEBI (RA) Regulations, 2014'),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Digital signature',
          icon: Icons.draw_outlined,
          children: [
            Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Image.network(
                  profile.secureSignatureUrl,
                  headers: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.draw_rounded,
                            color: Color(0xFF94A3B8), size: 20),
                        SizedBox(width: 8),
                        Flexible(
                            child: Text(
                          'Verified Digital Signature On File',
                          style: TextStyle(
                            fontFamily: 'DeskSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF65728B),
                          ),
                        )),
                      ],
                    );
                  },
                )),
          ]),
      const SizedBox(height: 24),
      Obx(() => DeskButton(
          label: controller.isDownloadingPdf.value
              ? (controller.downloadProgress.value > 0
                  ? '${(controller.downloadProgress.value * 100).toInt()}%...'
                  : 'Downloading...')
              : 'Download (PDF)',
          loading: controller.isDownloadingPdf.value,
          onPressed: controller.isDownloadingPdf.value
              ? null
              : () => controller.downloadAgreementPdf())),
    ]);
  }

  Widget _buildPendingReviewPage(
      MitcController controller, MitcModel profile, BuildContext context) {
    return DeskBody(children: [
      const DeskHero(title: 'MITC Agreement'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: profile.displayReferenceId,
          title: 'Under Review',
          description:
              'Your MITC agreement has been submitted to the compliance desk.',
          color: AppColors.warning,
          icon: Icons.schedule_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Applicant details',
          icon: Icons.person_outline_rounded,
          children: [
            _buildInfoRow('Full Legal Name', profile.fullName),
            _buildInfoRow('Mobile Number', profile.mobile),
            _buildInfoRow('Email Address', profile.email),
          ]),
      const SizedBox(height: 16),
      DeskButton(
          label: 'Preview Submitted Agreement',
          onPressed: () => controller.showAgreementPreview(context: context)),
    ]);
  }

  Widget _buildRejectedPage(
      MitcController controller, MitcModel profile, BuildContext context) {
    final reason = profile.rejectionReason != null &&
            profile.rejectionReason!.isNotEmpty
        ? profile.rejectionReason!
        : 'Specimen digital signature or investor details did not match regulatory standards.';
    return DeskBody(children: [
      const DeskHero(title: 'MITC Agreement'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: profile.displayReferenceId,
          title: 'Rejected',
          description: reason,
          color: AppColors.error,
          icon: Icons.priority_high_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Applicant details',
          icon: Icons.person_outline_rounded,
          children: [
            _buildInfoRow('Full Legal Name', profile.fullName),
            _buildInfoRow('Mobile Number', profile.mobile),
            _buildInfoRow('Email Address', profile.email),
          ]),
      const SizedBox(height: 16),
      DeskButton(
          label: 'Re-submit MITC Agreement',
          onPressed: controller.startResubmission),
    ]);
  }

  Widget _buildMitcForm(MitcController controller, BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, 22, 24, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DeskHero(
              title: 'Your advisory agreement.',
              subtitle: 'Most Important Terms & Conditions'),
          const SizedBox(height: 24),
          // Informational Header

          // Form Container
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildFieldLabel('Full Legal Name *'),
            _buildTextField(
                controller.fullNameController, 'Enter full name as per PAN'),
            const SizedBox(height: 14),
            _buildFieldLabel('Father\'s Name'),
            _buildTextField(
                controller.fatherNameController, 'Enter father\'s name'),
            const SizedBox(height: 14),
            _buildFieldLabel('Date of Birth (YYYY-MM-DD)'),
            _buildDobField(controller, context),
            const SizedBox(height: 14),
            _buildFieldLabel('Permanent Account (PAN) *'),
            _buildTextField(controller.panController, 'e.g. ABCDE1234F',
                isPan: true),
            const SizedBox(height: 14),
            _buildFieldLabel('Registered Mobile Number *'),
            _buildTextField(
                controller.mobileController, '10-digit mobile number',
                isPhone: true),
            const SizedBox(height: 14),
            _buildFieldLabel('Registered Email Address *'),
            _buildTextField(controller.emailController, 'name@example.com',
                isEmail: true),
            const SizedBox(height: 14),
            _buildFieldLabel('Full Residential Address *'),
            _buildTextField(
              controller.addressController,
              'Enter flat/house, street, city, state, pincode',
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _buildFieldLabel('Specimen Digital Signature *'),
            const SizedBox(height: 8),
            Obx(() {
              final path = controller.signaturePath.value;

              if (path != null && File(path).existsSync()) {
                return Container(
                  width: double.infinity,
                  height: 110,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(File(path), fit: BoxFit.contain),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => controller.signaturePath.value = null,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          controller.pickSignature(ImageSource.gallery),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Gallery',
                                style: TextStyle(
                                    fontFamily: 'DeskSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          controller.pickSignature(ImageSource.camera),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Camera',
                                style: TextStyle(
                                    fontFamily: 'DeskSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 18),
            Obx(() => InkWell(
                  onTap: () => controller.agreementPreviewAccepted.value =
                      !controller.agreementPreviewAccepted.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: controller.agreementPreviewAccepted.value,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => controller
                                .agreementPreviewAccepted.value = val ?? false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I have reviewed and accept the statutory MITC Agreement terms & conditions.',
                            style: TextStyle(
                                fontFamily: 'DeskSans',
                                fontSize: 12,
                                color: Color(0xFF334155),
                                height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            Obx(() => InkWell(
                  onTap: () => controller.privacyPolicyAccepted.value =
                      !controller.privacyPolicyAccepted.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: controller.privacyPolicyAccepted.value,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => controller
                                .privacyPolicyAccepted.value = val ?? false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I accept the Moneyara SEBI regulatory compliance policies & conditions.',
                            style: TextStyle(
                                fontFamily: 'DeskSans',
                                fontSize: 12,
                                color: Color(0xFF334155),
                                height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Obx(() {
              final isSubmitting = controller.isSubmitting.value;
              return DeskButton(
                  label: 'Submit MITC Agreement',
                  loading: isSubmitting,
                  onPressed: isSubmitting ? null : controller.submitAgreement);
            }),
            if (controller.mitcProfile.value != null) ...[
              const SizedBox(height: 20),
              DeskButton(
                  label: 'Cancel & Return to Status',
                  secondary: true,
                  onPressed: controller.cancelEditing),
            ],
          ]),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS & DIALOGS
  // =========================================================================
  Widget _buildFieldLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: deskText.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isPan = false,
    bool isPhone = false,
    bool isEmail = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: isPan
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
        keyboardType: isPhone
            ? TextInputType.phone
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: [
          if (isPhone) FilteringTextInputFormatter.digitsOnly,
          if (isPhone) LengthLimitingTextInputFormatter(10),
          if (isPan) LengthLimitingTextInputFormatter(10),
        ],
        style: const TextStyle(
            fontFamily: 'DeskSans', fontSize: 14, color: Color(0xFF192542)),
        decoration: deskInputDecoration(hintText: hint, suffixIcon: suffixIcon),
      ),
    );
  }

  Widget _buildDobField(MitcController controller, BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 20, now.month, now.day),
          firstDate: DateTime(1940),
          lastDate: DateTime(now.year - 18, now.month, now.day),
        );
        if (picked != null) {
          final m = picked.month.toString().padLeft(2, '0');
          final d = picked.day.toString().padLeft(2, '0');
          controller.dobController.text = '${picked.year}-$m-$d';
        }
      },
      child: IgnorePointer(
        child: _buildTextField(
          controller.dobController,
          'Select Date of Birth',
          suffixIcon: Icon(Icons.calendar_month_rounded,
              color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return ComplianceField(label, value);
  }

  void _downloadAgreementPdf(BuildContext context, MitcModel profile) {
    final controller = Get.isRegistered<MitcController>()
        ? Get.find<MitcController>()
        : Get.put(MitcController());
    controller.downloadAgreementPdf();
  }
}
