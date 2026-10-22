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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (controller.isEditing.value && controller.mitcProfile.value != null) {
              controller.cancelEditing();
            } else {
              Get.back();
            }
          },
        ),
        title: const Text(
          'MITC Agreement',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
            tooltip: 'Refresh Status',
            onPressed: controller.loadMitcProfile,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
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
          if (status == 'verified' || status == 'approved' || profile.isVerified) {
            return _buildVerifiedShowPage(controller, profile, context);
          }

          // 3. Under Review / Pending State
          if (status == 'pending' || status == 'under_review' || profile.isPending) {
            return _buildPendingReviewPage(controller, profile, context);
          }

          // 4. Rejected / Action Required State
          if (status == 'rejected' || status == 'declined' || profile.isRejected) {
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verified Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MITC Agreement Verified',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ref: ${profile.displayReferenceId}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action Buttons: Download & Preview Agreement
          Row(
            children: [
              // Download Button
              Expanded(
                flex: 6,
                child: Obx(() {
                  final isDownloading = controller.isDownloadingPdf.value;
                  final progress = controller.downloadProgress.value;

                  return SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: isDownloading
                          ? null
                          : () => controller.downloadAgreementPdf(),
                      icon: isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.download_rounded,
                              size: 19, color: Colors.white),
                      label: Text(
                        isDownloading
                            ? (progress > 0
                                ? '${(progress * 100).toInt()}%...'
                                : 'Downloading...')
                            : 'Download (PDF)',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        disabledBackgroundColor: const Color(0xFF6EE7B7),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detailed Verified Information Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Statutory Compliance Records',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                _buildInfoRow('Full Legal Name', profile.fullName),
                _buildInfoRow('Father\'s Name', profile.fatherName ?? 'Not specified'),
                _buildInfoRow('Date of Birth', profile.dob ?? 'Not specified'),
                _buildInfoRow('Permanent Account (PAN)', profile.panNumber ?? 'Not specified'),
                _buildInfoRow('Mobile Number', profile.mobile),
                _buildInfoRow('Email Address', profile.email),
                _buildInfoRow('Residential Address', profile.address ?? 'Not specified'),
                if (profile.verifiedAt != null)
                  _buildInfoRow('Verified On', profile.verifiedAt!),
                _buildInfoRow('Compliance Standard', 'SEBI (RA) Regulations, 2014'),

                const SizedBox(height: 18),
                const Text(
                  'Digital Specimen Signature',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 90,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Center(
                    child: Image.network(
                      profile.secureSignatureUrl,
                      headers: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.draw_rounded, color: Color(0xFF94A3B8), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Verified Digital Signature On File',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // SEBI Statutory Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This Most Important Terms & Conditions (MITC) agreement is legally binding under SEBI Master Circular guidelines. A copy has been digitally preserved on our compliance archive.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. UNDER REVIEW / PENDING STATE
  // =========================================================================
  Widget _buildPendingReviewPage(
      MitcController controller, MitcModel profile, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'MITC Under Review',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Most Important Terms and Conditions (MITC) compliance agreement has been successfully submitted and is under audit by Moneyara Compliance Desk.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Reference ID Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reference ID: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    profile.displayReferenceId,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Actions: Preview Agreement Draft
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () =>
                    controller.showAgreementPreview(context: context),
                icon: const Icon(Icons.visibility_outlined,
                    size: 19, color: Color(0xFFD97706)),
                label: const Text(
                  'Preview Submitted Agreement',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCD34D), width: 1.4),
                  backgroundColor: const Color(0xFFFFFBEB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. REJECTED / ACTION REQUIRED STATE
  // =========================================================================
  Widget _buildRejectedPage(
      MitcController controller, MitcModel profile, BuildContext context) {
    final reason = profile.rejectionReason != null && profile.rejectionReason!.isNotEmpty
        ? profile.rejectionReason!
        : 'Specimen digital signature or investor details did not match regulatory standards.';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFFEF4444),
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'MITC Agreement Rejected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compliance Desk Reason:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F1D1D),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please update your details or re-upload a clear specimen signature to complete statutory compliance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 24),

                // Re-submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: controller.startResubmission,
                    icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                    label: const Text(
                      'Re-submit MITC Agreement',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. MITC SUBMISSION FORM (For new users OR re-submitting after rejection)
  // =========================================================================
  Widget _buildMitcForm(MitcController controller, BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informational Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.balance_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEBI Statutory MITC Form',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mandatory terms & conditions agreement for research advisory clients.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF3B82F6), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Form Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Full Legal Name *'),
                _buildTextField(controller.fullNameController, 'Enter full name as per PAN'),
                const SizedBox(height: 14),

                _buildFieldLabel('Father\'s Name'),
                _buildTextField(controller.fatherNameController, 'Enter father\'s name'),
                const SizedBox(height: 14),

                _buildFieldLabel('Date of Birth (YYYY-MM-DD)'),
                _buildDobField(controller, context),
                const SizedBox(height: 14),

                _buildFieldLabel('Permanent Account (PAN) *'),
                _buildTextField(controller.panController, 'e.g. ABCDE1234F', isPan: true),
                const SizedBox(height: 14),

                _buildFieldLabel('Registered Mobile Number *'),
                _buildTextField(controller.mobileController, '10-digit mobile number', isPhone: true),
                const SizedBox(height: 14),

                _buildFieldLabel('Registered Email Address *'),
                _buildTextField(controller.emailController, 'name@example.com', isEmail: true),
                const SizedBox(height: 14),

                _buildFieldLabel('Full Residential Address *'),
                _buildTextField(
                  controller.addressController,
                  'Enter flat/house, street, city, state, pincode',
                  maxLines: 3,
                ),
                const SizedBox(height: 18),

                // Signature Upload Section
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
                        color: const Color(0xFFF8FAFC),
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
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
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
                          onPressed: () => controller.pickSignature(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 18),
                                SizedBox(width: 6),
                                Text('Gallery', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.pickSignature(ImageSource.camera),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 18),
                                SizedBox(width: 6),
                                Text('Camera', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 18),

                // Consent Checkboxes (Responsive custom layout)
                Obx(() => InkWell(
                  onTap: () => controller.agreementPreviewAccepted.value = !controller.agreementPreviewAccepted.value,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => controller.agreementPreviewAccepted.value = val ?? false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I have reviewed and accept the statutory MITC Agreement terms & conditions.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                Obx(() => InkWell(
                  onTap: () => controller.privacyPolicyAccepted.value = !controller.privacyPolicyAccepted.value,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => controller.privacyPolicyAccepted.value = val ?? false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I accept the Moneyara SEBI regulatory compliance policies & conditions.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 20),

                // Submit Button
                Obx(() {
                  final isSubmitting = controller.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : controller.submitAgreement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Submit MITC Agreement',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),

                if (controller.mitcProfile.value != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: controller.cancelEditing,
                      child: const Text(
                        'Cancel & Return to Status',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS & DIALOGS
  // =========================================================================
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
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
        textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.sentences,
        keyboardType: isPhone
            ? TextInputType.phone
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: [
          if (isPhone) FilteringTextInputFormatter.digitsOnly,
          if (isPhone) LengthLimitingTextInputFormatter(10),
          if (isPan) LengthLimitingTextInputFormatter(10),
        ],
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
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
          suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadAgreementPdf(BuildContext context, MitcModel profile) {
    final controller = Get.isRegistered<MitcController>()
        ? Get.find<MitcController>()
        : Get.put(MitcController());
    controller.downloadAgreementPdf();
  }
}
